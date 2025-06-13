import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/services/localization/app_text.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/pages/auth/otp-params.dart';
import 'package:mobile/ui/pages/auth/otp_page.dart';
import 'package:mobile/ui/routes/app_routes.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/utils/ui_helpers.dart';
import 'package:mobile/ui/views/auth/signup_input_view.dart';
import 'package:mobile/ui/widgets/inputs/auth/terms_and_privacy_checkbox.dart';
import 'package:mobile/ui/widgets/shared/helpers/custom_spacer.dart';
import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
class SignupFormView extends StatefulWidget {
  const SignupFormView({super.key});

  @override
  State<SignupFormView> createState() => _SignupFormViewState();
}

class _SignupFormViewState extends State<SignupFormView> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _emailController;
  late String _selectedGender;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> checkboxValueNotifier = ValueNotifier(false);
  ValueNotifier<Color?> checkboxColorNotifier = ValueNotifier(null);
  Color? checkboxColor;
  TextEditingController? activeController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emailController = TextEditingController();
    super.initState();
  }

  void _handleCheckbox(bool value, [Color? color]) {
    checkboxValueNotifier.value = value;
    checkboxColorNotifier.value = color;
    
  }

  void _handleGenderChanged(String gender) {
    _selectedGender = gender;
  }

  void _handleSubmit() {
     if (_selectedGender == null || _selectedGender!.isEmpty) {
      UiHelpers.showErrorSnackBar(context, AppStrings.selectGender.tr(context));
      return;
    }
    if (!checkboxValueNotifier.value) {
      _handleCheckbox(false, Colors.red);

      return;
    }
    context.read<SignupBloc>().add(
          SignupEvent( 
            email: _emailController.text,
            name: _nameController.text,
            surname: _surnameController.text,
            password: _passwordController.text,
            gender: _selectedGender
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeUtils(context);
    final appTheme = Theme.of(context);

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupFailure) {
          final error = state.error;
          UiHelpers.showErrorSnackBar(
              context, error);
        } else if (state is SignupSuccess) {
          final message = state.message;
          UiHelpers.showSuccessSnackBar(context, message);
          // Route to otp screen
          // context.go(AppRoutes.otp,
          //     extra:
          //         OtpParams(email: widget.email, name: _nameController.text));
          context.go(RouteNames.otp, extra: OtpParams(email: _emailController.text.trim()),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.scaledShortestScreenSide(0.1),
        ),
        child: Column(
          children: [
            Text(
              AppStrings.completeDetails.tr(context),
              style: appTheme.textTheme.labelSmall,
            ),
            SignupInputFields(
              formKey: _formKey,
              nameController: _nameController,
              surnameController: _surnameController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              emailController: _emailController,
              onSubmit: _handleSubmit,
              onGenderChanged: _handleGenderChanged,

            ),
            CustomSpacer(height: screen.scaledLongestScreenSide(0.02)),
             ValueListenableBuilder(
              valueListenable: checkboxValueNotifier,
              builder: (context, value, child) => ValueListenableBuilder(
                valueListenable: checkboxColorNotifier,
                builder: (context, color, child) {
                  return TermsAndPrivacyCheckbox(
                    checkboxValue: value,
                    onChanged: (value) => _handleCheckbox(value ?? false),
                    color: color,
                  );
                },
              ),
            ),

            CustomSpacer(height: screen.scaledLongestScreenSide(0.03)),

            RichText(
              textAlign: TextAlign.center, 
              text: TextSpan(
                text: AppStrings.dontHaveAccount.tr(context),
                style: appTheme.textTheme.bodyMedium?.copyWith(
                  color: appTheme.colorScheme.onSurface.withOpacity(0.7), // Match nearby text color
                ),
                children: [
                  TextSpan(
                    text: AppStrings.login.tr(context),
                    style: appTheme.textTheme.bodyMedium?.copyWith( 
                      color: Color.fromRGBO(143, 148, 251, 1),
                      fontWeight: FontWeight.bold, 
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.go(RouteNames.login);
                      },
                  ),
                ],
              ),
            ),

            CustomSpacer(height: screen.scaledLongestScreenSide(0.03)),
          ],
        ),
      ),
    );
  }
}
