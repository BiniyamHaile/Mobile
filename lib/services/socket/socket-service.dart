import 'package:mobile/common/constants.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/services/utls/header_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
class SocketService {
  final ApiEndpoints apiEndpoints = ApiEndpoints();
  // final SharedPreferences prefs;

  late io.Socket _socket;
  String? _accessToken;
  bool _isInitialized = false;

  factory SocketService() =>
      SocketService._internal();

  SocketService._internal();

  
  Future<void> initialize() async {
    final String? bearerToken = _getAccessToken();
    if (bearerToken == null) {
      return;
    }

    if (_isInitialized) {
      updateAccessToken(bearerToken);
      return;
    }

    _accessToken = bearerToken;

    _socket = io.io(
      apiEndpoints.socketServerUrl,
      io.OptionBuilder()
          .setTransports([Constants.webSocket])
          .disableAutoConnect()
          .setExtraHeaders(
              HeaderUtils.createAuthorizationHeaders(accessToken: _accessToken))
          .build(),
    );

    _socket.connect();

    _initializeListeners();

    _isInitialized = true;
  }

  void updateAccessToken(String newToken) {
    if (_accessToken != newToken) {
      _accessToken = newToken;

      if (_socket.connected) {
        _socket.disconnect();
      }

      _socket.io.options?[Constants.extraHeaders] =
          HeaderUtils.createAuthorizationHeaders(accessToken: _accessToken);
      _socket.connect();

      _initializeListeners();
    }
  }

  String? _getAccessToken() {
    // return prefs.getString(Constants.accessToken);
  }

  
  void dispose() {
    _socket.clearListeners();
    if (_socket.connected) {
      _socket.disconnect();
      _socket.dispose();
    }
  }

  void connect() {
    if (!_socket.connected) {
      _socket.connect();
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  
  void emit(String event, data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    }
  }

  void attachListeners({
    Function(dynamic p1)? onConnect,
    Function(dynamic p1)? onDisconnect,
    Function(dynamic p1)? onConnectError,
    Function(dynamic p1)? onError,
    Map<String, Function>? events,
  }) {
    if (onConnect != null) {
      _onConnectListeners.add(onConnect);
    }

    if (onDisconnect != null) {
      _onDisconnectListeners.add(onDisconnect);
    }

    if (onConnectError != null) {
      _onConnectErrorListeners.add(onConnectError);
    }

    if (onError != null) {
      _onErrorListeners.add(onError);
    }

    if (events != null) {
      for (var entry in events.entries) {
        final event = entry.key;
        final listener = entry.value;

        if (_onEventListeners.containsKey(event)) {
          final listeners = _onEventListeners[event];
          if (listeners != null) {
            listeners.add(listener);
          } else {
            _onEventListeners[event] = [listener];
          }
        } else {
          _onEventListeners[event] = [listener];
        }
      }
    }

    if (_isInitialized) {
      _initializeListeners();
    }
  }

  final _onConnectListeners = <Function>[];
  final _onDisconnectListeners = <Function>[];
  final _onConnectErrorListeners = <Function>[];
  final _onErrorListeners = <Function>[];
  final _onEventListeners = <String, List<Function>>{};

  void _initializeListeners() {
    _socket.onConnect((data) {
      for (var listener in _onConnectListeners) {
        listener(data);
      }
      _onConnectListeners.clear();
    });

    _socket.onDisconnect((data) {
      for (var listener in _onDisconnectListeners) {
        listener(data);
      }
      _onDisconnectListeners.clear();
    });

    _socket.onConnectError((err) {
      for (var listener in _onConnectErrorListeners) {
        listener(err);
      }
      _onConnectErrorListeners.clear();
    });

    _socket.onError((err) {
      for (var listener in _onErrorListeners) {
        listener(err);
      }
      _onErrorListeners.clear();
    });

    for (var entry in _onEventListeners.entries) {
      final event = entry.key;
      final listeners = entry.value;

      _socket.on(event, (data) {
        for (var listener in listeners) {
          listener(data);
        }
      });
    }
    _onEventListeners.clear();
  }
}
