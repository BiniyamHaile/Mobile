
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/bloc/auth/signup/signup_bloc.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/views/auth/form_wrapper.dart';
import 'package:mobile/ui/views/auth/password_input.dart';
import 'package:mobile/ui/widgets/inputs/auth/custom_input_field.dart';
import 'package:mobile/ui/widgets/inputs/auth/password_input_with_strength_indicator.dart';

class SignupInputFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController emailController;
  final void Function() onSubmit;
  const SignupInputFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.surnameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.emailController,
  });

  @override
  State<SignupInputFields> createState() => _SignupInputFieldsState();
}

class _SignupInputFieldsState extends State<SignupInputFields> {
  ValueNotifier<bool> showPasswordErrorNotifier = ValueNotifier(false);
  bool showPasswordError = false;
  TextEditingController? activeController;
  bool validateAll = false;

  void _onPrevalidation() {
    validateAll = true;
    activeController = null;
    showPasswordErrorNotifier.value = true;
  }

  String? _validate(TextEditingController controller) {

    if (controller == widget.nameController && _shouldValidate(controller)) {
      final nameError = context.read<AuthFormBloc>().state.nameError;

      return nameError;
    } else if (controller == widget.surnameController &&
        _shouldValidate(controller)) {
      final surnameError = context.read<AuthFormBloc>().state.surnameError;

      return surnameError;
    } else if (controller == widget.passwordController &&
        _shouldValidate(controller)) {
      final passwordError = context.read<AuthFormBloc>().state.passwordError;

      return passwordError;
    } else if (controller == widget.confirmPasswordController &&
        _shouldValidate(controller)) {
      final confirmPasswordError =
          context.read<AuthFormBloc>().state.confirmPasswordError;

      return confirmPasswordError;
    }
    return null;
  }

  bool _shouldValidate(TextEditingController controller) {
    return activeController == controller ||
        activeController == null ||
        validateAll;
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeUtils(context);
    final appTheme = Theme.of(context);

    return BlocListener<AuthFormBloc, AuthFormState>(
      listener: (context, state) {
        widget.formKey.currentState?.validate();
      },
      child: BlocBuilder<SignupBloc, SignupState>(
        builder: (context, state) {
          return FormWrapper(
            formKey: widget.formKey,
            loading: state is SignupLoading,
            inputFields: [
              CustomTextField(
                margin: EdgeInsets.symmetric(
                    vertical: screen.scaledScreenHeight(0.015)),
                controller: widget.nameController,
                hintText: "name",
                keyboardType: TextInputType.name,
                prefixIcon: Icon(Icons.person, color: appTheme.iconTheme.color),
                validator: (value) => _validate(widget.nameController),
                onChanged: (value) {
                  if (value == null) return null;
                  activeController = widget.nameController;
                  context.read<AuthFormBloc>().add(NameChanged(value));
                  return null;
                },
              ),
              CustomTextField(
                margin: EdgeInsets.symmetric(
                    vertical: screen.scaledScreenHeight(0.015)),
                controller: widget.surnameController,
                hintText: "surname",
                keyboardType: TextInputType.name,
                prefixIcon: Icon(Icons.person, color: appTheme.iconTheme.color),
                validator: (value) => _validate(widget.surnameController),
                onChanged: (value) {
                  if (value == null) return null;

                  activeController = widget.surnameController;
                  context.read<AuthFormBloc>().add(SurnameChanged(value));
                  return null;
                },
              ),
              CustomTextField(
                controller: widget.emailController,
                validator: (value) => _validate(widget.emailController),
                onChanged: (value) {
                  if (value == null) return null;

                  activeController = widget.emailController;
                  context.read<AuthFormBloc>().add(EmailChanged(value));
                  return null;
                },
                margin: EdgeInsets.only(
                  bottom: screen.scaledScreenHeight(0.03),
                  top: screen.scaledScreenHeight(0.015),
                ),
                hintText: "email",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email, color: appTheme.iconTheme.color),
              ),
              ValueListenableBuilder(
                  valueListenable: showPasswordErrorNotifier,
                  builder: (context, showError, child) {
                    return PasswordInputWithStrengthIndicator(
                      controller: widget.passwordController,
                      showError: showPasswordError,
                    );
                  }),
              PasswordInput(
                controller: widget.confirmPasswordController,
                hintText: "Confirm password",
                validator: (value) =>
                    _validate(widget.confirmPasswordController),
                onChanged: (value) {
                  if (value == null) return null;

                  activeController = widget.confirmPasswordController;
                  context.read<AuthFormBloc>().add(ConfirmPasswordChanged(
                        confirmPassword: value,
                        password: widget.passwordController.text,
                      ));
                  return null;
                },
              ),
            ],
            bottomGap: screen.scaledScreenHeight(0.025),
            onSubmit: widget.onSubmit,
            onPrevalidation: _onPrevalidation,
            submitTitle: "Enter",
          );
        },
      ),
    );
  }
}
