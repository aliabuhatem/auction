import 'package:flutter/material.dart';

class AppStrings {
  AppStrings._();

  static String get(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') return _ar[key] ?? _en[key] ?? key;
    if (locale == 'en') return _en[key] ?? _nl[key] ?? key;
    return _nl[key] ?? key;
  }

  // App
  static String appName(BuildContext context) => get(context, 'appName');
  static String tagline(BuildContext context) => get(context, 'tagline');
  
  // Auth
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

  // Navigation & Tabs
  static String navHome(BuildContext context) => get(context, 'navHome');
  static String myAuctions(BuildContext context) => get(context, 'myAuctions');
  static String active(BuildContext context) => get(context, 'active');
  static String won(BuildContext context) => get(context, 'won');
  static String payNow(BuildContext context) => get(context, 'payNow');
  static String saved(BuildContext context) => get(context, 'saved');
  
  // Home & Categories
  static String all(BuildContext context) => get(context, 'all');
  static String allAuctions(BuildContext context) => get(context, 'allAuctions');
  static String endingSoon(BuildContext context) => get(context, 'endingSoon');
  static String catVacation(BuildContext context) => get(context, 'catVacation');
  static String catBeauty(BuildContext context) => get(context, 'catBeauty');
  static String catSauna(BuildContext context) => get(context, 'catSauna');
  static String catFood(BuildContext context) => get(context, 'catFood');
  static String catExperiences(BuildContext context) => get(context, 'catExperiences');
  static String catProducts(BuildContext context) => get(context, 'catProducts');
  static String catSports(BuildContext context) => get(context, 'catSports');
  static String catWellness(BuildContext context) => get(context, 'catWellness');
  static String catDayTrips(BuildContext context) => get(context, 'catDayTrips');

  // Scratch Card
  static String scratchCard(BuildContext context) => get(context, 'scratchCard');
  static String scratchToReveal(BuildContext context) => get(context, 'scratchToReveal');
  static String shareForExtra(BuildContext context) => get(context, 'shareForExtra');
  static String congratulations(BuildContext context) => get(context, 'congratulations');
  static String comeBackTomorrow(BuildContext context) => get(context, 'comeBackTomorrow');
  static String streakTitle(BuildContext context) => get(context, 'streakTitle');
  static String claimPrize(BuildContext context) => get(context, 'claimPrize');

  // Profile
  static String profile(BuildContext context) => get(context, 'profile');
  static String editProfile(BuildContext context) => get(context, 'editProfile');
  static String notifications(BuildContext context) => get(context, 'notifications');
  static String darkMode(BuildContext context) => get(context, 'darkMode');
  static String language(BuildContext context) => get(context, 'language');
  static String help(BuildContext context) => get(context, 'help');
  static String about(BuildContext context) => get(context, 'about');
  static String deleteAccount(BuildContext context) => get(context, 'deleteAccount');

  // Vouchers
  static String myVoucher(BuildContext context) => get(context, 'myVoucher');
  static String voucherCode(BuildContext context) => get(context, 'voucherCode');
  static String showQr(BuildContext context) => get(context, 'showQr');
  
  // Status & Feedback
  static String noActive(BuildContext context) => get(context, 'noActive');
  static String noWon(BuildContext context) => get(context, 'noWon');
  static String noSaved(BuildContext context) => get(context, 'noSaved');
  static String noPending(BuildContext context) => get(context, 'noPending');
  static String pendingPaymentWarning(BuildContext context) => get(context, 'pendingPaymentWarning');
  static String tryAgain(BuildContext context) => get(context, 'tryAgain');

  static const Map<String, String> _nl = {
    'appName': 'Vakantieveilingen',
    'tagline': 'Bied op exclusieve aanbiedingen',
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
    'navHome': 'Home',
    'myAuctions': 'Mijn veilingen',
    'active': 'Actief',
    'won': 'Gewonnen',
    'payNow': 'Betalen',
    'saved': 'Opgeslagen',
    'all': 'Alles',
    'allAuctions': 'Alle veilingen',
    'endingSoon': 'Loopt bijna af ⏳',
    'catVacation': 'Vakanties',
    'catBeauty': 'Beauty',
    'catSauna': 'Sauna',
    'catFood': 'Eten & drinken',
    'catExperiences': 'Uitjes',
    'catProducts': 'Producten',
    'catSports': 'Sport',
    'catWellness': 'Wellness',
    'catDayTrips': 'Dagtrips',
    'scratchCard': 'Kraskaart',
    'scratchToReveal': 'Kras de kaart om je prijs te onthullen!',
    'shareForExtra': 'Deel de app voor een extra kraskaart',
    'congratulations': 'Gefeliciteerd!',
    'comeBackTomorrow': 'Kom morgen terug voor een nieuwe kraskaart',
    'streakTitle': 'Dagelijkse streak',
    'claimPrize': 'Prijs claimen',
    'profile': 'Profiel',
    'editProfile': 'Profiel bewerken',
    'notifications': 'Meldingen',
    'darkMode': 'Donkere modus',
    'language': 'Taal',
    'help': 'Help & Support',
    'about': 'Over ons',
    'deleteAccount': 'Account verwijderen',
    'myVoucher': 'Mijn voucher',
    'voucherCode': 'Vouchercode',
    'showQr': 'Toon deze QR-code bij het inchecken',
    'noActive': 'Geen actieve biedingen',
    'noWon': 'Nog niets gewonnen',
    'noSaved': 'Geen opgeslagen veilingen',
    'noPending': 'Geen openstaande betalingen',
    'pendingPaymentWarning': 'Je hebt gewonnen veilingen die nog betaald moeten worden!',
    'tryAgain': 'Probeer opnieuw',
  };

