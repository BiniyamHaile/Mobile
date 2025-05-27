// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/forgot_password/forgot_password_bloc.dart';
import 'package:mobile/bloc/auth/login/login_bloc.dart';
import 'package:mobile/bloc/auth/otp/otp_bloc.dart';
import 'package:mobile/bloc/auth/reset_password/reset_password_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/repository/social/post_repository.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        MultiBlocProvider(
          providers: [
            // ChangeNotifierProvider(create: (_) => EthereumService()),
            BlocProvider<AuthFormBloc>(create: (context) => AuthFormBloc()),
            BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
            BlocProvider(
              create: (context) => PostBloc(
                postRepository: PostRepository(),
              ),
              child: const PostingScreen(),
            ),
            BlocProvider<OtpBloc>(create: (context) => OtpBloc()),
            BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
            BlocProvider<ResetPasswordBloc>(
                create: (context) => ResetPasswordBloc()),
            BlocProvider<ForgotPasswordBloc>(
                create: (context) => ForgotPasswordBloc()),
          ],
          child: App(),
        ),
      ],
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthFormBloc>(create: (context) => AuthFormBloc()),
          BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
          BlocProvider<OtpBloc>(create: (context) => OtpBloc()),
          BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
          BlocProvider<ResetPasswordBloc>(
              create: (context) => ResetPasswordBloc()),
          BlocProvider<ForgotPasswordBloc>(
              create: (context) => ForgotPasswordBloc()),
        ],
        child: MaterialApp.router(
            routerConfig: AppRoutes.router,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(context)));
  }
}
