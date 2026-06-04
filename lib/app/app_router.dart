// lib/app/app_router.dart
export 'app_routes.dart';

import 'dart:async';
import 'app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../injection_container.dart' as di;

// ── Auth ──────────────────────────────────────────────────────────────────────
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';

// ── Auctions ──────────────────────────────────────────────────────────────────
import '../features/auctions/presentation/pages/home_page.dart';
import '../features/auctions/presentation/pages/auction_detail_page.dart';
import '../features/auctions/presentation/pages/category_page.dart';
import '../features/auctions/presentation/bloc/bidding_bloc.dart';

// ── My Auctions ───────────────────────────────────────────────────────────────
import '../features/my_auctions/presentation/pages/my_auctions_page.dart';

// ── Scratch Card ──────────────────────────────────────────────────────────────
import '../features/scratch_card/presentation/pages/scratch_card_page.dart';

// ── Tickets / Vouchers ────────────────────────────────────────────────────────
import '../features/search/presentation/pages/search_page.dart';
import '../features/tickets/presentation/pages/tickets_page.dart';
import '../features/tickets/presentation/pages/voucher_page.dart';

// ── Payment ───────────────────────────────────────────────────────────────────
import '../features/payment/presentation/pages/payment_page.dart';
import '../features/payment/presentation/pages/payment_success_page.dart';

// ── Profile ───────────────────────────────────────────────────────────────────
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/pages/account_settings_page.dart';
import '../features/profile/presentation/pages/wallet_page.dart';
import '../features/profile/presentation/pages/referral_page.dart';

// ── Notifications ─────────────────────────────────────────────────────────────
import '../features/notifications/presentation/notifications_page.dart';

// ── Admin ─────────────────────────────────────────────────────────────────────
import '../features/admin/admin_routes.dart';
import '../features/admin/presentation/pages/admin_login_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_auctions_page.dart';
import '../features/admin/presentation/pages/admin_auction_form_page.dart';
import '../features/admin/presentation/pages/admin_products_page.dart';
import '../features/admin/presentation/pages/admin_product_form_page.dart';
import '../features/admin/presentation/pages/admin_orders_page.dart';
import '../features/admin/presentation/pages/admin_vouchers_page.dart';
import '../features/admin/presentation/pages/admin_settings_page.dart';
import '../features/admin/presentation/pages/admin_users_page.dart';
import '../features/admin/presentation/pages/admin_bids_page.dart';
import '../features/admin/presentation/pages/admin_notifications_page.dart';
import '../features/admin/domain/entities/admin_auction_entity.dart';
import '../features/admin/domain/entities/admin_product_entity.dart';

// ── Shell wrapper (bottom nav) ────────────────────────────────────────────────
import 'shell_scaffold.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

// AppRoutes constants are defined in app_routes.dart and re-exported above.

// ─────────────────────────────────────────────────────────────────────────────
// Admin role cache — avoids a Firestore read on every admin route navigation.
// Reads from the `admins` collection (write-protected to super_admin only).
// Cache TTL: 5 minutes. Cleared on every Firebase auth state change.
// ─────────────────────────────────────────────────────────────────────────────
String?   _adminRoleCache;
String?   _adminRoleCacheUid;
DateTime? _adminRoleCacheTime;

void _clearAdminRoleCache() {
  _adminRoleCache     = null;
  _adminRoleCacheUid  = null;
  _adminRoleCacheTime = null;
}

Future<bool> _checkAdminAccess() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _clearAdminRoleCache();
    return false;
  }
  final now = DateTime.now();
  if (_adminRoleCacheUid == user.uid &&
      _adminRoleCache != null &&
      _adminRoleCacheTime != null &&
      now.difference(_adminRoleCacheTime!) < const Duration(minutes: 5)) {
    return _adminRoleCache == 'admin' || _adminRoleCache == 'super_admin';
  }
  try {
    // Read from `admins/{uid}` — only writable by super_admin, so users
    // cannot self-escalate by modifying their own `users/{uid}.role` field.
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();
    _adminRoleCache     = doc.exists ? (doc.data()?['role'] as String?) ?? '' : '';
    _adminRoleCacheUid  = user.uid;
    _adminRoleCacheTime = now;
    return _adminRoleCache == 'admin' || _adminRoleCache == 'super_admin';
  } catch (_) {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Refresh stream — notifies GoRouter whenever Firebase auth state changes so
// the redirect guard re-evaluates. Also clears the admin role cache on change.
// ─────────────────────────────────────────────────────────────────────────────
class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) {
      _clearAdminRoleCache();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _rootNavigatorKey  = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey:        _rootNavigatorKey,
  initialLocation:     kIsWeb ? AppRoutes.adminLogin : AppRoutes.splash,
  debugLogDiagnostics: true,

  refreshListenable: _GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  redirect: (BuildContext context, GoRouterState state) async {
    final path = state.matchedLocation;

    // ── Web: admin-only build ────────────────────────────────────────────────
    if (kIsWeb) {
      if (!path.startsWith('/admin')) return AppRoutes.adminLogin;
      if (path == AppRoutes.adminLogin) return null;
      if (!await _checkAdminAccess()) return AppRoutes.adminLogin;
      return null;
    }

    // ── Mobile: admin sub-paths also need a guard ────────────────────────────
    if (path.startsWith('/admin')) {
      if (path == AppRoutes.adminLogin) return null;
      if (!await _checkAdminAccess()) return AppRoutes.adminLogin;
      return null;
    }

    // ── Mobile auth logic ────────────────────────────────────────────────────
    final user           = FirebaseAuth.instance.currentUser;
    final isOnAuth       = path.startsWith('/auth');
    final isOnSplash     = path == AppRoutes.splash;
    final isOnOnboarding = path == AppRoutes.onboarding;

    if (user == null) {
      // Allow unauthenticated access only to auth pages, splash, and onboarding.
      if (isOnAuth || isOnSplash || isOnOnboarding) return null;
      return AppRoutes.login;
    }

    // Authenticated user on login/register/splash → send to correct destination.
    if (isOnAuth || isOnSplash) {
      final prefs          = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;
      return onboardingDone ? AppRoutes.home : AppRoutes.onboarding;
    }

    // Authenticated user on /onboarding or any other page → no redirect.
    return null;
  },

