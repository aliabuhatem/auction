/// All user-facing strings in Dutch (nl-NL) with English fallback keys.
/// Replace values here to support full localization later.
class AppStrings {
  AppStrings._();

  // ── App ────────────────────────────────────────────────
  static const String appName    = 'Vakantieveilingen';
  static const String tagline    = 'Bied op exclusieve aanbiedingen';
  static const String appVersion = '1.0.0';

  // ── Auth — general ────────────────────────────────────
  static const String login          = 'Inloggen';
  static const String register       = 'Registreren';
  static const String logout         = 'Uitloggen';
  static const String email          = 'E-mailadres';
  static const String password       = 'Wachtwoord';
  static const String confirmPassword = 'Bevestig wachtwoord';
  static const String name           = 'Naam';
  static const String forgotPassword = 'Wachtwoord vergeten?';
  static const String continueWith   = 'of ga verder met';
  static const String google         = 'Doorgaan met Google';
  static const String apple          = 'Doorgaan met Apple';
  static const String noAccount      = 'Nog geen account? Registreer hier';
  static const String hasAccount     = 'Al een account? Log hier in';

  // ── Auth — headings ────────────────────────────────────
  static const String welcomeBack    = 'Welkom terug!';
  static const String createAccount  = 'Account aanmaken';
  static const String loginSubtitle  = 'Log in om te bieden op exclusieve aanbiedingen';
  static const String registerSubtitle = 'Maak een account aan en begin met bieden';

  // ── Auth — validation ──────────────────────────────────
  static const String emailInvalid        = 'Voer een geldig e-mailadres in';
  static const String passwordTooShort    = 'Wachtwoord moet minimaal 6 tekens zijn';
  static const String passwordsNoMatch    = 'Wachtwoorden komen niet overeen';
  static const String fieldRequired       = 'Dit veld is verplicht';
  static const String nameTooShort        = 'Naam moet minimaal 2 tekens zijn';

  // ── Bottom Navigation ──────────────────────────────────
  static const String navHome        = 'Home';
  static const String navSearch      = 'Zoeken';
  static const String navScratch     = 'Kraskaart';
  static const String navMyAuctions  = 'Mijn veilingen';
  static const String navProfile     = 'Profiel';

  // ── Home ───────────────────────────────────────────────
  static const String allAuctions    = 'Alle veilingen';
  static const String endingSoon     = 'Loopt bijna af ⏳';
  static const String featuredDeals  = 'Uitgelichte deals';
  static const String newArrivals    = 'Nieuw toegevoegd';
  static const String all            = 'Alles';
  static const String popularNow     = 'Nu populair 🔥';

  // ── Categories ─────────────────────────────────────────
  static const String catVacation    = 'Vakanties';
  static const String catBeauty      = 'Beauty';
  static const String catSauna       = 'Sauna';
  static const String catFood        = 'Eten & drinken';
  static const String catExperiences = 'Uitjes';
  static const String catProducts    = 'Producten';
  static const String catSports      = 'Sport';
  static const String catWellness    = 'Wellness';
  static const String catDayTrips    = 'Dagtrips';

  // ── Auction Card / List ────────────────────────────────
  static const String currentBid     = 'Huidig bod';
  static const String bids           = 'biedingen';
  static const String oneBid         = 'bieding';
  static const String retailValue    = 'Waarde';
  static const String youSave        = 'Jij bespaart';
  static const String location       = 'Locatie';
  static const String ended          = 'Afgelopen';
  static const String endingIn       = 'Eindigt over';
  static const String upcoming       = 'Binnenkort';

  // ── Auction Detail ─────────────────────────────────────
  static const String description    = 'Beschrijving';
  static const String bidHistory     = 'Biedingen';
  static const String placeBid       = 'Bied';
  static const String bidNow         = 'Bied nu';
  static const String setAlarm       = 'Stel alarm in';
  static const String alarmSet       = 'Alarm ingesteld ✓';
  static const String alarmRemove    = 'Alarm verwijderen';
  static const String shareAuction   = 'Deel veiling';
  static const String addToWatchlist = 'Opslaan';
  static const String removeWatchlist = 'Verwijder uit opgeslagen';
  static const String noBids         = 'Nog geen biedingen — wees de eerste!';
  static const String bidPlaced      = 'Bod geplaatst! 🎉';
  static const String bidFailed      = 'Bod mislukt';
  static const String outbid         = 'Je bent overboden!';
  static const String outbidMessage  = 'Iemand heeft een hoger bod geplaatst. Bied opnieuw!';
  static const String bidTooLow      = 'Je bod is te laag. Minimum: ';
  static const String auctionEnded   = 'Deze veiling is al afgelopen';
  static const String youWon         = 'Gefeliciteerd! Je hebt gewonnen 🎉';
  static const String youLost        = 'Helaas, je hebt deze veiling niet gewonnen';

