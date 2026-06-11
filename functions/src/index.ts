// functions/src/index.ts
//
// Cloud Functions for the VakantieVeilingen auction app.
//
// IMPORTANT — these are aligned to the ACTUAL app data shapes (verified in the
// Flutter datasources), which differ from the loose written spec:
//   • auctions/{id}.endsAt is a Firestore Timestamp (not an ISO string).
//   • bids live in the SUBCOLLECTION auctions/{id}/bids/{bidId}
//     with fields { auctionId, userId, userName, amount, placedAt: Timestamp }.
//   • the leading bidder is auctions/{id}.lastBidderId (the highest bid wins).
//   • vouchers use { code, isUsed: bool, expiresAt: Timestamp } (not status).
//   • users/{uid}.fcmToken holds the device token.
// Timestamps written here use admin Timestamps for consistency with the app.

import {initializeApp} from "firebase-admin/app";
import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {defineSecret, defineString} from "firebase-functions/params";
import {logger} from "firebase-functions";

initializeApp();
const db = getFirestore();

// ── Mollie config ──────────────────────────────────────────────────────────────
// Secret — set once with:  firebase functions:secrets:set MOLLIE_API_KEY
// Use a test_… key in dev and a live_… key in production. NEVER ship this in the
// client; only these server functions ever see it.
const mollieApiKey = defineSecret("MOLLIE_API_KEY");

// Where Mollie sends the user back to after checkout. The in-app WebView watches
// for "payment/success" in the URL to close itself; the order's `status` flip
// (driven by the webhook) is the real source of truth.
const appRedirectBase = defineString("MOLLIE_REDIRECT_BASE", {
  default: "https://auction-netherlands.web.app",
});

// Public URL Mollie calls to report payment status. After the first deploy,
// confirm the actual mollieWebhook URL and set it with:
//   firebase functions:config is not used — set the param via .env or:
//   firebase deploy  (the default below works for us-central1 cloudfunctions.net)
const mollieWebhookUrl = defineString("MOLLIE_WEBHOOK_URL", {
  default:
    "https://us-central1-auction-netherlands.cloudfunctions.net/mollieWebhook",
});