  routes: [
    // ── Splash ────────────────────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.splash,
      builder: (_, __) => const SplashPage(),
    ),

    // ── Onboarding ────────────────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.onboarding,
      builder: (_, __) => const OnboardingPage(),
    ),

    // ── Auth ──────────────────────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path:    AppRoutes.register,
      builder: (_, __) => const RegisterPage(),
    ),

    // ── Admin Routes ──────────────────────────────────────────────────────────
    GoRoute(
      path:    AppRoutes.adminLogin,
      builder: (context, state) =>
          const AdminProviders(child: AdminLoginPage()),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminProviders(child: child),
      routes: [
        GoRoute(
          path:    AppRoutes.adminDashboard,
          builder: (_, __) => const AdminDashboardPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminAuctions,
          builder: (_, __) => const AdminAuctionsPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminAuctionNew,
          builder: (_, __) => const AdminAuctionFormPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminAuctionEdit,
          builder: (_, state) => AdminAuctionFormPage(
            existing: state.extra as AdminAuctionEntity?,
          ),
        ),
        GoRoute(
          path:    AppRoutes.adminProducts,
          builder: (_, __) => const AdminProductsPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminProductNew,
          builder: (_, __) => const AdminProductFormPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminProductEdit,
          builder: (_, state) => AdminProductFormPage(
            existing: state.extra as AdminProductEntity?,
          ),
        ),
        GoRoute(
          path:    AppRoutes.adminUsers,
          builder: (_, __) => const AdminUsersPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminBids,
          builder: (_, __) => const AdminBidsPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminOrders,
          builder: (_, __) => const AdminOrdersPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminVouchers,
          builder: (_, __) => const AdminVouchersPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminNotifications,
          builder: (_, __) => const AdminNotificationsPage(),
        ),
        GoRoute(
          path:    AppRoutes.adminSettings,
          builder: (_, __) => const AdminSettingsPage(),
        ),
      ],
    ),

    // ── Standalone pages (overlay above the bottom-nav shell) ─────────────────
    GoRoute(
      path:               AppRoutes.notifications,
      parentNavigatorKey: _rootNavigatorKey,
      builder:            (_, __) => const NotificationsPage(),
    ),
    GoRoute(
      path:               AppRoutes.search,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => CustomTransitionPage(
        key:   state.pageKey,
        child: const SearchPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path:               AppRoutes.auctionDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => BlocProvider(
        create: (_) => di.sl<BiddingBloc>(),
        child: AuctionDetailPage(auctionId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path:               AppRoutes.voucherDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          VoucherPage(voucherId: state.pathParameters['voucherId']!),
    ),
    // paymentSuccess MUST appear before payment so '/payment/success' is not
    // captured as '/payment/:orderId' with orderId='success'.
    GoRoute(
      path:               AppRoutes.paymentSuccess,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentSuccessPage(
          orderId:      extra?['orderId']      as String? ?? '',
          voucherId:    extra?['voucherId']    as String?,
          auctionTitle: extra?['auctionTitle'] as String? ?? '',
          amount:       (extra?['amount']      as num?)?.toDouble() ?? 0,
        );
      },
    ),
    GoRoute(
      path:               AppRoutes.payment,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) =>
          PaymentPage(orderId: state.pathParameters['orderId']!),
    ),
    GoRoute(
      path:               AppRoutes.profileSettings,
      parentNavigatorKey: _rootNavigatorKey,
      builder:            (_, __) => const AccountSettingsPage(),
    ),
    GoRoute(
      path:               AppRoutes.wallet,
      parentNavigatorKey: _rootNavigatorKey,
      builder:            (_, __) => const WalletPage(),
    ),
    GoRoute(
      path:               AppRoutes.referral,
      parentNavigatorKey: _rootNavigatorKey,
      builder:            (_, __) => const ReferralPage(),
    ),

    // ── Bottom-nav shell ──────────────────────────────────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder:      (_, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path:    AppRoutes.home,
          builder: (_, __) => const HomePage(),
          routes: [
            GoRoute(
              path:    'category',
              builder: (_, state) => CategoryPage(
                category: state.extra as dynamic,
              ),
            ),
          ],
        ),
        GoRoute(
          path:    AppRoutes.myAuctions,
          builder: (_, __) => const MyAuctionsPage(),
        ),
        GoRoute(
          path:    AppRoutes.scratchCard,
          builder: (_, __) => const ScratchCardPage(),
        ),
        GoRoute(
          path:    AppRoutes.tickets,
          builder: (_, __) => const TicketsPage(),
        ),
        GoRoute(
          path:    AppRoutes.profile,
          builder: (_, __) => const ProfilePage(),
        ),
      ],
    ),
  ],

  errorBuilder: (_, state) => _ErrorPage(error: state.error),
);

// ─────────────────────────────────────────────────────────────────────────────
class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                AppStrings.pageNotFound(context),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(AppStrings.backToHome(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
