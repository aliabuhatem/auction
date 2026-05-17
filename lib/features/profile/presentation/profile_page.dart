import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../../app/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import 'bloc/locale_bloc.dart';
import '../../../app/app.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryRed, Color(0xFFc1121f)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    final user = state is AuthAuthenticated ? state.user : null;

                    String getInitial() {
                      final name = user?.displayName;
                      if (name == null || name.trim().isEmpty) return 'G';
                      return name.trim()[0].toUpperCase();
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                          child: (user?.avatarUrl == null)
                              ? Text(
                                  getInitial(),
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(user?.displayName ?? 'Gebruiker',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _section('Account', [
                  _tile(Icons.manage_accounts_outlined, AppStrings.editProfile(context),
                      () => context.push(AppRoutes.profileSettings)),
                  _tile(Icons.account_balance_wallet_outlined, 'Wallet & tegoed',
                      () => context.push(AppRoutes.wallet)),
                  _tile(Icons.person_add_outlined, 'Vrienden uitnodigen',
                      () => context.push(AppRoutes.referral)),
                  _tile(Icons.notifications_outlined, AppStrings.notifications(context),
                      () => context.push(AppRoutes.notifications)),
                  _tile(Icons.dark_mode_outlined, AppStrings.darkMode(context),
                      () => ThemeModeNotifier.of(context)?.toggleTheme()),
                  _tile(Icons.language, AppStrings.language(context), () => _showLanguageDialog(context)),
                ]),
                _section('Meer', [
                  _tile(Icons.help_outline, AppStrings.help(context), () => _showHelp(context)),
                  _tile(Icons.info_outline, AppStrings.about(context), () => _showAbout(context)),
                ]),
                _section('Account beheer', [
                  _tile(Icons.logout, AppStrings.logout(context), () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  }, color: Colors.red),
                  _tile(Icons.delete_outline, AppStrings.deleteAccount(context),
                      () => _deleteAccount(context),
                      color: Colors.red),
                ]),
                const SizedBox(height: 32),
                const Text('Vakantieveilingen v1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Heb je een vraag of probleem?', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Row(children: [
              Icon(Icons.email_outlined, size: 18, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text('support@vakantieveilingen.nl'),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.schedule_outlined, size: 18, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text('Ma–Vr 09:00–17:00'),
            ]),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Sluiten')),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Vakantieveilingen',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.gavel, color: Colors.white, size: 28),
      ),
      children: const [
        Text('Bied mee op exclusieve vakanties, wellness-arrangementen en meer. Elke dag nieuwe veilingen!'),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Account verwijderen'),
        content: const Text(
          'Weet je zeker dat je je account permanent wilt verwijderen? Al je data, biedingen en vouchers worden verwijderd. Dit kan niet ongedaan worden gemaakt.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuleren')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwijderen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (context.mounted) {
        context.read<AuthBloc>().add(LogoutRequested());
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log opnieuw in om je account te verwijderen.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Fout'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showLanguageDialog(BuildContext pageContext) {
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.language(pageContext)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(pageContext, dialogContext, 'Nederlands', const Locale('nl', 'NL')),
            _languageOption(pageContext, dialogContext, 'English', const Locale('en', 'US')),
            _languageOption(pageContext, dialogContext, 'العربية', const Locale('ar', 'SA')),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext pageContext, BuildContext dialogContext, String name, Locale locale) {
    final currentLocale = pageContext.read<LocaleBloc>().state.locale;
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryRed) : null,
      onTap: () {
        pageContext.read<LocaleBloc>().add(ChangeLocale(locale));
        Navigator.pop(dialogContext);
      },
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback? onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
