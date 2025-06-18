import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/login/login_bloc.dart';
import 'package:mobile/core/validators/auth_validator.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/pages/auth/otp-params.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/views/auth/validation_indicator.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _initialized = false;

  // Password validation state
  double _strengthPercentage = 0.0;
  String? _errorText;
  Color? _indicatorColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final routeState = GoRouterState.of(context);
      final args = routeState.extra;
      if (args is OtpParams) {
        _emailController.text = args.email;
      }
      _initialized = true;
    }
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(
        LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _updatePasswordStrength(String password) {
    final validator = Validator(context);
    final maxStrength = validator.maxErrorStrength;
    final validation = validator.validateNewPassword(password);
    setState(() {
      _errorText = validation.message;
      _strengthPercentage =
          (maxStrength - (validation.errorStrength)) * 100 / maxStrength;
      _indicatorColor = validation.color;
    });
  }

  @override
  Widget build(BuildContext context) {

    final lang = context.watch<LanguageService>();

    final theme = AppTheme.getTheme(context);

    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is LoginSuccess) {
          // Navigate to home page after successful login
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(
                AppStrings.loginSuccess.tr(context),
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          context.go(RouteNames.feed);
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        final theme = AppTheme.getTheme(context);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Animated Header Section
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(
                          duration: const Duration(seconds: 1),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-1.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/light-2.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/clock.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: Container(
                            margin: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                               AppStrings.login.tr(context),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromRGBO(143, 148, 251, 1),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                AppStrings.welcomeLogin.tr(context),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                cursorColor: Colors.deepPurple,
                                style:  TextStyle(color: theme.colorScheme.primary),
                                decoration: InputDecoration(
                                  labelText: AppStrings.email.tr(context),
                                  labelStyle: TextStyle(
                                  color: Colors.black,
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  prefixIconColor: theme.colorScheme.primary,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return AppStrings.emailRequired.tr(context);
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+?',
                                  );
                                  if (!emailRegex.hasMatch(val)) {
                                    return AppStrings.invalidEmail.tr(context);
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                cursorColor: Colors.deepPurple,
                                style: TextStyle(
                                  color: Colors.black,
                                ),

                                decoration: InputDecoration(
                                  labelText: AppStrings.password.tr(context),
                                  labelStyle: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  prefixIconColor: theme.colorScheme.primary,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) =>
                                    _updatePasswordStrength(value),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return AppStrings.passwordRequired.tr(context);
                                  }
                                  if (val.length < 8) {
                                    return AppStrings.passwordMinLength.tr(context);
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(val)) {
                                    return AppStrings.passwordUppercase.tr(context);
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(val)) {
                                    return AppStrings.passwordNumber.tr(context);
                                  }
                                  if (!RegExp(r'[(@$!%*?&)]').hasMatch(val)) {
                                    return AppStrings.passwordSpecialChar.tr(context);
                                  }
                                  return null;
                                },
                              ),
                              ValidationIndicator(
                                fillColor: _indicatorColor,
                                message: _errorText,
                                fillPercentage: _strengthPercentage,
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.go('/forgot-password');
                                        },
                                  child: Text(
                                    AppStrings.forgotPassword.tr(context),
                                    style: TextStyle(
                                      color: Color.fromRGBO(143, 148, 251, 1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(
                                      143,
                                      148,
                                      251,
                                      1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      :  Text(
                                          AppStrings.login.tr(context),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.dontHaveAccount.tr(context),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.go('/register');
                                          },
                                    child: Text(
                                      AppStrings.register.tr(context),
                                      style: TextStyle(
                                        color: Color.fromRGBO(143, 148, 251, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
