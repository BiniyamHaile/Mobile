import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/bloc/chat/retrieve_messages/retrieve_messages_bloc.dart';
import 'package:mobile/bloc/chat/send_message/send_message_bloc.dart';
import 'package:mobile/bloc/notifications/retrieve-notifications/retrieve_notifications_bloc.dart';
import 'package:mobile/bloc/chat/recent_chat/recent_chat_bloc.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';

void main() => runApp(
  const App(),
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

@override
void initState() {
  super.initState();
  initNotifications();
}


  @override
  Widget build(BuildContext context) {
    return 
  MultiBlocProvider(providers: [
    BlocProvider<AuthFormBloc>(create: (context) => AuthFormBloc()),
    BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
    BlocProvider<RetrieveNotificationsBloc>(create: (context) => RetrieveNotificationsBloc()),
    BlocProvider<RecentChatBloc>(create: (context) => RecentChatBloc()..add(LoadRecentChatsEvent())),
    BlocProvider<RetrieveMessagesBloc>(create: (context) => RetrieveMessagesBloc()),
    BlocProvider<SendMessageBloc>(
      create: (context) => SendMessageBloc(),
    )
  ], child:  MaterialApp.router(
    routerConfig: AppRoutes.router,
    debugShowCheckedModeBanner: false,
    // themeMode: ThemeMode.system,
    themeMode: ThemeMode.light,
    theme: AppTheme.lightTheme(context),
    darkTheme: AppTheme.darkTheme(context),
  ));
  }
}

