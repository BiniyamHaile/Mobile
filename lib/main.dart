import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/forgot_password/forgot_password_bloc.dart';
import 'package:mobile/bloc/auth/login/login_bloc.dart';
import 'package:mobile/bloc/auth/otp/otp_bloc.dart';
import 'package:mobile/bloc/auth/reset_password/reset_password_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/bloc/chat/recent_chat/recent_chat_bloc.dart';
import 'package:mobile/bloc/chat/retrieve_messages/retrieve_messages_bloc.dart';
import 'package:mobile/bloc/chat/send_message/send_message_bloc.dart';
import 'package:mobile/bloc/comment/comment_bloc.dart';
import 'package:mobile/bloc/notifications/retrieve-notifications/retrieve_notifications_bloc.dart';
import 'package:mobile/bloc/profile/profile_bloc.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_bloc.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/core/dependency_injector/dependency_injector.dart';
import 'package:mobile/core/injections/get_it.dart' hide getIt;
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/repository/social/post_repository.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
import 'package:mobile/services/api/profile/profile_repository.dart';
import 'package:mobile/services/api/wallet/wallet_repository_impl.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<String> getLocalIPAddress() async {
  try {
    // Get the list of network interfaces
    final interfaces = await NetworkInterface.list();

    // Iterate over the interfaces and find one that's not a loopback address
    for (var interface in interfaces) {
      for (var address in interface.addresses) {
        if (!address.isLoopback) {
          // Check if it's an IPv4 address (optional)
          if (address.type == InternetAddressType.IPv4) {
            return address.address;
          }
          // If you want IPv6 addresses as well, remove the type check
          //return address.address;
        }
      }
    }

    return '127.0.0.1'; // Fallback to localhost if no suitable address is found
  } catch (e) {
    print('Error getting local IP: $e');
    return '127.0.0.1'; // Fallback to localhost in case of errors
  }
}

void main() async {
  final ipAddress = await getLocalIPAddress();
  print('Local IP Address: $ipAddress');
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print(".env loaded successfully");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  injectionSetup();
  setupServiceLocator();
  await _initNotifications();

  final dio = Dio();
  final apiEndpoints = ApiEndpoints();
  final walletRepository = WalletRepositoryImpl(
    dio: dio,
    apiEndpoints: apiEndpoints,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageService(),
      child: MultiProvider(
        providers: [
          MultiProvider(
            providers: [
              MultiBlocProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) =>
                        WalletService(walletRepository: walletRepository),
                  ),
                  BlocProvider<AuthFormBloc>(
                    create: (context) => AuthFormBloc(),
                  ),
                  BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
                  BlocProvider(
                    create: (context) =>
                        PostBloc(postRepository: PostRepository()),
                    child: const PostingScreen(),
                  ),
                  BlocProvider<OtpBloc>(create: (context) => OtpBloc()),
                  BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
                  BlocProvider<ResetPasswordBloc>(
                    create: (context) => ResetPasswordBloc(),
                  ),
                  BlocProvider<ForgotPasswordBloc>(
                    create: (context) => ForgotPasswordBloc(),
                  ),
                  BlocProvider(create: (_) => AuthFormBloc()),
                  BlocProvider(create: (_) => SignupBloc()),
                  BlocProvider(create: (_) => RetrieveNotificationsBloc()),
                  BlocProvider(
                    create: (_) =>
                        RecentChatBloc()..add(LoadRecentChatsEvent()),
                  ),
                  BlocProvider(create: (_) => RetrieveMessagesBloc()),
                  BlocProvider(create: (_) => SendMessageBloc()),
                  BlocProvider<AuthFormBloc>(
                    create: (context) => AuthFormBloc(),
                  ),
                  BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
                  BlocProvider<OtpBloc>(create: (context) => OtpBloc()),
                  BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
                  BlocProvider<ResetPasswordBloc>(
                    create: (context) => ResetPasswordBloc(),
                  ),
                  BlocProvider<ForgotPasswordBloc>(
                    create: (context) => ForgotPasswordBloc(),
                  ),
                  BlocProvider<ReelFeedAndActionBloc>(
                    create: (context) => getIt<ReelFeedAndActionBloc>(),
                  ),
                  BlocProvider<PostDetailsBloc>(
                    create: (context) => getIt<PostDetailsBloc>(),
                  ),
                  BlocProvider<CommentBloc>(
                    create: (context) => getIt<CommentBloc>(),
                  ),
                  BlocProvider(create: (_) => RetrieveNotificationsBloc()),
                  BlocProvider(
                    create: (_) =>
                        RecentChatBloc()..add(LoadRecentChatsEvent()),
                  ),
                  BlocProvider(create: (_) => RetrieveMessagesBloc()),
                  BlocProvider(create: (_) => SendMessageBloc()),
                  BlocProvider<AuthFormBloc>(
                    create: (context) => AuthFormBloc(),
                  ),
                  BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
                  BlocProvider<OtpBloc>(create: (context) => OtpBloc()),
                  BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
                  BlocProvider<ResetPasswordBloc>(
                    create: (context) => ResetPasswordBloc(),
                  ),
                  BlocProvider<ForgotPasswordBloc>(
                    create: (context) => ForgotPasswordBloc(),
                  ),
                  BlocProvider<ProfileBloc>(
                    create: (context) =>
                        ProfileBloc(profileRepository: ProfileRepository(dio)),
                  ),
                ],
                child: App(),
              ),
            ],
          ),
        ],
      ),
    ),
  );
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
    // extractUserId();
  }

  // Future<void> extractUserId()async {
  //     final prefs = await SharedPreferences.getInstance();
  //    final token =  prefs.getString('token') ?? "";
  //   final parts = token.split('.');
  //   if (parts.length != 3) throw Exception('Invalid token');

  //   final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  //   final Map<String, dynamic> data = json.decode(payload);

  //   getIt<WebSocketService>().connect(data['userId']);

  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
    );
  }
}
