import 'package:mobile/core/injections/get_it.dart';
import 'package:mobile/services/socket/socket-service.dart';

class SocketInjection {

  void init() {
       getIt.registerLazySingleton<SocketService>(
        () => SocketService());
  }
}
