import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/core/injections/get_it.dart';
import 'package:mobile/models/chat/recent_chat.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile/core/network/api_endpoints.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late IO.Socket _socket;
  bool _connected = false;

final _notificationsPlugin = getIt<FlutterLocalNotificationsPlugin>();

  // Streams
  final StreamController<dynamic> _newMessageController = StreamController.broadcast();
  final StreamController<void> _typingController = StreamController.broadcast();
  final StreamController<void> _stopTypingController = StreamController.broadcast();

  final StreamController<List<RecentChat>> _recentChatUpdateController =
    StreamController.broadcast();



Stream<List<RecentChat>> get recentChatUpdateStream =>
    _recentChatUpdateController.stream;


  factory WebSocketService() => _instance;

  WebSocketService._internal();

  void connect(String userId) {
    if (_connected) return;

    _socket = IO.io(
      ApiEndpoints().socketServerUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath('/socket.io')
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      _connected = true;
      print('✅ Socket connected: ${_socket.id}');
    });

    _socket.onDisconnect((_) {
      _connected = false;
      print('❌ Socket disconnected');
    });

_socket.onAny((event, data) {
  print('🔄 Event: $event');
  print('📦 Data: $data');
});


    _socket.on('new_message', _newMessageController.add);
    _socket.on('typing', (_) => _typingController.add(null));
    _socket.on('stop_typing', (_) => _stopTypingController.add(null));
     _socket.on("recent_chat_update", (data) {
      print("Hell, received recent chat update: $data");
      final List<RecentChat> recentChats = (data as List)
          .map((item) => RecentChat.fromJson(item))
          .toList();

    _recentChatUpdateController.add(recentChats);
  });

    _socket.onConnectError((err) => print('⚠️ Connect error: $err'));
    _socket.onError((err) => print('🔥 Socket error: $err'));
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _socket.on( "new_notification", (data) {
      try {
        final notification = NotificationModel.fromJson(data);
        _showLocalNotification(notification);
      } catch (e) {
        print('❌ Failed to handle notification: $e');
      }
    });
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    final android = AndroidNotificationDetails(
      'your_channel_id',
      'App Notifications',
      channelDescription: 'Notifications from app backend',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iOS = DarwinNotificationDetails();

    final platformDetails = NotificationDetails(android: android, iOS: iOS);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id
      notification.senders[0].firstName,
      notification.text,
      platformDetails,
      payload: jsonEncode(notification.toJson()),
    );
  }

  // Room logic
  void joinRoom(String roomId) => _socket.emit('join_room', roomId);
  void startTyping(String roomId) => _socket.emit('typing', roomId);
  void stopTyping(String roomId) => _socket.emit('stop_typing', roomId);

  // Streams
  Stream<dynamic> get newMessageStream => _newMessageController.stream;
  Stream<void> get typingStream => _typingController.stream;
  Stream<void> get stopTypingStream => _stopTypingController.stream;

  

  void dispose() {
    _newMessageController.close();
    _typingController.close();
    _stopTypingController.close();
    _recentChatUpdateController.close();
    _socket.dispose();
  }
}
