import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/profile/passwordsettings_bloc.dart';
import 'package:mobile/core/validators/auth_validator.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/views/auth/validation_indicator.dart';

class PasswordSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     context.watch<LanguageService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.changePassword.tr(context), style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(143, 148, 251, 0.2), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocProvider(
                create: (context) => PasswordsettingsBloc(),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: PasswordSettingsForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordSettingsForm extends StatefulWidget {
  @override
  _PasswordSettingsFormState createState() => _PasswordSettingsFormState();
}

class _PasswordSettingsFormState extends State<PasswordSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Password validation state
  double _strengthPercentage = 0.0;
  String? _errorText;
  Color? _indicatorColor;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
    return BlocListener<PasswordsettingsBloc, PasswordsettingsState>(
      listener: (context, state) {
        if (state is PasswordUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.passwordUpdatedSuccess.tr(context),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        if (state is PasswordUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
             AppStrings.changePassword.tr(context),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(143, 148, 251, 1),
              ),
            ),
            SizedBox(height: 24),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              cursorColor: Color.fromRGBO(143, 148, 251, 1),
              decoration: InputDecoration(
                labelText: AppStrings.currentPassword.tr(context),
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrent = !_obscureCurrent;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ;
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              cursorColor: Color.fromRGBO(143, 148, 251, 1),
              decoration: InputDecoration(
                labelText: AppStrings.newPassword.tr(context),
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                _updatePasswordStrength(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.newPasswordRequired.tr(context);
                }

                final validator = Validator(context);
                final validation = validator.validateNewPassword(value);

                // Only return error if the password is not valid (error strength > 0)
                if (validation.errorStrength > 0) {
                  return validation.message;
                }

                return null;
              },
            ),
            ValidationIndicator(
              fillColor: _indicatorColor,
              message: _errorText,
              fillPercentage: _strengthPercentage,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              cursorColor: Color.fromRGBO(143, 148, 251, 1),
              decoration: InputDecoration(
                labelText: AppStrings.confirmPassword.tr(context),
                labelStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.lock_reset, color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseConfirmPassword.tr(context);
                }
                if (value != _newPasswordController.text) {
                  return AppStrings.passwordsDoNotMatch.tr(context);
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            BlocBuilder<PasswordsettingsBloc, PasswordsettingsState>(
              builder: (context, state) {
                final isLoading = state is PasswordUpdateInProgress;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<PasswordsettingsBloc>().add(
                                PasswordChanged(
                                  currentPassword:
                                      _currentPasswordController.text,
                                  newPassword: _newPasswordController.text,
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppStrings.changePassword.tr(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
