import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/utils/ui_helpers.dart';
import 'package:mobile/ui/views/auth/signup_input_view.dart';
import 'package:mobile/ui/widgets/inputs/auth/terms_and_privacy_checkbox.dart';
import 'package:mobile/ui/widgets/shared/helpers/custom_spacer.dart';

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

  void _handleSubmit() {
    if (!checkboxValueNotifier.value) {
      _handleCheckbox(false, Colors.red);

      print("Still not checked");
      return;
    }
    print("Checked");
    context.read<SignupBloc>().add(
          SignupEvent( 
            email: _emailController.text,
            name: _nameController.text,
            surname: _surnameController.text,
            password: _passwordController.text,
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
          // Route to otp screen
          // context.go(AppRoutes.otp,
          //     extra:
          //         OtpParams(email: widget.email, name: _nameController.text));
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screen.scaledShortestScreenSide(0.1),
        ),
        child: Column(
          children: [
            Text(
              "Complete your details",
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
          ],
        ),
      ),
    );
  }
}
