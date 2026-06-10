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
import {logger} from "firebase-functions";

initializeApp();
const db = getFirestore();

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
    if (userSnap.data()?.notifyOnOutbid === false) return;

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

  await db.collection("vouchers").add({
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
  const referredBy = user.referredBy as string | undefined;
  if (!referredBy) return;

  const configSnap = await db.collection("config").doc("app_settings").get();
  const reward =
    (configSnap.data()?.referralRewardCredits as number | undefined) ?? 2.5;

  const referrerRef = db.collection("users").doc(referredBy);
  await referrerRef.update({
    bidCredits: FieldValue.increment(reward),
    referralCount: FieldValue.increment(1),
  });

  await db.collection("wallet_transactions").add({
    userId: referredBy,
    type: "earned",
    source: "referral",
    amount: reward,
    description: "Vriend uitgenodigd",
    referenceId: event.params.uid,
    createdAt: new Date().toISOString(),
  });

  await db.collection("referrals").add({
    referrerId: referredBy,
    referrerCode: (user.referredByCode as string | undefined) ?? "",
    newUserId: event.params.uid,
    newUserEmail: (user.email as string | undefined) ?? "",
    rewardGiven: true,
    createdAt: new Date().toISOString(),
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
        .where("totalWins", ">", 0)
        .get();
      tokens = snap.docs
        .map((d) => d.data().fcmToken as string | undefined)
        .filter((t): t is string => !!t);
    } else if (target === "active_bidders") {
      const snap = await db
        .collection("users")
        .where("totalBids", ">", 0)
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
