import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  static String get(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') return _ar[key] ?? _en[key] ?? key;
    if (locale == 'en') return _en[key] ?? _nl[key] ?? key;
    return _nl[key] ?? key;
  }

  // ── App ───────────────────────────────────────────────────────────────────
  static String appName(BuildContext context) => get(context, 'appName');
  static String tagline(BuildContext context) => get(context, 'tagline');

  // ── Auth ──────────────────────────────────────────────────────────────────
  static String login(BuildContext context) => get(context, 'login');
  static String register(BuildContext context) => get(context, 'register');
  static String welcomeBack(BuildContext context) => get(context, 'welcomeBack');
  static String loginSubtitle(BuildContext context) => get(context, 'loginSubtitle');
  static String registerSubtitle(BuildContext context) => get(context, 'registerSubtitle');
  static String email(BuildContext context) => get(context, 'email');
  static String emailInvalid(BuildContext context) => get(context, 'emailInvalid');
  static String password(BuildContext context) => get(context, 'password');
  static String passwordTooShort(BuildContext context) => get(context, 'passwordTooShort');
  static String forgotPassword(BuildContext context) => get(context, 'forgotPassword');
  static String continueWith(BuildContext context) => get(context, 'continueWith');
  static String google(BuildContext context) => get(context, 'google');
  static String noAccount(BuildContext context) => get(context, 'noAccount');
  static String hasAccount(BuildContext context) => get(context, 'hasAccount');
  static String createAccount(BuildContext context) => get(context, 'createAccount');
  static String fieldRequired(BuildContext context) => get(context, 'fieldRequired');
  static String name(BuildContext context) => get(context, 'name');
  static String confirmPassword(BuildContext context) => get(context, 'confirmPassword');
  static String passwordsNoMatch(BuildContext context) => get(context, 'passwordsNoMatch');
  static String logout(BuildContext context) => get(context, 'logout');
  static String forgotPasswordTitle(BuildContext context) => get(context, 'forgotPasswordTitle');
  static String sendBtn(BuildContext context) => get(context, 'sendBtn');
  static String resetLinkSentMsg(BuildContext context) => get(context, 'resetLinkSentMsg');
  static String sendError(BuildContext context) => get(context, 'sendError');

  // ── Onboarding ────────────────────────────────────────────────────────────
  static String onboard1Title(BuildContext context) => get(context, 'onboard1Title');
  static String onboard1Body(BuildContext context) => get(context, 'onboard1Body');
  static String onboard2Title(BuildContext context) => get(context, 'onboard2Title');
  static String onboard2Body(BuildContext context) => get(context, 'onboard2Body');
  static String onboard3Title(BuildContext context) => get(context, 'onboard3Title');
  static String onboard3Body(BuildContext context) => get(context, 'onboard3Body');
  static String skip(BuildContext context) => get(context, 'skip');
  static String getStarted(BuildContext context) => get(context, 'getStarted');
  static String next(BuildContext context) => get(context, 'next');

  // ── Navigation & Shell ────────────────────────────────────────────────────
  static String navHome(BuildContext context) => get(context, 'navHome');
  static String navAuctions(BuildContext context) => get(context, 'navAuctions');
  static String navScratchCard(BuildContext context) => get(context, 'navScratchCard');
  static String navVouchers(BuildContext context) => get(context, 'navVouchers');
  static String navProfile(BuildContext context) => get(context, 'navProfile');

  // ── My Auctions ───────────────────────────────────────────────────────────
  static String myAuctions(BuildContext context) => get(context, 'myAuctions');
  static String active(BuildContext context) => get(context, 'active');
  static String won(BuildContext context) => get(context, 'won');
  static String payNow(BuildContext context) => get(context, 'payNow');
  static String saved(BuildContext context) => get(context, 'saved');
  static String retryBtn(BuildContext context) => get(context, 'retryBtn');
  static String orderNotFoundMsg(BuildContext context) => get(context, 'orderNotFoundMsg');

  // ── Home & Categories ─────────────────────────────────────────────────────
  static String all(BuildContext context) => get(context, 'all');
  static String allAuctions(BuildContext context) => get(context, 'allAuctions');
  static String endingSoon(BuildContext context) => get(context, 'endingSoon');
  static String sectionEndingSoon(BuildContext context) => get(context, 'sectionEndingSoon');
  static String catVacation(BuildContext context) => get(context, 'catVacation');
  static String catBeauty(BuildContext context) => get(context, 'catBeauty');
  static String catSauna(BuildContext context) => get(context, 'catSauna');
  static String catFood(BuildContext context) => get(context, 'catFood');
  static String catExperiences(BuildContext context) => get(context, 'catExperiences');
  static String catProducts(BuildContext context) => get(context, 'catProducts');
  static String catSports(BuildContext context) => get(context, 'catSports');
  static String catWellness(BuildContext context) => get(context, 'catWellness');
  static String catDayTrips(BuildContext context) => get(context, 'catDayTrips');
  static String connectionError(BuildContext context) => get(context, 'connectionError');

  // ── Auction Detail ────────────────────────────────────────────────────────
  static String bidPlaced(BuildContext context) => get(context, 'bidPlaced');
  static String outbid(BuildContext context) => get(context, 'outbid');
  static String currentBid(BuildContext context) => get(context, 'currentBid');
  static String endsIn(BuildContext context) => get(context, 'endsIn');
  static String retailValue(BuildContext context) => get(context, 'retailValue');
  static String yourSaving(BuildContext context) => get(context, 'yourSaving');
  static String tabDescription(BuildContext context) => get(context, 'tabDescription');
  static String tabBids(BuildContext context) => get(context, 'tabBids');

  // ── Scratch Card ──────────────────────────────────────────────────────────
  static String scratchCard(BuildContext context) => get(context, 'scratchCard');
  static String scratchToReveal(BuildContext context) => get(context, 'scratchToReveal');
  static String shareForExtra(BuildContext context) => get(context, 'shareForExtra');
  static String congratulations(BuildContext context) => get(context, 'congratulations');
  static String comeBackTomorrow(BuildContext context) => get(context, 'comeBackTomorrow');
  static String streakTitle(BuildContext context) => get(context, 'streakTitle');
  static String claimPrize(BuildContext context) => get(context, 'claimPrize');
  static String scratchPrizeAdded(BuildContext context) => get(context, 'scratchPrizeAdded');
  static String creditReceived(BuildContext context) => get(context, 'creditReceived');
  static String shareAppMsg(BuildContext context) => get(context, 'shareAppMsg');
  static String scratchPrizeWon(BuildContext context, String prize) =>
      get(context, 'scratchPrizeWon').replaceAll('{prize}', prize);

  // ── Search ────────────────────────────────────────────────────────────────
  static String searchHint(BuildContext context) => get(context, 'searchHint');
  static String searchPrompt(BuildContext context) => get(context, 'searchPrompt');
  static String noResults(BuildContext context) => get(context, 'noResults');

  // ── Notifications ─────────────────────────────────────────────────────────
  static String loginForNotifications(BuildContext context) => get(context, 'loginForNotifications');
  static String markAllRead(BuildContext context) => get(context, 'markAllRead');
  static String noNotifications(BuildContext context) => get(context, 'noNotifications');
  static String errorPrefix(BuildContext context) => get(context, 'errorPrefix');
  static String minAgo(BuildContext context, int n) =>
      get(context, 'minAgo').replaceAll('{n}', '$n');
  static String hourAgo(BuildContext context, int n) =>
      get(context, 'hourAgo').replaceAll('{n}', '$n');
  static String daysAgo(BuildContext context, int n) =>
      get(context, 'daysAgo').replaceAll('{n}', '$n');

  // ── Tickets / Vouchers ────────────────────────────────────────────────────
  static String loginForVouchers(BuildContext context) => get(context, 'loginForVouchers');
  static String myVouchers(BuildContext context) => get(context, 'myVouchers');
  static String winVoucherHint(BuildContext context) => get(context, 'winVoucherHint');
  static String validUntil(BuildContext context) => get(context, 'validUntil');
  static String usedStatus(BuildContext context) => get(context, 'usedStatus');
  static String expiredStatus(BuildContext context) => get(context, 'expiredStatus');
  static String showQrAtCheckin(BuildContext context) => get(context, 'showQrAtCheckin');
  static String showQrAtBusiness(BuildContext context) => get(context, 'showQrAtBusiness');
  static String voucherNotFound(BuildContext context) => get(context, 'voucherNotFound');
  static String noTickets(BuildContext context) => get(context, 'noTickets');
  static String myVoucher(BuildContext context) => get(context, 'myVoucher');
  static String voucherCode(BuildContext context) => get(context, 'voucherCode');
  static String showQr(BuildContext context) => get(context, 'showQr');

  // ── Payment ───────────────────────────────────────────────────────────────
  static String paymentSuccess(BuildContext context) => get(context, 'paymentSuccess');
  static String yourVoucher(BuildContext context) => get(context, 'yourVoucher');
  static String voucherCreating(BuildContext context) => get(context, 'voucherCreating');
  static String viewVoucher(BuildContext context) => get(context, 'viewVoucher');

  // ── Wallet ────────────────────────────────────────────────────────────────
  static String loginForWallet(BuildContext context) => get(context, 'loginForWallet');
  static String wallet(BuildContext context) => get(context, 'wallet');
  static String walletLoadError(BuildContext context) => get(context, 'walletLoadError');
  static String txLoadError(BuildContext context) => get(context, 'txLoadError');
  static String filterReceived(BuildContext context) => get(context, 'filterReceived');
  static String filterUsed(BuildContext context) => get(context, 'filterUsed');
  static String txHistory(BuildContext context) => get(context, 'txHistory');
  static String noTransactions(BuildContext context) => get(context, 'noTransactions');
  static String biddingCredit(BuildContext context) => get(context, 'biddingCredit');
  static String creditInfo(BuildContext context) => get(context, 'creditInfo');

  // ── Referral ──────────────────────────────────────────────────────────────
  static String inviteFriendsTitle(BuildContext context) => get(context, 'inviteFriendsTitle');
  static String inviteTitle(BuildContext context) => get(context, 'inviteTitle');
  static String inviteSubtitle(BuildContext context) => get(context, 'inviteSubtitle');
  static String yourInviteCode(BuildContext context) => get(context, 'yourInviteCode');
  static String copy(BuildContext context) => get(context, 'copy');
  static String share(BuildContext context) => get(context, 'share');
  static String invited(BuildContext context) => get(context, 'invited');
  static String earned(BuildContext context) => get(context, 'earned');
  static String howItWorks(BuildContext context) => get(context, 'howItWorks');
  static String codeCopied(BuildContext context) => get(context, 'codeCopied');
  static String step1Title(BuildContext context) => get(context, 'step1Title');
  static String step1Body(BuildContext context) => get(context, 'step1Body');
  static String step2Title(BuildContext context) => get(context, 'step2Title');
  static String step2Body(BuildContext context) => get(context, 'step2Body');
  static String step3Title(BuildContext context) => get(context, 'step3Title');
  static String step3Body(BuildContext context) => get(context, 'step3Body');
  static String referralShareMsg(BuildContext context, String code) =>
      get(context, 'referralShareMsg').replaceAll('{code}', code);
  static String referralShareSubject(BuildContext context) => get(context, 'referralShareSubject');

  // ── Profile ───────────────────────────────────────────────────────────────
  static String profile(BuildContext context) => get(context, 'profile');
  static String editProfile(BuildContext context) => get(context, 'editProfile');
  static String notifications(BuildContext context) => get(context, 'notifications');
  static String darkMode(BuildContext context) => get(context, 'darkMode');
  static String language(BuildContext context) => get(context, 'language');
  static String help(BuildContext context) => get(context, 'help');
  static String about(BuildContext context) => get(context, 'about');
  static String deleteAccount(BuildContext context) => get(context, 'deleteAccount');
  static String defaultUser(BuildContext context) => get(context, 'defaultUser');
  static String walletAndCredit(BuildContext context) => get(context, 'walletAndCredit');
  static String inviteFriends(BuildContext context) => get(context, 'inviteFriends');
  static String sectionAccount(BuildContext context) => get(context, 'sectionAccount');
  static String sectionMore(BuildContext context) => get(context, 'sectionMore');
  static String sectionAccountManage(BuildContext context) => get(context, 'sectionAccountManage');
  static String helpQuestion(BuildContext context) => get(context, 'helpQuestion');
  static String supportHours(BuildContext context) => get(context, 'supportHours');
  static String close(BuildContext context) => get(context, 'close');
  static String aboutDesc(BuildContext context) => get(context, 'aboutDesc');
  static String deleteAccountConfirmMsg(BuildContext context) => get(context, 'deleteAccountConfirmMsg');
  static String langNl(BuildContext context) => get(context, 'langNl');
  static String langEn(BuildContext context) => get(context, 'langEn');
  static String langAr(BuildContext context) => get(context, 'langAr');
  static String cancel(BuildContext context) => get(context, 'cancel');
  static String reloginToDeleteMsg(BuildContext context) => get(context, 'reloginToDeleteMsg');

  // ── Account Settings ──────────────────────────────────────────────────────
  static String settingsSaved(BuildContext context) => get(context, 'settingsSaved');
  static String reloginToChangeName(BuildContext context) => get(context, 'reloginToChangeName');
  static String saveFailed(BuildContext context) => get(context, 'saveFailed');
  static String resetLinkSentTo(BuildContext context, String email) =>
      get(context, 'resetLinkSentTo').replaceAll('{email}', email);
  static String myData(BuildContext context) => get(context, 'myData');
  static String save(BuildContext context) => get(context, 'save');
  static String personalData(BuildContext context) => get(context, 'personalData');
  static String phone(BuildContext context) => get(context, 'phone');
  static String security(BuildContext context) => get(context, 'security');
  static String changePassword(BuildContext context) => get(context, 'changePassword');
  static String changePasswordSub(BuildContext context) => get(context, 'changePasswordSub');
  static String notifPrefs(BuildContext context) => get(context, 'notifPrefs');
  static String notifOutbid(BuildContext context) => get(context, 'notifOutbid');
  static String notifOutbidSub(BuildContext context) => get(context, 'notifOutbidSub');
  static String notifWon(BuildContext context) => get(context, 'notifWon');
  static String notifWonSub(BuildContext context) => get(context, 'notifWonSub');
  static String notifAlarms(BuildContext context) => get(context, 'notifAlarms');
  static String notifAlarmsSub(BuildContext context) => get(context, 'notifAlarmsSub');
  static String notifDeals(BuildContext context) => get(context, 'notifDeals');
  static String notifDealsSub(BuildContext context) => get(context, 'notifDealsSub');
  static String dangerZone(BuildContext context) => get(context, 'dangerZone');
  static String confirmDeleteAccountTitle(BuildContext context) => get(context, 'confirmDeleteAccountTitle');
  static String confirmDeleteAccountMsg(BuildContext context) => get(context, 'confirmDeleteAccountMsg');
  static String confirmDeletion(BuildContext context) => get(context, 'confirmDeletion');
  static String typeDeleteToConfirm(BuildContext context) => get(context, 'typeDeleteToConfirm');
  static String deleteForever(BuildContext context) => get(context, 'deleteForever');
  static String reloginToDelete(BuildContext context) => get(context, 'reloginToDelete');
  static String delete(BuildContext context) => get(context, 'delete');

  // ── Shared ────────────────────────────────────────────────────────────────
  static String noActive(BuildContext context) => get(context, 'noActive');
  static String noWon(BuildContext context) => get(context, 'noWon');
  static String noSaved(BuildContext context) => get(context, 'noSaved');
  static String noPending(BuildContext context) => get(context, 'noPending');
  static String pendingPaymentWarning(BuildContext context) => get(context, 'pendingPaymentWarning');
  static String tryAgain(BuildContext context) => get(context, 'tryAgain');
  static String pageNotFound(BuildContext context) => get(context, 'pageNotFound');
  static String backToHome(BuildContext context) => get(context, 'backToHome');

  // ─────────────────────────────────────────────────────────────────────────
  // Dutch
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _nl = {
    // App
    'appName': 'Vakantieveilingen',
    'tagline': 'Bied op exclusieve aanbiedingen',

    // Auth
    'login': 'Inloggen',
    'register': 'Registreren',
    'welcomeBack': 'Welkom terug!',
    'loginSubtitle': 'Log in om te bieden op exclusieve aanbiedingen',
    'registerSubtitle': 'Maak een account aan om te bieden',
    'email': 'E-mailadres',
    'emailInvalid': 'Voer een geldig e-mailadres in',
    'password': 'Wachtwoord',
    'passwordTooShort': 'Wachtwoord moet minimaal 6 tekens zijn',
    'forgotPassword': 'Wachtwoord vergeten?',
    'continueWith': 'of ga verder met',
    'google': 'Doorgaan met Google',
    'noAccount': 'Nog geen account? Registreer hier',
    'hasAccount': 'Al een account? Log hier in',
    'createAccount': 'Account aanmaken',
    'fieldRequired': 'Dit veld is verplicht',
    'name': 'Naam',
    'confirmPassword': 'Bevestig wachtwoord',
    'passwordsNoMatch': 'Wachtwoorden komen niet overeen',
    'logout': 'Uitloggen',
    'forgotPasswordTitle': 'Wachtwoord vergeten',
    'sendBtn': 'Versturen',
    'resetLinkSentMsg': 'Reset-link verstuurd. Check je e-mail.',
    'sendError': 'Fout bij versturen',

    // Onboarding
    'onboard1Title': 'Bied op droomvakanties',
    'onboard1Body': 'Vind unieke vakanties, uitjes en ervaringen. Bied mee en win voor een fractie van de prijs.',
    'onboard2Title': 'Realtime veilingen',
    'onboard2Body': 'Volg iedere bieding live. Stel een alarm in zodat je nooit een eindsprint mist.',
    'onboard3Title': 'Win en betaal veilig',
    'onboard3Body': 'Gewonnen? Betaal eenvoudig en ontvang je voucher direct in de app. Veilig, snel en betrouwbaar.',
    'skip': 'Overslaan',
    'getStarted': 'Aan de slag',
    'next': 'Volgende',

    // Navigation
    'navHome': 'Home',
    'navAuctions': 'Veilingen',
    'navScratchCard': 'Kraskaart',
    'navVouchers': 'Vouchers',
    'navProfile': 'Profiel',

    // My Auctions
    'myAuctions': 'Mijn veilingen',
    'active': 'Actief',
    'won': 'Gewonnen',
    'payNow': 'Betalen',
    'saved': 'Opgeslagen',
    'retryBtn': 'Opnieuw proberen',
    'orderNotFoundMsg': 'Geen openstaande bestelling gevonden',

    // Home
    'all': 'Alles',
    'allAuctions': 'Alle veilingen',
    'endingSoon': 'Loopt bijna af ⏳',
    'sectionEndingSoon': '🔥 Snel sluitend',
    'catVacation': 'Vakanties',
    'catBeauty': 'Beauty',
    'catSauna': 'Sauna',
    'catFood': 'Eten & drinken',
    'catExperiences': 'Uitjes',
    'catProducts': 'Producten',
    'catSports': 'Sport',
    'catWellness': 'Wellness',
    'catDayTrips': 'Dagtrips',
    'connectionError': 'Verbindingsfout',

    // Auction Detail
    'bidPlaced': 'Bod geplaatst!',
    'outbid': 'Je bent overboden! Bied opnieuw.',
    'currentBid': 'Huidig bod',
    'endsIn': 'Eindigt over',
    'retailValue': 'Winkelwaarde',
    'yourSaving': 'Jij bespaart',
    'tabDescription': 'Beschrijving',
    'tabBids': 'Biedingen',

    // Scratch Card
    'scratchCard': 'Kraskaart',
    'scratchToReveal': 'Kras de kaart om je prijs te onthullen!',
    'shareForExtra': 'Deel de app voor een extra kraskaart',
    'congratulations': 'Gefeliciteerd!',
    'comeBackTomorrow': 'Kom morgen terug voor een nieuwe kraskaart',
    'streakTitle': 'Dagelijkse streak',
    'claimPrize': 'Prijs claimen',
    'scratchPrizeAdded': '🎉 {prize} is toegevoegd aan je wallet!',
    'creditReceived': 'Tegoed ontvangen',
    'shareAppMsg': 'Probeer Vakantieveilingen! Download de app en win geweldige prijzen.',
    'scratchPrizeWon': 'Je hebt {prize} gewonnen!',

    // Search
    'searchHint': 'Zoek een veiling...',
    'searchPrompt': 'Begin met typen om te zoeken',
    'noResults': 'Geen veilingen gevonden',

    // Notifications
    'loginForNotifications': 'Log in om meldingen te zien',
    'markAllRead': 'Alles lezen',
    'noNotifications': 'Geen meldingen',
    'errorPrefix': 'Fout: ',
    'minAgo': '{n} min geleden',
    'hourAgo': '{n} uur geleden',
    'daysAgo': '{n} dag{s} geleden',

    // Tickets / Vouchers
    'loginForVouchers': 'Log in om je vouchers te zien',
    'myVouchers': 'Mijn vouchers',
    'winVoucherHint': 'Win een veiling om een voucher te ontvangen',
    'validUntil': 'Geldig t/m',
    'usedStatus': 'Gebruikt',
    'expiredStatus': 'Verlopen',
    'showQrAtCheckin': 'Toon deze QR-code bij het inchecken aan de medewerker',
    'showQrAtBusiness': 'Toon deze QR-code bij het bedrijf',
    'voucherNotFound': 'Geen voucher gevonden',
    'noTickets': 'Geen vouchers',
    'myVoucher': 'Mijn voucher',
    'voucherCode': 'Vouchercode',
    'showQr': 'Toon deze QR-code bij het inchecken',

    // Payment Success
    'paymentSuccess': 'Betaling geslaagd!',
    'yourVoucher': 'Je voucher',
    'voucherCreating': 'Voucher wordt aangemaakt...',
    'viewVoucher': 'Bekijk voucher',

    // Wallet
    'loginForWallet': 'Log in om je wallet te bekijken',
    'wallet': 'Wallet',
    'walletLoadError': 'Fout bij laden wallet. Probeer het opnieuw.',
    'txLoadError': 'Fout bij laden transacties.',
    'filterReceived': 'Ontvangen',
    'filterUsed': 'Gebruikt',
    'txHistory': 'Transactiegeschiedenis',
    'noTransactions': 'Geen transacties',
    'biddingCredit': 'Biedingstegoeden',
    'creditInfo': 'Tegoed geldig voor biedingen in de app',

    // Referral
    'inviteFriendsTitle': 'Vrienden uitnodigen',
    'inviteTitle': 'Nodig vrienden uit!',
    'inviteSubtitle': 'Jij én je vriend ontvangen €5 biedingstegoed\nzodra je vriend zich registreert.',
    'yourInviteCode': 'Jouw uitnodigingscode',
    'copy': 'Kopiëren',
    'share': 'Delen',
    'invited': 'Uitgenodigd',
    'earned': 'Verdiend',
    'howItWorks': 'Hoe werkt het?',
    'codeCopied': 'Code gekopieerd!',
    'step1Title': 'Deel je code',
    'step1Body': 'Deel je persoonlijke code met vrienden via WhatsApp, mail of social media.',
    'step2Title': 'Vriend registreert',
    'step2Body': 'Je vriend downloadt de app en voert jouw code in tijdens de registratie.',
    'step3Title': 'Beiden profiteren',
    'step3Body': 'Jullie ontvangen allebei €5 biedingstegoed. Bied mee en win!',
    'referralShareMsg': 'Gebruik mijn code {code} bij Vakantieveilingen en ontvang €5 biedingstegoed! 🎉\n\nhttps://vakantieveilingen.nl',
    'referralShareSubject': 'Gratis €5 biedingstegoed',

    // Profile
    'profile': 'Profiel',
    'editProfile': 'Profiel bewerken',
    'notifications': 'Meldingen',
    'darkMode': 'Donkere modus',
    'language': 'Taal',
    'help': 'Help & Support',
    'about': 'Over ons',
    'deleteAccount': 'Account verwijderen',
    'defaultUser': 'Gebruiker',
    'walletAndCredit': 'Wallet & tegoed',
    'inviteFriends': 'Vrienden uitnodigen',
    'sectionAccount': 'Account',
    'sectionMore': 'Meer',
    'sectionAccountManage': 'Account beheer',
    'helpQuestion': 'Heb je een vraag of probleem?',
    'supportHours': 'Ma–Vr 09:00–17:00',
    'close': 'Sluiten',
    'aboutDesc': 'Bied mee op exclusieve vakanties, wellness-arrangementen en meer. Elke dag nieuwe veilingen!',
    'deleteAccountConfirmMsg': 'Weet je zeker dat je je account permanent wilt verwijderen? Al je data, biedingen en vouchers worden verwijderd. Dit kan niet ongedaan worden gemaakt.',
    'langNl': 'Nederlands',
    'langEn': 'English',
    'langAr': 'العربية',
    'cancel': 'Annuleren',
    'reloginToDeleteMsg': 'Log opnieuw in om je account te verwijderen.',

    // Account Settings
    'settingsSaved': 'Instellingen opgeslagen!',
    'reloginToChangeName': 'Log opnieuw in om je naam te wijzigen.',
    'saveFailed': 'Opslaan mislukt. Probeer het opnieuw.',
    'resetLinkSentTo': 'Resetlink verzonden naar {email}',
    'myData': 'Mijn gegevens',
    'save': 'Opslaan',
    'personalData': 'Persoonlijke gegevens',
    'phone': 'Telefoonnummer',
    'security': 'Beveiliging',
    'changePassword': 'Wachtwoord wijzigen',
    'changePasswordSub': 'Ontvang een resetlink per e-mail',
    'notifPrefs': 'Meldingsvoorkeuren',
    'notifOutbid': 'Overboden',
    'notifOutbidSub': 'Ontvang een melding als je overboden wordt',
    'notifWon': 'Gewonnen',
    'notifWonSub': 'Melding als je een veiling wint',
    'notifAlarms': 'Alarms',
    'notifAlarmsSub': 'Veilingsalarmen die je hebt ingesteld',
    'notifDeals': 'Aanbiedingen',
    'notifDealsSub': 'Nieuwe veilingen en promoties',
    'dangerZone': 'Gevaarlijk gebied',
    'confirmDeleteAccountTitle': 'Account verwijderen?',
    'confirmDeleteAccountMsg': 'Weet je zeker dat je je account wil verwijderen? Dit kan niet ongedaan worden gemaakt.',
    'confirmDeletion': 'Bevestig verwijdering',
    'typeDeleteToConfirm': 'Typ DELETE om te bevestigen:',
    'deleteForever': 'Definitief verwijderen',
    'reloginToDelete': 'Log opnieuw in om je account te verwijderen.',
    'delete': 'Verwijderen',

    // Shared
    'noActive': 'Geen actieve biedingen',
    'noWon': 'Nog niets gewonnen',
    'noSaved': 'Geen opgeslagen veilingen',
    'noPending': 'Geen openstaande betalingen',
    'pendingPaymentWarning': 'Je hebt gewonnen veilingen die nog betaald moeten worden!',
    'tryAgain': 'Probeer opnieuw',
    'pageNotFound': 'Pagina niet gevonden',
    'backToHome': 'Terug naar home',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // English
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _en = {
    // App
    'appName': 'Holiday Auctions',
    'tagline': 'Bid on exclusive deals',

    // Auth
    'login': 'Login',
    'register': 'Register',
    'welcomeBack': 'Welcome back!',
    'loginSubtitle': 'Log in to bid on exclusive deals',
    'registerSubtitle': 'Create an account to bid',
    'email': 'Email Address',
    'emailInvalid': 'Enter a valid email address',
    'password': 'Password',
    'passwordTooShort': 'Password must be at least 6 characters',
    'forgotPassword': 'Forgot password?',
    'continueWith': 'or continue with',
    'google': 'Continue with Google',
    'noAccount': 'No account? Register here',
    'hasAccount': 'Already have an account? Log in',
    'createAccount': 'Create Account',
    'fieldRequired': 'This field is required',
    'name': 'Name',
    'confirmPassword': 'Confirm Password',
    'passwordsNoMatch': 'Passwords do not match',
    'logout': 'Logout',
    'forgotPasswordTitle': 'Forgot password',
    'sendBtn': 'Send',
    'resetLinkSentMsg': 'Reset link sent. Check your email.',
    'sendError': 'Error sending',

    // Onboarding
    'onboard1Title': 'Bid on dream vacations',
    'onboard1Body': 'Find unique vacations, trips and experiences. Bid and win for a fraction of the price.',
    'onboard2Title': 'Real-time auctions',
    'onboard2Body': 'Follow every bid live. Set an alarm so you never miss a final sprint.',
    'onboard3Title': 'Win and pay safely',
    'onboard3Body': 'Won? Pay easily and receive your voucher directly in the app. Safe, fast and reliable.',
    'skip': 'Skip',
    'getStarted': 'Get started',
    'next': 'Next',

    // Navigation
    'navHome': 'Home',
    'navAuctions': 'Auctions',
    'navScratchCard': 'Scratch Card',
    'navVouchers': 'Vouchers',
    'navProfile': 'Profile',

    // My Auctions
    'myAuctions': 'My Auctions',
    'active': 'Active',
    'won': 'Won',
    'payNow': 'Pay Now',
    'saved': 'Saved',
    'retryBtn': 'Try again',
    'orderNotFoundMsg': 'No pending order found',

    // Home
    'all': 'All',
    'allAuctions': 'All Auctions',
    'endingSoon': 'Ending soon ⏳',
    'sectionEndingSoon': '🔥 Ending Soon',
    'catVacation': 'Vacations',
    'catBeauty': 'Beauty',
    'catSauna': 'Sauna',
    'catFood': 'Food & Drink',
    'catExperiences': 'Trips',
    'catProducts': 'Products',
    'catSports': 'Sports',
    'catWellness': 'Wellness',
    'catDayTrips': 'Day Trips',
    'connectionError': 'Connection error',

    // Auction Detail
    'bidPlaced': 'Bid placed!',
    'outbid': 'You have been outbid! Bid again.',
    'currentBid': 'Current bid',
    'endsIn': 'Ends in',
    'retailValue': 'Retail value',
    'yourSaving': 'You save',
    'tabDescription': 'Description',
    'tabBids': 'Bids',

    // Scratch Card
    'scratchCard': 'Scratch Card',
    'scratchToReveal': 'Scratch the card to reveal your prize!',
    'shareForExtra': 'Share the app for an extra scratch card',
    'congratulations': 'Congratulations!',
    'comeBackTomorrow': 'Come back tomorrow for a new scratch card',
    'streakTitle': 'Daily streak',
    'claimPrize': 'Claim Prize',
    'scratchPrizeAdded': '🎉 {prize} has been added to your wallet!',
    'creditReceived': 'Credit received',
    'shareAppMsg': 'Try Holiday Auctions! Download the app and win great prizes.',
    'scratchPrizeWon': 'You won {prize}!',

    // Search
    'searchHint': 'Search for an auction...',
    'searchPrompt': 'Start typing to search',
    'noResults': 'No auctions found',

    // Notifications
    'loginForNotifications': 'Log in to see notifications',
    'markAllRead': 'Mark all read',
    'noNotifications': 'No notifications',
    'errorPrefix': 'Error: ',
    'minAgo': '{n} min ago',
    'hourAgo': '{n} hr ago',
    'daysAgo': '{n} day(s) ago',

    // Tickets / Vouchers
    'loginForVouchers': 'Log in to see your vouchers',
    'myVouchers': 'My vouchers',
    'winVoucherHint': 'Win an auction to receive a voucher',
    'validUntil': 'Valid until',
    'usedStatus': 'Used',
    'expiredStatus': 'Expired',
    'showQrAtCheckin': 'Show this QR code to the staff at check-in',
    'showQrAtBusiness': 'Show this QR code at the business',
    'voucherNotFound': 'Voucher not found',
    'noTickets': 'No vouchers',
    'myVoucher': 'My Voucher',
    'voucherCode': 'Voucher Code',
    'showQr': 'Show this QR code at check-in',

    // Payment Success
    'paymentSuccess': 'Payment successful!',
    'yourVoucher': 'Your voucher',
    'voucherCreating': 'Creating voucher...',
    'viewVoucher': 'View voucher',

    // Wallet
    'loginForWallet': 'Log in to view your wallet',
    'wallet': 'Wallet',
    'walletLoadError': 'Error loading wallet. Please try again.',
    'txLoadError': 'Error loading transactions.',
    'filterReceived': 'Received',
    'filterUsed': 'Used',
    'txHistory': 'Transaction history',
    'noTransactions': 'No transactions',
    'biddingCredit': 'Bidding credit',
    'creditInfo': 'Credit valid for bids in the app',

    // Referral
    'inviteFriendsTitle': 'Invite friends',
    'inviteTitle': 'Invite your friends!',
    'inviteSubtitle': 'You and your friend each receive €5 bidding credit\nonce your friend registers.',
    'yourInviteCode': 'Your invite code',
    'copy': 'Copy',
    'share': 'Share',
    'invited': 'Invited',
    'earned': 'Earned',
    'howItWorks': 'How does it work?',
    'codeCopied': 'Code copied!',
    'step1Title': 'Share your code',
    'step1Body': 'Share your personal code with friends via WhatsApp, email or social media.',
    'step2Title': 'Friend registers',
    'step2Body': 'Your friend downloads the app and enters your code during registration.',
    'step3Title': 'Both benefit',
    'step3Body': 'You both receive €5 bidding credit. Bid and win!',
    'referralShareMsg': 'Use my code {code} at Holiday Auctions and receive €5 bidding credit! 🎉\n\nhttps://vakantieveilingen.nl',
    'referralShareSubject': 'Free €5 bidding credit',

    // Profile
    'profile': 'Profile',
    'editProfile': 'Edit Profile',
    'notifications': 'Notifications',
    'darkMode': 'Dark Mode',
    'language': 'Language',
    'help': 'Help & Support',
    'about': 'About Us',
    'deleteAccount': 'Delete Account',
    'defaultUser': 'User',
    'walletAndCredit': 'Wallet & Credit',
    'inviteFriends': 'Invite friends',
    'sectionAccount': 'Account',
    'sectionMore': 'More',
    'sectionAccountManage': 'Account management',
    'helpQuestion': 'Have a question or issue?',
    'supportHours': 'Mon–Fri 09:00–17:00',
    'close': 'Close',
    'aboutDesc': 'Bid on exclusive vacations, wellness packages and more. New auctions every day!',
    'deleteAccountConfirmMsg': 'Are you sure you want to permanently delete your account? All your data, bids and vouchers will be deleted. This cannot be undone.',
    'langNl': 'Dutch',
    'langEn': 'English',
    'langAr': 'Arabic',
    'cancel': 'Cancel',
    'reloginToDeleteMsg': 'Please log in again to delete your account.',

    // Account Settings
    'settingsSaved': 'Settings saved!',
    'reloginToChangeName': 'Please log in again to change your name.',
    'saveFailed': 'Save failed. Please try again.',
    'resetLinkSentTo': 'Reset link sent to {email}',
    'myData': 'My Details',
    'save': 'Save',
    'personalData': 'Personal details',
    'phone': 'Phone number',
    'security': 'Security',
    'changePassword': 'Change password',
    'changePasswordSub': 'Receive a reset link by email',
    'notifPrefs': 'Notification preferences',
    'notifOutbid': 'Outbid',
    'notifOutbidSub': 'Get notified when you are outbid',
    'notifWon': 'Won',
    'notifWonSub': 'Notification when you win an auction',
    'notifAlarms': 'Alarms',
    'notifAlarmsSub': 'Auction alarms you have set',
    'notifDeals': 'Deals',
    'notifDealsSub': 'New auctions and promotions',
    'dangerZone': 'Danger zone',
    'confirmDeleteAccountTitle': 'Delete account?',
    'confirmDeleteAccountMsg': 'Are you sure you want to delete your account? This cannot be undone.',
    'confirmDeletion': 'Confirm deletion',
    'typeDeleteToConfirm': 'Type DELETE to confirm:',
    'deleteForever': 'Delete permanently',
    'reloginToDelete': 'Please log in again to delete your account.',
    'delete': 'Delete',

    // Shared
    'noActive': 'No active bids',
    'noWon': 'Nothing won yet',
    'noSaved': 'No saved auctions',
    'noPending': 'No pending payments',
    'pendingPaymentWarning': 'You have won auctions that still need to be paid!',
    'tryAgain': 'Try again',
    'pageNotFound': 'Page not found',
    'backToHome': 'Back to home',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Arabic
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> _ar = {
    // App
    'appName': 'مزادات العطلات',
    'tagline': 'زايد على عروض حصرية',

    // Auth
    'login': 'تسجيل الدخول',
    'register': 'تسجيل',
    'welcomeBack': 'مرحباً بعودتك!',
    'loginSubtitle': 'سجل دخولك للمزايدة على عروض حصرية',
    'registerSubtitle': 'أنشئ حساباً للمزايدة',
    'email': 'البريد الإلكتروني',
    'emailInvalid': 'أدخل بريداً إلكترونياً صالحاً',
    'password': 'كلمة المرور',
    'passwordTooShort': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    'forgotPassword': 'هل نسيت كلمة المرور؟',
    'continueWith': 'أو المتابعة باستخدام',
    'google': 'المتابعة باستخدام جوجل',
    'noAccount': 'ليس لديك حساب؟ سجل هنا',
    'hasAccount': 'لديك حساب بالفعل؟ سجل دخولك',
    'createAccount': 'إنشاء حساب',
    'fieldRequired': 'هذا الحقل مطلوب',
    'name': 'الاسم',
    'confirmPassword': 'تأكيد كلمة المرور',
    'passwordsNoMatch': 'كلمات المرور غير متطابقة',
    'logout': 'تسجيل الخروج',
    'forgotPasswordTitle': 'نسيت كلمة المرور',
    'sendBtn': 'إرسال',
    'resetLinkSentMsg': 'تم إرسال رابط الإعادة. تحقق من بريدك الإلكتروني.',
    'sendError': 'خطأ في الإرسال',

    // Onboarding
    'onboard1Title': 'زايد على إجازات أحلامك',
    'onboard1Body': 'اعثر على إجازات وتجارب فريدة. زايد وافز بسعر لا يُصدق.',
    'onboard2Title': 'مزادات لحظية',
    'onboard2Body': 'تابع كل مزايدة مباشرة. اضبط تنبيهًا حتى لا تفوتك نهاية المزاد.',
    'onboard3Title': 'افز وادفع بأمان',
    'onboard3Body': 'فزت؟ ادفع بسهولة واستلم قسيمتك مباشرة في التطبيق. آمن وسريع وموثوق.',
    'skip': 'تخطي',
    'getStarted': 'ابدأ الآن',
    'next': 'التالي',

    // Navigation
    'navHome': 'الرئيسية',
    'navAuctions': 'المزادات',
    'navScratchCard': 'كرت الحظ',
    'navVouchers': 'القسائم',
    'navProfile': 'الملف الشخصي',

    // My Auctions
    'myAuctions': 'مزاداتي',
    'active': 'نشط',
    'won': 'فزت بها',
    'payNow': 'ادفع الآن',
    'saved': 'المحفوظة',
    'retryBtn': 'حاول مرة أخرى',
    'orderNotFoundMsg': 'لم يُعثر على طلب معلق',

    // Home
    'all': 'الكل',
    'allAuctions': 'جميع المزادات',
    'endingSoon': 'تنتهي قريباً ⏳',
    'sectionEndingSoon': '🔥 تنتهي قريباً',
    'catVacation': 'عطلات',
    'catBeauty': 'جمال',
    'catSauna': 'ساونا',
    'catFood': 'طعام وشراب',
    'catExperiences': 'رحلات',
    'catProducts': 'منتجات',
    'catSports': 'رياضة',
    'catWellness': 'صحة',
    'catDayTrips': 'رحلات يومية',
    'connectionError': 'خطأ في الاتصال',

    // Auction Detail
    'bidPlaced': 'تم تقديم المزايدة!',
    'outbid': 'تم تجاوز مزايدتك! قدّم مزايدة جديدة.',
    'currentBid': 'المزايدة الحالية',
    'endsIn': 'ينتهي خلال',
    'retailValue': 'القيمة التجارية',
    'yourSaving': 'توفيرك',
    'tabDescription': 'الوصف',
    'tabBids': 'المزايدات',

    // Scratch Card
    'scratchCard': 'بطاقة الحظ',
    'scratchToReveal': 'امسح البطاقة للكشف عن جائزتك!',
    'shareForExtra': 'شارك التطبيق للحصول على بطاقة إضافية',
    'congratulations': 'تهانينا!',
    'comeBackTomorrow': 'عد غداً للحصول على بطاقة جديدة',
    'streakTitle': 'التفاعل اليومي',
    'claimPrize': 'المطالبة بالجائزة',
    'scratchPrizeAdded': '🎉 تمت إضافة {prize} إلى محفظتك!',
    'creditReceived': 'تم استلام الرصيد',
    'shareAppMsg': 'جرّب مزادات العطلات! حمّل التطبيق وافز بجوائز رائعة.',
    'scratchPrizeWon': 'لقد فزت بـ {prize}!',

    // Search
    'searchHint': 'ابحث عن مزاد...',
    'searchPrompt': 'ابدأ الكتابة للبحث',
    'noResults': 'لم يُعثر على مزادات',

    // Notifications
    'loginForNotifications': 'سجل دخولك لرؤية الإشعارات',
    'markAllRead': 'تحديد الكل كمقروء',
    'noNotifications': 'لا توجد إشعارات',
    'errorPrefix': 'خطأ: ',
    'minAgo': 'منذ {n} دقيقة',
    'hourAgo': 'منذ {n} ساعة',
    'daysAgo': 'منذ {n} يوم',

    // Tickets / Vouchers
    'loginForVouchers': 'سجل دخولك لرؤية قسائمك',
    'myVouchers': 'قسائمي',
    'winVoucherHint': 'افز بمزاد للحصول على قسيمة',
    'validUntil': 'صالح حتى',
    'usedStatus': 'مستخدم',
    'expiredStatus': 'منتهي الصلاحية',
    'showQrAtCheckin': 'أظهر رمز QR هذا للموظف عند تسجيل الوصول',
    'showQrAtBusiness': 'أظهر رمز QR هذا في المنشأة',
    'voucherNotFound': 'لم يُعثر على القسيمة',
    'noTickets': 'لا توجد قسائم',
    'myVoucher': 'قسيمتي',
    'voucherCode': 'رمز القسيمة',
    'showQr': 'أظهر رمز QR هذا عند تسجيل الوصول',

    // Payment Success
    'paymentSuccess': 'تمّ الدفع بنجاح!',
    'yourVoucher': 'قسيمتك',
    'voucherCreating': 'جارٍ إنشاء القسيمة...',
    'viewVoucher': 'عرض القسيمة',

    // Wallet
    'loginForWallet': 'سجل دخولك لعرض محفظتك',
    'wallet': 'المحفظة',
    'walletLoadError': 'خطأ في تحميل المحفظة. حاول مرة أخرى.',
    'txLoadError': 'خطأ في تحميل المعاملات.',
    'filterReceived': 'المستلمة',
    'filterUsed': 'المستخدمة',
    'txHistory': 'سجل المعاملات',
    'noTransactions': 'لا توجد معاملات',
    'biddingCredit': 'رصيد المزايدة',
    'creditInfo': 'الرصيد صالح للمزايدة في التطبيق',

    // Referral
    'inviteFriendsTitle': 'دعوة الأصدقاء',
    'inviteTitle': 'ادعُ أصدقاءك!',
    'inviteSubtitle': 'أنت وصديقك تحصلان على رصيد مزايدة €5\nبمجرد تسجيل صديقك.',
    'yourInviteCode': 'كودك الدعوي',
    'copy': 'نسخ',
    'share': 'مشاركة',
    'invited': 'مدعوون',
    'earned': 'مكتسب',
    'howItWorks': 'كيف يعمل؟',
    'codeCopied': 'تم نسخ الكود!',
    'step1Title': 'شارك كودك',
    'step1Body': 'شارك كودك الشخصي مع الأصدقاء عبر واتساب أو البريد أو التواصل الاجتماعي.',
    'step2Title': 'صديقك يسجل',
    'step2Body': 'يحمّل صديقك التطبيق ويدخل كودك أثناء التسجيل.',
    'step3Title': 'كلاكما يستفيد',
    'step3Body': 'تحصلان معًا على رصيد €5. زايدا وافوزا!',
    'referralShareMsg': 'استخدم كودي {code} في مزادات العطلات واحصل على رصيد مزايدة €5! 🎉\n\nhttps://vakantieveilingen.nl',
    'referralShareSubject': 'رصيد مزايدة مجاني €5',

    // Profile
    'profile': 'الملف الشخصي',
    'editProfile': 'تعديل الملف الشخصي',
    'notifications': 'الإشعارات',
    'darkMode': 'الوضع الليلي',
    'language': 'اللغة',
    'help': 'المساعدة والدعم',
    'about': 'من نحن',
    'deleteAccount': 'حذف الحساب',
    'defaultUser': 'المستخدم',
    'walletAndCredit': 'المحفظة والرصيد',
    'inviteFriends': 'دعوة الأصدقاء',
    'sectionAccount': 'الحساب',
    'sectionMore': 'المزيد',
    'sectionAccountManage': 'إدارة الحساب',
    'helpQuestion': 'هل لديك سؤال أو مشكلة؟',
    'supportHours': 'الإثنين–الجمعة 09:00–17:00',
    'close': 'إغلاق',
    'aboutDesc': 'زايد على إجازات وعروض صحية حصرية والمزيد. مزادات جديدة كل يوم!',
    'deleteAccountConfirmMsg': 'هل أنت متأكد من حذف حسابك نهائياً؟ سيتم حذف جميع بياناتك ومزايداتك وقسائمك. لا يمكن التراجع عن ذلك.',
    'langNl': 'الهولندية',
    'langEn': 'الإنجليزية',
    'langAr': 'العربية',
    'cancel': 'إلغاء',
    'reloginToDeleteMsg': 'سجل دخولك مجدداً لحذف حسابك.',

    // Account Settings
    'settingsSaved': 'تم حفظ الإعدادات!',
    'reloginToChangeName': 'سجل دخولك مجدداً لتغيير اسمك.',
    'saveFailed': 'فشل الحفظ. حاول مرة أخرى.',
    'resetLinkSentTo': 'تم إرسال رابط الإعادة إلى {email}',
    'myData': 'بياناتي',
    'save': 'حفظ',
    'personalData': 'البيانات الشخصية',
    'phone': 'رقم الهاتف',
    'security': 'الأمان',
    'changePassword': 'تغيير كلمة المرور',
    'changePasswordSub': 'احصل على رابط إعادة التعيين عبر البريد',
    'notifPrefs': 'تفضيلات الإشعارات',
    'notifOutbid': 'تم تجاوزك',
    'notifOutbidSub': 'احصل على إشعار عند تجاوز مزايدتك',
    'notifWon': 'فوز',
    'notifWonSub': 'إشعار عند الفوز بمزاد',
    'notifAlarms': 'التنبيهات',
    'notifAlarmsSub': 'تنبيهات المزادات التي ضبطتها',
    'notifDeals': 'العروض',
    'notifDealsSub': 'مزادات وعروض جديدة',
    'dangerZone': 'منطقة خطر',
    'confirmDeleteAccountTitle': 'حذف الحساب؟',
    'confirmDeleteAccountMsg': 'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن ذلك.',
    'confirmDeletion': 'تأكيد الحذف',
    'typeDeleteToConfirm': 'اكتب DELETE للتأكيد:',
    'deleteForever': 'حذف نهائي',
    'reloginToDelete': 'سجل دخولك مجدداً لحذف حسابك.',
    'delete': 'حذف',

    // Shared
    'noActive': 'لا توجد مزايدات نشطة',
    'noWon': 'لم تفز بأي شيء بعد',
    'noSaved': 'لا توجد مزادات محفوظة',
    'noPending': 'لا توجد مدفوعات معلقة',
    'pendingPaymentWarning': 'لديك مزادات فزت بها ويجب دفعها!',
    'tryAgain': 'حاول مرة أخرى',
    'pageNotFound': 'الصفحة غير موجودة',
    'backToHome': 'العودة إلى الرئيسية',
  };
}
