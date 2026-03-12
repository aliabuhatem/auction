class DashboardStatsEntity {
  final int    totalAuctions;
  final int    liveAuctions;
  final int    totalUsers;
  final int    todayBids;
  final double totalRevenue;
  final int    pendingPayments;
  final List<ChartPoint> bidChart;
  final List<ChartPoint> revenueChart;
  final List<RecentBidItem> recentBids;
  final List<EndingSoonItem> endingSoon;

  const DashboardStatsEntity({
    required this.totalAuctions,
    required this.liveAuctions,
    required this.totalUsers,
    required this.todayBids,
    required this.totalRevenue,
    required this.pendingPayments,
    required this.bidChart,
    required this.revenueChart,
    required this.recentBids,
    required this.endingSoon,
  });
}

class ChartPoint {
  final String label;
  final double value;
  const ChartPoint(this.label, this.value);
}

class RecentBidItem {
  final String userId;
  final String userName;
  final String auctionId;
  final String auctionTitle;
  final double amount;
  final DateTime createdAt;
  const RecentBidItem({
    required this.userId,
    required this.userName,
    required this.auctionId,
    required this.auctionTitle,
    required this.amount,
    required this.createdAt,
  });
}

class EndingSoonItem {
  final String   id;
  final String   title;
  final int      bidCount;
  final double   currentBid;
  final DateTime endsAt;
  const EndingSoonItem({
    required this.id,
    required this.title,
    required this.bidCount,
    required this.currentBid,
    required this.endsAt,
  });
}
