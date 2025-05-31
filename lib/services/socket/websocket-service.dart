import 'package:mobile/core/network/api_endpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  late IO.Socket socket;

  factory WebSocketService() => _instance;

  WebSocketService._internal();

void connect(String userId) {
  socket = IO.io(
    ApiEndpoints().socketServerUrl, // <-- Just the host & port
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .setPath('/socket.io') // <-- Match the backend's path
        .setQuery({'userId': userId})
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .build(),
  );

    socket.connect();

    socket.onAny( (event, data) {
      print('🔔 Event: $event, Data: $data');
    });

    // ✅ Log connection status
    socket.onConnect((_) {
      print('✅ Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    // ❗ Catch errors
    socket.onConnectError((data) {
      print('⚠️ Socket connect error: $data');
    });

    socket.onError((data) {
      print('🔥 Socket general error: $data');
    });

    socket.onReconnect((attempt) {
      print('🔄 Attempting to reconnect (#$attempt)...');
    });

    socket.onReconnectError((data) {
      print('🤕 Reconnect error: $data');
    });

    socket.onReconnectFailed((_) {
      print('💀 Reconnect failed after max attempts.');
    });
  }

  bool isConnected() => socket.connected;

  void joinRoom(String roomId) => socket.emit('join_room', roomId);
  void startTyping(String roomId) => socket.emit('typing', roomId);
  void stopTyping(String roomId) => socket.emit('stop_typing', roomId);

void onNewMessage(Function(dynamic) callback) {
  print("Setting up new message listener");
  socket.off('new_message'); // remove previous listener
  socket.on('new_message', callback);
}

  void onTyping(Function(dynamic) callback) =>
      socket.on('typing', callback);
  void onStopTyping(Function(dynamic) callback) =>
      socket.on('stop_typing', callback);
  void onRecentChatUpdate(Function(dynamic) callback) =>
      socket.on('recent_chat_update', callback);
}
