import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';

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
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryRed, Color(0xFFc1121f)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    final user = state is AuthAuthenticated ? state.user : null;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                          child: user?.avatarUrl == null ? Text(
                            (user?.displayName ?? 'G').substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryRed),
                          ) : null,
                        ),
                        const SizedBox(height: 12),
                        Text(user?.displayName ?? 'Gebruiker', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  _tile(Icons.edit, AppStrings.editProfile, () {}),
                  _tile(Icons.notifications_outlined, AppStrings.notifications, () {}),
                  _tile(Icons.dark_mode_outlined, AppStrings.darkMode, () {}),
                  _tile(Icons.language, AppStrings.language, () {}),
                ]),
                _section('Meer', [
                  _tile(Icons.help_outline, AppStrings.help, () {}),
                  _tile(Icons.info_outline, AppStrings.about, () {}),
                ]),
                _section('Account beheer', [
                  _tile(Icons.logout, AppStrings.logout, () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  }, color: Colors.red),
                  _tile(Icons.delete_outline, AppStrings.deleteAccount, () {}, color: Colors.red),
                ]),
                const SizedBox(height: 32),
                const Text('Vakantieveilingen v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(title, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
