import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/forgot_password/forgot_password_bloc.dart';
import 'package:mobile/bloc/auth/login/login_bloc.dart';
import 'package:mobile/bloc/auth/otp/otp_bloc.dart';
import 'package:mobile/bloc/auth/reset_password/reset_password_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/bloc/comment/comment_bloc.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_bloc.dart';
import 'package:mobile/core/dependency_injector/dependency_injector.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';

// void main() => runApp(
//   App(),

// );

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  injectionSetup();

  runApp(
    const App(),
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
          BlocProvider<ReelFeedAndActionBloc>(
            create: (context) => getIt<ReelFeedAndActionBloc>(),
          ),
          BlocProvider<PostDetailsBloc>(
            create: (context) => getIt<PostDetailsBloc>(),
          ),
          BlocProvider<CommentBloc>(
            create: (context) => getIt<CommentBloc>(),
          ),
        ],
        child: MaterialApp.router(
            routerConfig: AppRoutes.router,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(context)));
  }
}
