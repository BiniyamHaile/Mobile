part of 'retrieve_notifications_bloc.dart';

abstract class RetrieveNotificationsState {}

final class RetrieveNotificationsInitial extends RetrieveNotificationsState {}


final class RetrieveNotificationsLoading extends RetrieveNotificationsState {}

final class RetrieveNotificationsLoaded extends RetrieveNotificationsState {
  final List<NotificationModel> notifications;

  RetrieveNotificationsLoaded(this.notifications);
}


final class RetrieveNotificationsError extends RetrieveNotificationsState {
  final String error;
  RetrieveNotificationsError(this.error);
}
