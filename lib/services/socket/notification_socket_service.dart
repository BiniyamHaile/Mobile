import 'dart:async';

import 'package:mobile/services/socket/socket-service.dart';


class NotificationSocketService{
  final SocketService socketService;

  NotificationSocketService({
    required this.socketService,
  }) {
    socketService.attachListeners(events: {
      'notification': _onNewNotificationReceived,
    });
  }

  final StreamController<int> _notificationStreamController =
      StreamController<int>.broadcast();

  Stream<int> get notificationStream => _notificationStreamController.stream;

  void _onNewNotificationReceived(Map<String, dynamic> data) {
    _notificationStreamController.add(1);
  }
}
