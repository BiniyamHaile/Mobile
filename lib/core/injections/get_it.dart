import 'package:get_it/get_it.dart';
import 'package:mobile/services/socket/websocket-service.dart';

final getIt = GetIt.instance;



void setupServiceLocator() {
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());
}