/** Calls the Mollie REST API and returns the parsed JSON (throws on non-2xx). */
async function mollieFetch(
  path: string,
  apiKey: string,
  init?: {method?: string; body?: Record<string, unknown>},
): Promise<Record<string, unknown>> {
  const res = await fetch(`https://api.mollie.com/v2${path}`, {
    method: init?.method ?? "GET",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: init?.body ? JSON.stringify(init.body) : undefined,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Mollie ${res.status}: ${text}`);
  }
  return (await res.json()) as Record<string, unknown>;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Sends a push notification to a single device token (best-effort). */
async function sendToToken(
  token: string | undefined | null,
  title: string,
  body: string,
  data: Record<string, string> = {},
): Promise<void> {
  if (!token) return;
  try {
    await getMessaging().send({token, notification: {title, body}, data});
  } catch (err) {
    logger.warn("FCM send failed", err);
  }
}

/**
 * Logs an in-app notification into the user's feed. Matches the app, which
 * reads users/{uid}/notifications ordered by createdAt with a `read` flag.
 */
async function logNotification(
  userId: string,
  title: string,
  body: string,
  type: string,
  referenceId?: string,
): Promise<void> {
  await db
    .collection("users")
    .doc(userId)
    .collection("notifications")
    .add({
      title,
      body,
      type,
      data: referenceId ? {referenceId} : {},
      read: false,
      createdAt: Timestamp.now(),
    });
}

/** Fetches a user's fcmToken. */
async function getUserToken(userId: string): Promise<string | undefined> {
  const snap = await db.collection("users").doc(userId).get();
  return snap.exists ? (snap.data()?.fcmToken as string | undefined) : undefined;
}

/** Random 8-char uppercase alphanumeric voucher code. */
function generateVoucherCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let out = "";
  for (let i = 0; i < 8; i++) {
    out += chars[Math.floor(Math.random() * chars.length)];
  }
  return out;
}

/** Adds whole months to a Date. */
function addMonths(date: Date, months: number): Date {
  const d = new Date(date);
  d.setMonth(d.getMonth() + months);
  return d;
}

// ── 0. placeBid — server-authoritative bid placement ───────────────────────────
// All bids go through here. Running with admin privileges, this is the ONLY
// path that may mutate auctions/{id}.currentBid and write the bids subcollection
// (Firestore rules deny those writes to clients). Every value is validated
// server-side so the client cannot spoof amounts, bid past the deadline, or
// forge the bidder identity.
export const placeBid = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Je moet ingelogd zijn om te bieden.");
  }

  const auctionId = request.data?.auctionId as string | undefined;
  const amount = Number(request.data?.amount);
  if (!auctionId || typeof auctionId !== "string") {
    throw new HttpsError("invalid-argument", "auctionId ontbreekt.");
  }
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new HttpsError("invalid-argument", "Ongeldig bedrag.");
  }

  // Block banned users.
  const userSnap = await db.collection("users").doc(uid).get();
  if (userSnap.data()?.isBanned === true) {
    throw new HttpsError("permission-denied", "Je account is geblokkeerd.");
  }
  const userName =
    (userSnap.data()?.displayName as string | undefined) ?? "Anonymous";

  const auctionRef = db.collection("auctions").doc(auctionId);

  const result = await db.runTransaction(async (tx) => {
    const doc = await tx.get(auctionRef);
    if (!doc.exists) {
      throw new HttpsError("not-found", "Veiling niet gevonden.");
    }
    const a = doc.data() as Record<string, unknown>;

    // Auction must be live.
    if (a.status !== "live") {
      throw new HttpsError("failed-precondition", "Deze veiling is niet actief.");
    }

    // endsAt may be a Timestamp (created) or an ISO string (older edits).
    const rawEnd = a.endsAt;
    let end: Date;
    if (rawEnd instanceof Timestamp) {
      end = rawEnd.toDate();
    } else if (typeof rawEnd === "string") {
      end = new Date(rawEnd);
    } else {
      throw new HttpsError("failed-precondition", "Veiling heeft geen einddatum.");
    }
    const now = new Date();
    if (now >= end) {
      throw new HttpsError("failed-precondition", "Deze veiling is al afgelopen.");
    }

    const cur = Number(a.currentBid ?? 0);
    const inc = Number(a.minBidIncrement ?? 1);
    const extSec = Number(a.extensionSeconds ?? 30);

    // Already the highest bidder — nothing to do.
    if (a.lastBidderId === uid) {
      throw new HttpsError(
        "failed-precondition",
        "Je bent al de hoogste bieder.",
      );
    }

    if (amount < cur + inc) {
      throw new HttpsError(
        "failed-precondition",
        `Minimumbod is € ${(cur + inc).toFixed(2)}.`,
      );
    }

    // Auto-extend: a bid in the last 60s pushes the end out by extensionSeconds.
    const updates: Record<string, unknown> = {
      currentBid: amount,
      bidCount: FieldValue.increment(1),
      lastBidderId: uid,
    };
    const secondsLeft = (end.getTime() - now.getTime()) / 1000;
    let newEnd = end;
    if (secondsLeft <= 60) {
      newEnd = new Date(end.getTime() + extSec * 1000);
      updates.endsAt = Timestamp.fromDate(newEnd);
    }

    tx.update(auctionRef, updates);
    tx.set(auctionRef.collection("bids").doc(), {
      auctionId,
      userId: uid,
      userName,
      amount,
      placedAt: Timestamp.now(),
    });

    // Keep the bidder's stat in sync (read by admin targeting & profile).
    tx.set(
      db.collection("users").doc(uid),
      {bidsCount: FieldValue.increment(1)},
      {merge: true},
    );

    return {currentBid: amount, endsAt: newEnd.toISOString(), bidCount: (Number(a.bidCount ?? 0) + 1)};
  });

  return {success: true, ...result};
});

// ── 1. onAuctionEnd — close live auctions past their end time ──────────────────
// Scheduled every minute. Sets winner (= lastBidderId), creates a pending order,
// and notifies the winner.
export const onAuctionEnd = onSchedule("every 1 minutes", async () => {
  const now = Timestamp.now();
  const due = await db
    .collection("auctions")
    .where("status", "==", "live")
    .where("endsAt", "<=", now)
    .get();

  for (const doc of due.docs) {
    const a = doc.data();
    const winnerId = (a.lastBidderId as string | undefined) ?? null;

    let winnerName: string | null = null;
    let winnerEmail: string | null = null;
    if (winnerId) {
      const u = await db.collection("users").doc(winnerId).get();
      winnerName = (u.data()?.displayName as string | undefined) ?? null;
      winnerEmail = (u.data()?.email as string | undefined) ?? null;
    }

    await doc.ref.update({
      status: "ended",
      winnerId,
      winnerName,
      winnerEmail,
    });

    if (!winnerId) continue;

    // Create a pending order (24h to pay).
    const expiresAt = Timestamp.fromMillis(Date.now() + 24 * 60 * 60 * 1000);
    const images = (a.imageUrls as string[] | undefined) ?? [];
    const orderRef = await db.collection("orders").add({
      auctionId: doc.id,
      auctionTitle: a.title ?? "",
      auctionImageUrl: a.imageUrl ?? images[0] ?? "",
      userId: winnerId,
      userName: winnerName ?? "",
      userEmail: winnerEmail ?? "",
      amount: a.currentBid ?? 0,
      status: "pending",
      createdAt: Timestamp.now(),
      expiresAt,
      // The app's PaymentPage reads `paymentDeadline`; keep both in sync
      // (onOrderExpire queries `expiresAt`).
      paymentDeadline: expiresAt,
      reminderSent: false,
    });

    const token = await getUserToken(winnerId);
    await sendToToken(
      token,
      "🏆 Gefeliciteerd! Je hebt gewonnen!",
      `Je hebt "${a.title}" gewonnen. Betaal binnen 24 uur.`,
      {type: "won", orderId: orderRef.id, auctionId: doc.id},
    );
    await logNotification(
      winnerId,
      "🏆 Gefeliciteerd! Je hebt gewonnen!",
      `Je hebt "${a.title}" gewonnen. Betaal binnen 24 uur.`,
      "won",
      orderRef.id,
    );
  }

  logger.info(`onAuctionEnd processed ${due.size} auctions`);
});

// ── 2. onBidCreated — notify the bidder who was just outbid ────────────────────
export const onBidCreated = onDocumentCreated(
  "auctions/{auctionId}/bids/{bidId}",
  async (event) => {
    const bid = event.data?.data();
    if (!bid) return;
    const auctionId = event.params.auctionId;
    const newBidderId = bid.userId as string;

    // Find the previous highest bid (the one being outbid).
    const prev = await db
      .collection("auctions")
      .doc(auctionId)
      .collection("bids")
      .orderBy("amount", "desc")
      .limit(5)
      .get();

    const outbid = prev.docs
      .map((d) => d.data())
      .find((b) => b.userId !== newBidderId);
    if (!outbid) return;

    const outbidUserId = outbid.userId as string;
    const userSnap = await db.collection("users").doc(outbidUserId).get();
    if (!userSnap.exists) return;
    // The app stores prefs in a `notificationPrefs` map (key `bids`).
    const prefs = userSnap.data()?.notificationPrefs as
      {bids?: boolean} | undefined;
    if (prefs?.bids === false) return;

    const auctionSnap = await db.collection("auctions").doc(auctionId).get();
    const title = (auctionSnap.data()?.title as string | undefined) ?? "veiling";

    await sendToToken(
      userSnap.data()?.fcmToken as string | undefined,
      "😮 Je bent overboden!",
      `Iemand heeft hoger geboden op "${title}". Bied opnieuw!`,
      {type: "outbid", auctionId},
    );
    await logNotification(
      outbidUserId,
      "😮 Je bent overboden!",
      `Iemand heeft hoger geboden op "${title}". Bied opnieuw!`,
      "outbid",
      auctionId,
    );
  },
);

// ── 3. onOrderPaid — generate the voucher once an order is paid ────────────────
// (The written spec ties voucher creation to auction end, but the real flow
//  issues a voucher only after a successful payment — implemented here.)
export const onOrderPaid = onDocumentUpdated("orders/{orderId}", async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  if (before.status === "paid" || after.status !== "paid") return;

  // Avoid duplicate vouchers for the same order.
  const existing = await db
    .collection("vouchers")
    .where("orderId", "==", event.params.orderId)
    .limit(1)
    .get();
  if (!existing.empty) return;

  const auctionSnap = await db
    .collection("auctions")
    .doc(after.auctionId as string)
    .get();
  const a = auctionSnap.data() ?? {};
  const validityMonths = (a.validityMonths as number | undefined) ?? 12;
  const code = generateVoucherCode();
  const now = new Date();

  const voucherRef = await db.collection("vouchers").add({
    code,
    qrData: code,
    auctionId: after.auctionId,
    auctionTitle: after.auctionTitle ?? a.title ?? "",
    auctionImageUrl: after.auctionImageUrl ?? "",
    merchant: a.merchant ?? "",
    userId: after.userId,
    userName: after.userName ?? "",
    userEmail: after.userEmail ?? "",
    orderId: event.params.orderId,
    isUsed: false,
    validFrom: Timestamp.fromDate(now),
    expiresAt: Timestamp.fromDate(addMonths(now, validityMonths)),
    reservationRequired: (a.reservationRequired as boolean | undefined) ?? false,
    reservationUrl: a.reservationUrl ?? null,
    createdAt: Timestamp.fromDate(now),
  });

  // Link the voucher back to the order so the success screen can show it.
  await event.data?.after.ref.update({voucherId: voucherRef.id});

  const token = await getUserToken(after.userId as string);
  await sendToToken(
    token,
    "🎫 Je voucher staat klaar!",
    `Je voucher voor "${after.auctionTitle}" is beschikbaar.`,
    {type: "system", orderId: event.params.orderId},
  );
});

// ── 4. onOrderExpire — cancel unpaid orders past their deadline ────────────────
export const onOrderExpire = onSchedule("every 60 minutes", async () => {
  const now = Timestamp.now();
  const expired = await db
    .collection("orders")
    .where("status", "==", "pending")
    .where("expiresAt", "<=", now)
    .get();

  const batch = db.batch();
  expired.docs.forEach((d) => batch.update(d.ref, {status: "cancelled"}));
  if (!expired.empty) await batch.commit();
  logger.info(`onOrderExpire cancelled ${expired.size} orders`);
});

// ── 5. onPaymentReminder — remind winners ~4h before the deadline ──────────────
export const onPaymentReminder = onSchedule("every 60 minutes", async () => {
  const cutoff = Timestamp.fromMillis(Date.now() - 20 * 60 * 60 * 1000);
  const pending = await db
    .collection("orders")
    .where("status", "==", "pending")
    .where("createdAt", "<=", cutoff)
    .get();

  for (const doc of pending.docs) {
    const o = doc.data();
    if (o.reminderSent === true) continue;
    const token = await getUserToken(o.userId as string);
    await sendToToken(
      token,
      "💳 Betaalherinnering — nog 4 uur!",
      `Vergeet niet "${o.auctionTitle}" te betalen voordat de tijd verloopt.`,
      {type: "payment_reminder", orderId: doc.id},
    );
    await logNotification(
      o.userId as string,
      "💳 Betaalherinnering — nog 4 uur!",
      `Vergeet niet "${o.auctionTitle}" te betalen voordat de tijd verloopt.`,
      "payment_reminder",
      doc.id,
    );
    await doc.ref.update({reminderSent: true});
  }
  logger.info(`onPaymentReminder checked ${pending.size} orders`);
});

// ── 6. onAlarmsDue — fire auction-ending alarms ────────────────────────────────
export const onAlarmsDue = onSchedule("every 1 minutes", async () => {
  const now = Timestamp.now();
  const due = await db
    .collection("alarms")
    .where("triggered", "==", false)
    .where("notifyAt", "<=", now)
    .get();

  for (const doc of due.docs) {
    const al = doc.data();
    const token = await getUserToken(al.userId as string);
    await sendToToken(
      token,
      "⏰ Je veiling loopt bijna af!",
      `"${al.auctionTitle}" eindigt binnenkort. Plaats snel je bod!`,
      {type: "alarm", auctionId: al.auctionId as string},
    );
    await logNotification(
      al.userId as string,
      "⏰ Je veiling loopt bijna af!",
      `"${al.auctionTitle}" eindigt binnenkort. Plaats snel je bod!`,
      "alarm",
      al.auctionId as string,
    );
    await doc.ref.update({triggered: true});
  }
  logger.info(`onAlarmsDue fired ${due.size} alarms`);
});

// ── 7. onReferralSignup — reward the referrer on a new signup ──────────────────
export const onReferralSignup = onDocumentCreated("users/{uid}", async (event) => {
  const user = event.data?.data();
  if (!user) return;

  // Resolve the referrer: prefer an explicit uid, otherwise look up by the code
  // the new user typed in (which is the referrer's own `referralCode`).
  let referredBy = user.referredBy as string | undefined;
  const referredByCode = user.referredByCode as string | undefined;
  if (!referredBy && referredByCode) {
    const q = await db
      .collection("users")
      .where("referralCode", "==", referredByCode)
      .limit(1)
      .get();
    if (!q.empty) referredBy = q.docs[0].id;
  }
  if (!referredBy) return;
  // Guard against self-referral.
  if (referredBy === event.params.uid) return;

  const configSnap = await db.collection("config").doc("app_settings").get();
  const reward =
    (configSnap.data()?.referralRewardCredits as number | undefined) ?? 2.5;

  const referrerRef = db.collection("users").doc(referredBy);
  await referrerRef.update({
    bidCredits: FieldValue.increment(reward),
    referralCount: FieldValue.increment(1),
  });

  // type/credit + Timestamp match what the app's WalletPage reads.
  await db.collection("wallet_transactions").add({
    userId: referredBy,
    type: "credit",
    source: "referral",
    amount: reward,
    description: "Vriend uitgenodigd",
    referenceId: event.params.uid,
    createdAt: Timestamp.now(),
  });

  await db.collection("referrals").add({
    referrerId: referredBy,
    referrerCode: referredByCode ?? "",
    newUserId: event.params.uid,
    newUserEmail: (user.email as string | undefined) ?? "",
    rewardGiven: true,
    createdAt: Timestamp.now(),
  });

  const token = await getUserToken(referredBy);
  await sendToToken(
    token,
    "🎉 Je hebt tegoed verdiend!",
    `Een vriend heeft zich aangemeld. Je ontvangt € ${reward.toFixed(2)} tegoed.`,
    {type: "promo"},
  );
});

// ── 8. onNotificationSend — admin broadcast fan-out ────────────────────────────
// Triggers on the top-level `notifications` collection the admin panel writes to.
export const onNotificationSend = onDocumentCreated(
  "notifications/{id}",
  async (event) => {
    const n = event.data?.data();
    if (!n || n.status !== "scheduled") return;
    await event.data?.ref.update({status: "sending"});

    const title = (n.title as string | undefined) ?? "";
    const body = (n.body as string | undefined) ?? "";
    const target = (n.target as string | undefined) ?? "all";

    // Resolve the audience → list of fcm tokens.
    let tokens: string[] = [];
    if (target === "specific" && n.targetUserId) {
      const t = await getUserToken(n.targetUserId as string);
      if (t) tokens = [t];
    } else if (target === "winners") {
      const snap = await db
        .collection("users")
        .where("wonCount", ">", 0)
        .get();
      tokens = snap.docs
        .map((d) => d.data().fcmToken as string | undefined)
        .filter((t): t is string => !!t);
    } else if (target === "active_bidders") {
      const snap = await db
        .collection("users")
        .where("bidsCount", ">", 0)
        .get();
      tokens = snap.docs
        .map((d) => d.data().fcmToken as string | undefined)
        .filter((t): t is string => !!t);
    } else {
      const snap = await db.collection("users").get();
      tokens = snap.docs
        .map((d) => d.data().fcmToken as string | undefined)
        .filter((t): t is string => !!t);
    }

    // Send in batches of 500 (FCM multicast limit).
    let sent = 0;
    for (let i = 0; i < tokens.length; i += 500) {
      const chunk = tokens.slice(i, i + 500);
      if (chunk.length === 0) continue;
      const res = await getMessaging().sendEachForMulticast({
        tokens: chunk,
        notification: {title, body},
        data: {type: "promo"},
      });
      sent += res.successCount;
    }

    await event.data?.ref.update({
      status: "sent",
      sentCount: sent,
      sentAt: new Date().toISOString(),
    });
    logger.info(`onNotificationSend delivered to ${sent} devices`);
  },
);

// ── 9. createMolliePayment — start a Mollie checkout for an order ───────────────
// Callable. Creates (or reuses) a Mollie payment for the caller's own order and
// returns the hosted checkout URL. The Mollie API key lives only here (secret).
export const createMolliePayment = onCall(
  {secrets: [mollieApiKey]},
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Je moet ingelogd zijn.");
    }
    const orderId = request.data?.orderId as string | undefined;
    if (!orderId) {
      throw new HttpsError("invalid-argument", "orderId ontbreekt.");
    }

    const orderRef = db.collection("orders").doc(orderId);
    const orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw new HttpsError("not-found", "Bestelling niet gevonden.");
    }
    const order = orderSnap.data() as Record<string, unknown>;

    // Ownership + state checks.
    if (order.userId !== uid) {
      throw new HttpsError("permission-denied", "Dit is niet jouw bestelling.");
    }
    if (order.status === "paid") {
      throw new HttpsError("failed-precondition", "Deze bestelling is al betaald.");
    }
    if (order.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Deze bestelling kan niet meer betaald worden.",
      );
    }

    // Reuse an existing open payment instead of charging twice.
    if (order.molliePaymentId && order.checkoutUrl) {
      try {
        const existing = await mollieFetch(
          `/payments/${order.molliePaymentId as string}`,
          mollieApiKey.value(),
        );
        if (existing.status === "open" || existing.status === "pending") {
          return {checkoutUrl: order.checkoutUrl as string};
        }
      } catch (err) {
        logger.warn("Reuse of existing Mollie payment failed; creating new", err);
      }
    }

    const amount = Number(order.amount ?? 0);
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new HttpsError("failed-precondition", "Ongeldig bedrag.");
    }

    const payment = await mollieFetch("/payments", mollieApiKey.value(), {
      method: "POST",
      body: {
        amount: {currency: "EUR", value: amount.toFixed(2)},
        description: `Veiling: ${(order.auctionTitle as string | undefined) ?? orderId}`,
        redirectUrl: `${appRedirectBase.value()}/payment/success?orderId=${orderId}`,
        webhookUrl: mollieWebhookUrl.value(),
        metadata: {orderId},
      },
    });

    const links = payment._links as {checkout?: {href?: string}} | undefined;
    const checkoutUrl = links?.checkout?.href;
    if (!checkoutUrl) {
      throw new HttpsError("internal", "Mollie gaf geen checkout-URL terug.");
    }

    await orderRef.update({
      molliePaymentId: payment.id as string,
      mollieStatus: payment.status as string,
      checkoutUrl,
      updatedAt: Timestamp.now(),
    });

    return {checkoutUrl};
  },
);

// ── 10. mollieWebhook — Mollie calls this when a payment changes state ──────────
// HTTP endpoint. Mollie POSTs `id=tr_…`; we re-fetch the payment server-side
// (never trust the body) and flip the order to `paid` on success — which in turn
// triggers onOrderPaid to issue the voucher. Always returns 200 so Mollie stops
// retrying once we've recorded the state.
export const mollieWebhook = onRequest(
  {secrets: [mollieApiKey]},
  async (req, res) => {
    try {
      const paymentId = (req.body?.id as string | undefined) ??
        (req.query?.id as string | undefined);
      if (!paymentId) {
        res.status(400).send("missing id");
        return;
      }

      const payment = await mollieFetch(
        `/payments/${paymentId}`,
        mollieApiKey.value(),
      );
      const metadata = payment.metadata as {orderId?: string} | undefined;
      const orderId = metadata?.orderId;
      const status = payment.status as string;

      if (!orderId) {
        logger.warn(`mollieWebhook: payment ${paymentId} has no orderId`);
        res.status(200).send("ok");
        return;
      }

      const orderRef = db.collection("orders").doc(orderId);
      const orderSnap = await orderRef.get();
      if (!orderSnap.exists) {
        logger.warn(`mollieWebhook: order ${orderId} not found`);
        res.status(200).send("ok");
        return;
      }
      const order = orderSnap.data() as Record<string, unknown>;

      // Always record the latest Mollie status for diagnostics.
      const update: Record<string, unknown> = {
        mollieStatus: status,
        updatedAt: Timestamp.now(),
      };

      // Only flip to paid once, and never downgrade an already-paid order.
      if (status === "paid" && order.status !== "paid") {
        update.status = "paid";
        update.paidAt = Timestamp.now();
      } else if (
        (status === "failed" ||
          status === "expired" ||
          status === "canceled") &&
        order.status === "pending"
      ) {
        // Leave the order pending so the user can retry before the deadline;
        // we just note the failed attempt.
        update.lastPaymentFailure = status;
      }

      await orderRef.update(update);
      res.status(200).send("ok");
    } catch (err) {
      logger.error("mollieWebhook error", err);
      // 500 makes Mollie retry later — appropriate for transient failures.
      res.status(500).send("error");
    }
  },
);
