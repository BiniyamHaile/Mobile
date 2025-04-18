import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/theme/app_theme.dart';

void main() => runApp(
  App(),
 
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return 
  MultiBlocProvider(providers: [
    BlocProvider<AuthFormBloc>(create: (context) => AuthFormBloc()),
    BlocProvider<SignupBloc>(create: (context) => SignupBloc()),
  ], child:  MaterialApp.router(
    routerConfig: AppRoutes.router,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme(context)
  ));
  }
}