  static const Map<String, String> _en = {
    'appName': 'Holiday Auctions',
    'tagline': 'Bid on exclusive deals',
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
    'navHome': 'Home',
    'myAuctions': 'My Auctions',
    'active': 'Active',
    'won': 'Won',
    'payNow': 'Pay Now',
    'saved': 'Saved',
    'all': 'All',
    'allAuctions': 'All Auctions',
    'endingSoon': 'Ending soon ⏳',
    'catVacation': 'Vacations',
    'catBeauty': 'Beauty',
    'catSauna': 'Sauna',
    'catFood': 'Food & Drink',
    'catExperiences': 'Trips',
    'catProducts': 'Products',
    'catSports': 'Sports',
    'catWellness': 'Wellness',
    'catDayTrips': 'Day Trips',
    'scratchCard': 'Scratch Card',
    'scratchToReveal': 'Scratch the card to reveal your prize!',
    'shareForExtra': 'Share the app for an extra scratch card',
    'congratulations': 'Congratulations!',
    'comeBackTomorrow': 'Come back tomorrow for a new scratch card',
    'streakTitle': 'Daily streak',
    'claimPrize': 'Claim Prize',
    'profile': 'Profile',
    'editProfile': 'Edit Profile',
    'notifications': 'Notifications',
    'darkMode': 'Dark Mode',
    'language': 'Language',
    'help': 'Help & Support',
    'about': 'About Us',
    'deleteAccount': 'Delete Account',
    'myVoucher': 'My Voucher',
    'voucherCode': 'Voucher Code',
    'showQr': 'Show this QR code at check-in',
    'noActive': 'No active bids',
    'noWon': 'Nothing won yet',
    'noSaved': 'No saved auctions',
    'noPending': 'No pending payments',
    'pendingPaymentWarning': 'You have won auctions that still need to be paid!',
    'tryAgain': 'Try again',
  };

  static const Map<String, String> _ar = {
    'appName': 'مزادات العطلات',
    'tagline': 'زايد على عروض حصرية',
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
    'navHome': 'الرئيسية',
    'myAuctions': 'مزاداتي',
    'active': 'نشط',
    'won': 'فزت بها',
    'payNow': 'ادفع الآن',
    'saved': 'المحفوظة',
    'all': 'الكل',
    'allAuctions': 'جميع المزادات',
    'endingSoon': 'تنتهي قريباً ⏳',
    'catVacation': 'عطلات',
    'catBeauty': 'جمال',
    'catSauna': 'ساونا',
    'catFood': 'طعام وشراب',
    'catExperiences': 'رحلات',
    'catProducts': 'منتجات',
    'catSports': 'رياضة',
    'catWellness': 'صحة',
    'catDayTrips': 'رحلات يومية',
    'scratchCard': 'بطاقة الحظ',
    'scratchToReveal': 'امسح البطاقة للكشف عن جائزتك!',
    'shareForExtra': 'شارك التطبيق للحصول على بطاقة إضافية',
    'congratulations': 'تهانينا!',
    'comeBackTomorrow': 'عد غداً للحصول على بطاقة جديدة',
    'streakTitle': 'التفاعل اليومي',
    'claimPrize': 'المطالبة بالجائزة',
    'profile': 'الملف الشخصي',
    'editProfile': 'تعديل الملف الشخصي',
    'notifications': 'التنبيهات',
    'darkMode': 'الوضع الليلي',
    'language': 'اللغة',
    'help': 'المساعدة والدعم',
    'about': 'من نحن',
    'deleteAccount': 'حذف الحساب',
    'myVoucher': 'قسيمتي',
    'voucherCode': 'رمز القسيمة',
    'showQr': 'أظهر رمز QR هذا عند تسجيل الوصول',
    'noActive': 'لا توجد مزايدات نشطة',
    'noWon': 'لم تفز بأي شيء بعد',
    'noSaved': 'لا توجد مزادات محفوظة',
    'noPending': 'لا توجد مدفوعات معلقة',
    'pendingPaymentWarning': 'لديك مزادات فزت بها ويجب دفعها!',
    'tryAgain': 'حاول مرة أخرى',
  };
}
