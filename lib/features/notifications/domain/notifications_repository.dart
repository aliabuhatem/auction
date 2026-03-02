abstract class NotificationsRepository {
  Future<void> initialize();
  Future<void> setAuctionAlarm(String auctionId);
  Future<void> removeAuctionAlarm(String auctionId);
}
