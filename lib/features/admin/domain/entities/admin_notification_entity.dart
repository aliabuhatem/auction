import 'package:equatable/equatable.dart';

class AdminNotificationEntity extends Equatable {
  final String    id;
  final String    title;
  final String    body;
  final String    target;
  final String?   targetUserId;
  final String    status;
  final int       sentCount;
  final String    sentBy;
  final DateTime  createdAt;
  final DateTime? scheduledFor;

  const AdminNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.targetUserId,
    required this.status,
    required this.sentCount,
    required this.sentBy,
    required this.createdAt,
    this.scheduledFor,
  });

  bool get isSentToAll => target == 'all';
  bool get isSent      => status == 'sent';
  bool get isScheduled => status == 'scheduled';

  @override
  List<Object?> get props => [
        id, title, body, target, targetUserId,
        status, sentCount, sentBy, createdAt, scheduledFor,
      ];
}
