import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/profile/usernamesettings_bloc.dart';

class ChangeUsernamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Username', style: TextStyle(color: Colors.white)),
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
                create: (context) => UsernamesettingsBloc(),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ChangeUsernameForm(),
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

class ChangeUsernameForm extends StatefulWidget {
  @override
  _ChangeUsernameFormState createState() => _ChangeUsernameFormState();
}

class _ChangeUsernameFormState extends State<ChangeUsernameForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isUsernameAvailable = false;
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(BuildContext context, String username) {
    if (username.isNotEmpty && username.length >= 3) {
      context.read<UsernamesettingsBloc>().add(
        UsernameAvailabilityChecked(username: username),
      );
    } else {
      setState(() {
        _usernameError = null;
        _isUsernameAvailable = false;
      });
    }
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate() && _isUsernameAvailable) {
      context.read<UsernamesettingsBloc>().add(
        UsernameChanged(newUsername: _usernameController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsernamesettingsBloc, UsernamesettingsState>(
      listener: (context, state) {
        if (state is UsernameUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Username updated successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        if (state is UsernameUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error, style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<UsernamesettingsBloc, UsernamesettingsState>(
        builder: (context, state) {
          if (state is UsernameAvailable) {
            _isUsernameAvailable = true;
            _usernameError = null;
          } else if (state is UsernameNotAvailable) {
            _isUsernameAvailable = false;
            _usernameError = 'Username is not available';
          } else if (state is UsernameAvailabilityChecking) {
            _isUsernameAvailable = false;
            _usernameError = null;
          }
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Update Your Username',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                ),
                SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  cursorColor: Color.fromRGBO(143, 148, 251, 1),
                  decoration: InputDecoration(
                    labelText: 'New Username',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: state is UsernameAvailabilityChecking
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color.fromRGBO(143, 148, 251, 1),
                            ),
                          )
                        : _isUsernameAvailable
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : _usernameError != null
                        ? Icon(Icons.error, color: Colors.red)
                        : null,
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
                  onChanged: (value) => _onUsernameChanged(context, value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (_usernameError != null) {
                      return _usernameError;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
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
                    onPressed:
                        state is UsernameUpdateInProgress ||
                            !_isUsernameAvailable
                        ? null
                        : () => _onSubmit(context),
                    child: state is UsernameUpdateInProgress
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'UPDATE USERNAME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
