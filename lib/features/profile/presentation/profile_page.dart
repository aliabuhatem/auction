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
                        Text(user?.displayName ?? AppStrings.defaultUser(ctx),
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
                _section(context, AppStrings.sectionAccount(context), [
                  _tile(context, Icons.manage_accounts_outlined, AppStrings.editProfile(context),
                      () => context.push(AppRoutes.profileSettings)),
                  _tile(context, Icons.account_balance_wallet_outlined, AppStrings.walletAndCredit(context),
                      () => context.push(AppRoutes.wallet)),
                  _tile(context, Icons.person_add_outlined, AppStrings.inviteFriends(context),
                      () => context.push(AppRoutes.referral)),
                  _tile(context, Icons.notifications_outlined, AppStrings.notifications(context),
                      () => context.push(AppRoutes.notifications)),
                  _tile(context, Icons.dark_mode_outlined, AppStrings.darkMode(context),
                      () => ThemeModeNotifier.of(context)?.toggleTheme()),
                  _tile(context, Icons.language, AppStrings.language(context), () => _showLanguageDialog(context)),
                ]),
                _section(context, AppStrings.sectionMore(context), [
                  _tile(context, Icons.help_outline, AppStrings.help(context), () => _showHelp(context)),
                  _tile(context, Icons.info_outline, AppStrings.about(context), () => _showAbout(context)),
                ]),
                _section(context, AppStrings.sectionAccountManage(context), [
                  _tile(context, Icons.logout, AppStrings.logout(context), () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  }, color: Colors.red),
                  _tile(context, Icons.delete_outline, AppStrings.deleteAccount(context),
                      () => _deleteAccount(context),
                      color: Colors.red),
                ]),
                const SizedBox(height: 32),
                Text('${AppStrings.appName(context)} v1.0.0',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
        title: Text(AppStrings.help(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.helpQuestion(context),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Row(children: [
              Icon(Icons.email_outlined, size: 18, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text('support@vakantieveilingen.nl'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule_outlined, size: 18, color: AppColors.primaryRed),
              const SizedBox(width: 8),
              Text(AppStrings.supportHours(context)),
            ]),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.close(context))),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName(context),
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryRed, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.gavel, color: Colors.white, size: 28),
      ),
      children: [
        Text(AppStrings.aboutDesc(context)),
      ],
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAccount(context)),
        content: Text(AppStrings.deleteAccountConfirmMsg(context)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppStrings.cancel(context))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete(context),
                style: const TextStyle(color: Colors.white)),
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
            SnackBar(
              content: Text(AppStrings.reloginToDeleteMsg(context)),
              backgroundColor: AppColors.warning,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? AppStrings.saveFailed(context)), backgroundColor: AppColors.error),
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
            _languageOption(pageContext, dialogContext, AppStrings.langNl(pageContext), const Locale('nl', 'NL')),
            _languageOption(pageContext, dialogContext, AppStrings.langEn(pageContext), const Locale('en', 'US')),
            _languageOption(pageContext, dialogContext, AppStrings.langAr(pageContext), const Locale('ar', 'SA')),
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

  Widget _section(BuildContext context, String title, List<Widget> tiles) {
    final surface = Theme.of(context).colorScheme.surface;
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
            color: surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback? onTap, {Color? color}) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface, size: 22),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
