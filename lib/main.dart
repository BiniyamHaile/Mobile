import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/bloc/chat/retrieve_messages/retrieve_messages_bloc.dart';
import 'package:mobile/bloc/chat/send_message/send_message_bloc.dart';
import 'package:mobile/bloc/notifications/retrieve-notifications/retrieve_notifications_bloc.dart';
import 'package:mobile/bloc/chat/recent_chat/recent_chat_bloc.dart';
import 'package:mobile/core/injections/get_it.dart';
import 'package:mobile/services/socket/websocket-service.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await _initNotifications();
  runApp(const App());
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification tapped with payload: ${response.payload}');
    },
  );

  // OPTIONAL: Immediately show a test notification when app starts
  await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notification',
    'This is a test message shown in foreground.',
    notificationDetails,
    payload: 'test_payload',
  );
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    getIt<WebSocketService>().connect("68361f8c48f4ac1ea297fe70");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthFormBloc()),
        BlocProvider(create: (_) => SignupBloc()),
        BlocProvider(create: (_) => RetrieveNotificationsBloc()),
        BlocProvider(create: (_) => RecentChatBloc()..add(LoadRecentChatsEvent())),
        BlocProvider(create: (_) => RetrieveMessagesBloc()),
        BlocProvider(create: (_) => SendMessageBloc()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRoutes.router,
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme(context),
        darkTheme: AppTheme.darkTheme(context),
      ),
    );
  }
}
