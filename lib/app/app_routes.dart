// Standalone route constants — no feature imports so any file can import this
// without creating circular dependencies.
class AppRoutes {
  AppRoutes._();

  static const splash          = '/';
  static const onboarding      = '/onboarding';
  static const login           = '/auth/login';
  static const register        = '/auth/register';
  static const home            = '/home';
  static const search          = '/search';
  static const auctionDetail   = '/auction/:id';
  // Nested under /home — path is relative 'category' → full path '/home/category'
  static const category        = '/home/category';
  static const myAuctions      = '/my-auctions';
  static const scratchCard     = '/scratch-card';
  static const tickets         = '/tickets';
  static const voucherDetail   = '/tickets/:voucherId';
  static const profile         = '/profile';
  static const profileSettings = '/profile/settings';
  static const wallet          = '/wallet';
  static const referral        = '/referral';
  static const notifications   = '/notifications';
  // IMPORTANT: paymentSuccess MUST be declared before payment in the route list
  // to prevent 'success' being captured as the :orderId parameter.
  static const paymentSuccess  = '/payment/success';
  static const payment         = '/payment/:orderId';

  // Admin
  static const adminLogin          = '/admin/login';
  static const adminDashboard      = '/admin/dashboard';
  static const adminAuctions       = '/admin/auctions';
  static const adminAuctionNew     = '/admin/auctions/new';
  static const adminAuctionEdit    = '/admin/auctions/:id/edit';
  static const adminProducts       = '/admin/products';
  static const adminProductNew     = '/admin/products/new';
  static const adminProductEdit    = '/admin/products/:id/edit';
  static const adminUsers          = '/admin/users';
  static const adminBids           = '/admin/bids';
  static const adminOrders         = '/admin/orders';
  static const adminVouchers       = '/admin/vouchers';
  static const adminNotifications  = '/admin/notifications';
  static const adminSettings       = '/admin/settings';

  static String auctionDetailPath(String id)    => '/auction/$id';
  static String voucherDetailPath(String id)    => '/tickets/$id';
  static String paymentPath(String orderId)     => '/payment/$orderId';
  static String adminAuctionEditPath(String id) => '/admin/auctions/$id/edit';
  static String adminProductEditPath(String id) => '/admin/products/$id/edit';
}
