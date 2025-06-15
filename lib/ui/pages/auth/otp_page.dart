import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/otp/otp_bloc.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/pages/auth/otp-params.dart';
import 'package:mobile/ui/routes/route_names.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;

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

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<OtpBloc>().add(
        OtpSubmitted(
          email: _emailController.text.trim(),
          code: _otpController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpState>(
      listener: (context, state) {
        if (state is OtpFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is OtpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ),
          );
          context.go(
            RouteNames.login,
            extra: OtpParams(email: _emailController.text.trim()),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is OtpLoading;

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
                                AppStrings.otpVerification.tr(context),
                                style: const TextStyle(
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
                                AppStrings.enterOtpSent.tr(context),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _emailController,
                                cursorColor: Colors.deepPurple,
                                decoration: InputDecoration(
                                  labelText: AppStrings.email.tr(context),
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Email is required'
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _otpController,
                                cursorColor: Colors.deepPurple,
                                decoration: InputDecoration(
                                  labelText: AppStrings.verifyOtp.tr(context),
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                validator: (val) => val == null || val.isEmpty
                                    ? 'OTP is required'
                                    : null,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _verifyOtp,
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
                                      : Text(
                                          isLoading
                                              ? AppStrings.verifying.tr(context)
                                              : AppStrings.verifyOtp.tr(context),
                                          style: const TextStyle(
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
                                    AppStrings.didntReceiveCode.tr(context),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<OtpBloc>().add(
                                              OtpResendRequested(
                                                email: _emailController.text
                                                    .trim(),
                                              ),
                                            );
                                          },
                                    child: Text(
                                      AppStrings.resendOtp.tr(context),
                                      style: const TextStyle(
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
