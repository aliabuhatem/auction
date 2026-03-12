import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';

// ── Auctions ──────────────────────────────────────────────────────────────────
import '../features/auctions/presentation/pages/home_page.dart';
import '../features/auctions/presentation/pages/auction_detail_page.dart';
import '../features/auctions/presentation/pages/category_page.dart';

// ── My Auctions ───────────────────────────────────────────────────────────────
import '../features/my_auctions/presentation/pages/my_auctions_page.dart';

// ── Scratch Card ──────────────────────────────────────────────────────────────
import '../features/scratch_card/presentation/pages/scratch_card_page.dart';

// ── Tickets / Vouchers ────────────────────────────────────────────────────────
import '../features/search/presentation/pages/search_page.dart';
import '../features/tickets/presentation/pages/tickets_page.dart';
import '../features/tickets/presentation/pages/voucher_page.dart';

// ── Profile ───────────────────────────────────────────────────────────────────
import '../features/profile/presentation/profile_page.dart';

// ── Notifications ─────────────────────────────────────────────────────────────
import '../features/notifications/presentation/notifications_page.dart';

// ── Admin ─────────────────────────────────────────────────────────────────────
import '../features/admin/admin_routes.dart';
import '../features/admin/presentation/pages/admin_login_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';

// ── Shell wrapper (bottom nav) ────────────────────────────────────────────────
import 'shell_scaffold.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route name constants
// ─────────────────────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const splash        = '/';
  static const login         = '/auth/login';
  static const register      = '/auth/register';
  static const home          = '/home';
  static const search        = '/search';
  static const auctionDetail = '/auction/:id';
  static const category      = '/category';
  static const myAuctions    = '/my-auctions';
  static const scratchCard   = '/scratch-card';
  static const tickets       = '/tickets';
  static const voucherDetail = '/tickets/:voucherId';
  static const profile       = '/profile';
  static const notifications = '/notifications';

  // Admin
  static const adminLogin     = '/admin/login';
  static const adminDashboard = '/admin/dashboard';

  /// Build a typed auction-detail path: '/auction/abc123'
  static String auctionDetailPath(String id) => '/auction/$id';

  /// Build a typed voucher-detail path: '/tickets/abc123'
  static String voucherDetailPath(String id) => '/tickets/$id';
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _rootNavigatorKey   = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey  = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey:     _rootNavigatorKey,
  initialLocation:  AppRoutes.adminLogin,
  debugLogDiagnostics: true,

  redirect: (BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final path      = state.matchedLocation;
    
    // 1. If we are on an admin path, don't let the main app's AuthBloc redirect us.
    // We handle admin auth separately.
    if (path.startsWith('/admin')) return null;

    // 2. If the user is an admin (e.g. email contains 'admin'), 
    // we might want to prevent them from seeing the user app.
    if (authState is AuthAuthenticated) {
      if (authState.user.email.contains('admin') && !path.startsWith('/admin')) {
         // Optionally redirect admins to dashboard if they hit the home page
         // return AppRoutes.adminDashboard; 
      }
    }

    final isOnAuth   = path.startsWith('/auth');
    final isOnSplash = path == AppRoutes.splash;

    if (authState is AuthLoading || authState is AuthInitial) {
      return isOnSplash ? null : AppRoutes.splash;
    }

    if (authState is AuthUnauthenticated) {
      return isOnAuth ? null : AppRoutes.login;
    }

    if (authState is AuthAuthenticated) {
      if (isOnAuth || isOnSplash) return AppRoutes.home;
    }

    return null;
  },

  refreshListenable: _AuthStateListenable(),

  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, __) => const RegisterPage(),
    ),
    
    // ── Admin Routes ──────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.adminLogin,
      builder: (context, state) => const AdminProviders(child: AdminLoginPage()),
    ),
    ShellRoute(
      builder: (context, state, child) => AdminProviders(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/auctions',
          builder: (_, __) => const AdminComingSoon(title: 'Veilingen Beheer', part: 4),
        ),
        GoRoute(
          path: '/admin/products',
          builder: (_, __) => const AdminComingSoon(title: 'Producten Beheer', part: 4),
        ),
        GoRoute(
          path: '/admin/users',
          builder: (_, __) => const AdminComingSoon(title: 'Gebruikers Beheer', part: 5),
        ),
        GoRoute(
          path: '/admin/bids',
          builder: (_, __) => const AdminComingSoon(title: 'Biedingen Overzicht', part: 4),
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (_, __) => const AdminComingSoon(title: 'Bestellingen & Betalingen', part: 5),
        ),
        GoRoute(
          path: '/admin/vouchers',
          builder: (_, __) => const AdminComingSoon(title: 'Voucher Beheer', part: 5),
        ),
        GoRoute(
          path: '/admin/notifications',
          builder: (_, __) => const AdminComingSoon(title: 'Admin Meldingen', part: 5),
        ),
        GoRoute(
          path: '/admin/settings',
          builder: (_, __) => const AdminComingSoon(title: 'Systeem Instellingen', part: 5),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.notifications,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.search,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => CustomTransitionPage(
        key:   state.pageKey,
        child: const SearchPage(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.auctionDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return AuctionDetailPage(auctionId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.voucherDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) {
        final voucherId = state.pathParameters['voucherId']!;
        return VoucherPage(voucherId: voucherId); 
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (_, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomePage(),
          routes: [
            GoRoute(
              path: 'category',
              builder: (_, state) => CategoryPage(
                category: state.extra != null
                    ? state.extra as dynamic
                    : null,
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.myAuctions,
          builder: (_, __) => const MyAuctionsPage(),
        ),
        GoRoute(
          path: AppRoutes.scratchCard,
          builder: (_, __) => const ScratchCardPage(),
        ),
        GoRoute(
          path: AppRoutes.tickets,
          builder: (_, __) => const TicketsPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfilePage(),
        ),
      ],
    ),
  ],

  errorBuilder: (_, state) => _ErrorPage(error: state.error),
);

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable();
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;
  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Pagina niet gevonden',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Terug naar home'),
            ),
          ],
        ),
      ),
    );
  }
}