  // ── My Auctions ────────────────────────────────────────
  static const String myAuctions        = 'Mijn veilingen';
  static const String active            = 'Actief';
  static const String won               = 'Gewonnen';
  static const String payNow            = 'Betalen';
  static const String saved             = 'Opgeslagen';
  static const String noActive          = 'Geen actieve biedingen';
  static const String noActiveSub       = 'Ga bieden op een veiling om hem hier te zien';
  static const String noWon             = 'Nog niets gewonnen';
  static const String noWonSub          = 'Bid op veilingen om ze te winnen!';
  static const String noPending         = 'Geen openstaande betalingen';
  static const String noSaved           = 'Geen opgeslagen veilingen';
  static const String noSavedSub        = 'Sla veilingen op om ze hier terug te vinden';
  static const String pendingPaymentWarning = 'Je hebt gewonnen veilingen die nog betaald moeten worden!';
  static const String payBeforeExpiry   = 'Betaal voor de deadline om je aankoop te bevestigen';

  // ── Payment ────────────────────────────────────────────
  static const String pay              = 'Betalen';
  static const String paymentTitle     = 'Betaling';
  static const String paymentSuccess   = 'Betaling geslaagd! 🎉';
  static const String paymentFailed    = 'Betaling mislukt';
  static const String paymentPending   = 'Betaling in behandeling…';
  static const String paymentCancelled = 'Betaling geannuleerd';
  static const String securePayment    = 'Veilig betalen met iDEAL / creditcard';
  static const String totalAmount      = 'Totaalbedrag';
  static const String orderNumber      = 'Ordernummer';

  // ── Vouchers / Tickets ─────────────────────────────────
  static const String myVoucher        = 'Mijn voucher';
  static const String myVouchers       = 'Mijn vouchers';
  static const String voucherCode      = 'Vouchercode';
  static const String validUntil       = 'Geldig t/m';
  static const String expired          = 'Verlopen';
  static const String usedLabel        = 'Gebruikt';
  static const String download         = 'Downloaden';
  static const String showQr           = 'Toon deze QR-code bij het inchecken aan de medewerker';
  static const String voucherValid     = 'Voucher geldig';
  static const String voucherExpired   = 'Voucher verlopen';
  static const String noVouchers       = 'Geen vouchers gevonden';

  // ── Scratch Card ───────────────────────────────────────
  static const String scratchCard      = 'Kraskaart';
  static const String scratchToReveal  = 'Kras de kaart om je prijs te onthullen!';
  static const String shareForExtra    = 'Deel de app voor een extra kraskaart';
  static const String congratulations  = 'Gefeliciteerd!';
  static const String youWonPrize      = 'Je hebt gewonnen';
  static const String streakTitle      = 'Dagelijkse streak';
  static const String streakDay        = 'dag';
  static const String streakDays       = 'dagen';
  static const String comeBackTomorrow = 'Kom morgen terug voor een nieuwe kraskaart';
  static const String claimPrize       = 'Prijs claimen';
  static const String prizeAlreadyClaimed = 'Prijs al geclaimed';

  // ── Profile ────────────────────────────────────────────
  static const String profile          = 'Profiel';
  static const String editProfile      = 'Profiel bewerken';
  static const String settings         = 'Instellingen';
  static const String notifications    = 'Meldingen';
  static const String darkMode         = 'Donkere modus';
  static const String language         = 'Taal';
  static const String help             = 'Help & Support';
  static const String about            = 'Over ons';
  static const String privacyPolicy    = 'Privacybeleid';
  static const String termsOfService   = 'Gebruiksvoorwaarden';
  static const String deleteAccount    = 'Account verwijderen';
  static const String deleteConfirm    = 'Weet je zeker dat je je account wilt verwijderen?';

  // ── Search ─────────────────────────────────────────────
  static const String searchHint       = 'Zoek op veiling, locatie…';
  static const String noResults        = 'Geen resultaten gevonden';
  static const String noResultsSub     = 'Probeer een andere zoekterm';
  static const String recentSearches   = 'Recente zoekopdrachten';
  static const String clearHistory     = 'Geschiedenis wissen';

  // ── Notifications ──────────────────────────────────────
  static const String notificationsTitle = 'Meldingen';
  static const String markAllRead        = 'Alles lezen';
  static const String noNotifications    = 'Geen meldingen';

  // ── Errors & Feedback ──────────────────────────────────
  static const String somethingWrong   = 'Er is iets misgegaan';
  static const String noInternet       = 'Geen internetverbinding';
  static const String tryAgain         = 'Probeer opnieuw';
  static const String loading          = 'Laden…';
  static const String cancel           = 'Annuleren';
  static const String confirm          = 'Bevestigen';
  static const String ok               = 'OK';
  static const String yes              = 'Ja';
  static const String no               = 'Nee';
  static const String save             = 'Opslaan';
  static const String close            = 'Sluiten';
  static const String back             = 'Terug';
  static const String next             = 'Volgende';
  static const String done             = 'Klaar';
  static const String submit           = 'Versturen';

  // ── Firebase error messages ────────────────────────────
  static const String errUserNotFound   = 'Geen account gevonden met dit e-mailadres';
  static const String errWrongPassword  = 'Onjuist wachtwoord. Probeer het opnieuw';
  static const String errEmailInUse     = 'Er bestaat al een account met dit e-mailadres';
  static const String errWeakPassword   = 'Wachtwoord is te zwak (minimaal 6 tekens)';
  static const String errInvalidEmail   = 'Ongeldig e-mailadres';
  static const String errNetworkRequest = 'Netwerkfout. Controleer je internetverbinding';
  static const String errTooManyRequests = 'Te veel pogingen. Probeer het later opnieuw';
  static const String errGeneral        = 'Er is iets misgegaan. Probeer opnieuw';
}
