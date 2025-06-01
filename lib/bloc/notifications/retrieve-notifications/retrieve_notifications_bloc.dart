import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:mobile/services/api/notification/notification-service.dart';

part 'retrieve_notifications_event.dart';
part 'retrieve_notifications_state.dart';

class RetrieveNotificationsBloc
    extends Bloc<RetrieveNotificationsEvent, RetrieveNotificationsState> {
  RetrieveNotificationsBloc() : super(RetrieveNotificationsInitial()) {
    on<RetrieveNotifications>(_handleRetrieveNotifications);
    on<ReadAllNotifications>(_handleReadAllNotifications);
  }

  Future<void> _handleRetrieveNotifications(
    RetrieveNotifications event,
    Emitter<RetrieveNotificationsState> emit,
  ) async {
    final notificationService = NotificationApiService();
    emit(RetrieveNotificationsLoading());

    try {
      final notifications = await notificationService.retrieveNotifications();
      emit(RetrieveNotificationsLoaded(notifications));
    } catch (e) {
      emit(RetrieveNotificationsError(e.toString()));
    }
  }

  Future<void> _handleReadAllNotifications(
    ReadAllNotifications event,
    Emitter<RetrieveNotificationsState> emit,
  ) async {
    try {
      if (state is RetrieveNotificationsLoaded) {
        final notifications =
            (state as RetrieveNotificationsLoaded).notifications;
        final updatedNotifications = notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        emit(RetrieveNotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(RetrieveNotificationsError(e.toString()));
    }
  }
}
