import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../../data/datasources/admin_notifications_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminNotificationsEvent extends Equatable {
  const AdminNotificationsEvent();
  @override List<Object?> get props => [];
}

class LoadAdminNotifications extends AdminNotificationsEvent {
  const LoadAdminNotifications();
}

class SendAdminNotification extends AdminNotificationsEvent {
  final String    title;
  final String    body;
  final bool      toAll;
  final String?   targetUserId;

  const SendAdminNotification({
    required this.title,
    required this.body,
    required this.toAll,
    this.targetUserId,
  });

  @override List<Object?> get props => [title, body, toAll, targetUserId];
}

class DeleteAdminNotification extends AdminNotificationsEvent {
  final String id;
  const DeleteAdminNotification(this.id);
  @override List<Object?> get props => [id];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminNotificationsState extends Equatable {
  const AdminNotificationsState();
  @override List<Object?> get props => [];
}

class AdminNotificationsInitial extends AdminNotificationsState {}
class AdminNotificationsLoading extends AdminNotificationsState {}
class AdminNotificationsSending extends AdminNotificationsState {
  final List<AdminNotificationEntity> notifications;
  const AdminNotificationsSending(this.notifications);
  @override List<Object?> get props => [notifications];
}

class AdminNotificationsError extends AdminNotificationsState {
  final String message;
  final List<AdminNotificationEntity> notifications;
  const AdminNotificationsError(this.message, [this.notifications = const []]);
  @override List<Object?> get props => [message, notifications];
}

class AdminNotificationsLoaded extends AdminNotificationsState {
  final List<AdminNotificationEntity> notifications;
  final bool justSent;

  const AdminNotificationsLoaded({
    required this.notifications,
    this.justSent = false,
  });

  AdminNotificationsLoaded copyWith({
    List<AdminNotificationEntity>? notifications,
    bool? justSent,
  }) => AdminNotificationsLoaded(
    notifications: notifications ?? this.notifications,
    justSent:      justSent      ?? this.justSent,
  );

  @override List<Object?> get props => [notifications, justSent];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AdminNotificationsBloc
    extends Bloc<AdminNotificationsEvent, AdminNotificationsState> {
  final AdminNotificationsDatasource _ds;

  AdminNotificationsBloc(this._ds) : super(AdminNotificationsInitial()) {
    on<LoadAdminNotifications> (_onLoad);
    on<SendAdminNotification>  (_onSend);
    on<DeleteAdminNotification>(_onDelete);
  }

  Future<void> _onLoad(
      LoadAdminNotifications e, Emitter<AdminNotificationsState> emit) async {
    emit(AdminNotificationsLoading());
    try {
      final list = await _ds.getNotifications();
      emit(AdminNotificationsLoaded(notifications: list));
    } catch (e) {
      emit(AdminNotificationsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onSend(
      SendAdminNotification e, Emitter<AdminNotificationsState> emit) async {
    final current = state is AdminNotificationsLoaded
        ? (state as AdminNotificationsLoaded).notifications
        : <AdminNotificationEntity>[];
    emit(AdminNotificationsSending(current));
    try {
      await _ds.sendNotification(
        title:        e.title,
        body:         e.body,
        toAll:        e.toAll,
        targetUserId: e.targetUserId,
      );
      final list = await _ds.getNotifications();
      emit(AdminNotificationsLoaded(notifications: list, justSent: true));
    } catch (e) {
      emit(AdminNotificationsError(
          e.toString().replaceAll('Exception: ', ''), current));
    }
  }

  Future<void> _onDelete(
      DeleteAdminNotification e, Emitter<AdminNotificationsState> emit) async {
    if (state is! AdminNotificationsLoaded) return;
    final s = state as AdminNotificationsLoaded;
    try {
      await _ds.deleteNotification(e.id);
      emit(s.copyWith(
        notifications: s.notifications.where((n) => n.id != e.id).toList(),
      ));
    } catch (ex) {
      emit(AdminNotificationsError(
          ex.toString().replaceAll('Exception: ', ''), s.notifications));
    }
  }
}
