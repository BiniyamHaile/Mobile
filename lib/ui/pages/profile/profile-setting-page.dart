import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/profile/profile_picture_cubit.dart';
import 'package:mobile/ui/pages/profile/change-password-page.dart';
import 'package:mobile/ui/pages/profile/change-username-page.dart';
import 'package:mobile/ui/pages/search/search_page.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'userId';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings and Privacy',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // White back arrow
          onPressed: () => context.go(RouterEnum.profileView.routeName),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingItem(
              context,
              'Change Password',
              Icons.lock,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordSettingsPage()),
              ),
            ),
            _buildSettingItem(
              context,
              'Change Username',
              Icons.person_outline,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeUsernamePage()),
              ),
            ),
            _buildSettingItem(
              context,
              'Change Profile Picture',
              Icons.photo_camera,
              onTap: () => _showProfilePicSheet(context),
            ),

            _buildSectionHeader('Preference'),
            // _buildSettingItem(context, 'Notifications', Icons.notifications),
            // _buildSettingItem(context, 'LIVE', Icons.live_tv),
            // _buildSettingItem(
            //   context,
            //   'SEARCH',
            //   Icons.history,
            //   onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => SearchPage()),
            //   ),
            // ),
            _buildSettingItem(
              context,
              'Content preferences',
              Icons.tune,
              onTap: () => context.go(RouteNames.preferences),
            ),
            // _buildSettingItem(context, 'Audience controls', Icons.people),
            // _buildSettingItem(context, 'Ads', Icons.ads_click),
            // _buildSettingItem(context, 'Playback', Icons.play_circle_outline),
            // _buildSettingItem(context, 'Display', Icons.display_settings),

            // Support Section
            _buildSectionHeader('Support & about'),
            // _buildSettingItem(context, 'Support', Icons.support_agent),
            // // _buildSettingItem(context, 'Report a Problem', Icons.report),
            _buildSettingItem(context, 'Terms and Policies', Icons.description),

            // Logout Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () => print('$title tapped'),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Use the context passed from build
    showDialog(
      context: context,

      // Use the original context to show the dialog
      builder: (BuildContext dialogContext) {
        // Use a different variable for the dialog's context
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color.fromRGBO(143, 148, 251, 0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient background
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(143, 148, 251, 0.1),
                        Color.fromRGBO(143, 148, 251, 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(143, 148, 251, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.logOut,
                          color: Color.fromRGBO(143, 148, 251, 1),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color.fromRGBO(143, 148, 251, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ),
                // Buttons
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Get SharedPreferences instance
                          final prefs = await SharedPreferences.getInstance();

                          // Clear the token and user ID
                          await prefs.remove(_tokenKey);
                          await prefs.remove(_userIdKey);

                          // Dismiss the dialog first
                          Navigator.of(dialogContext).pop();

                          // Show success message with custom styling
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.all(16),
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Logged out successfully',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          context.go(RouteNames.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfilePicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (_) => ProfilePictureCubit(),
          child: _ProfilePicSheetContent(),
        );
      },
    );
  }
}

class _ProfilePicSheetContent extends StatefulWidget {
  @override
  State<_ProfilePicSheetContent> createState() =>
      _ProfilePicSheetContentState();
}

class _ProfilePicSheetContentState extends State<_ProfilePicSheetContent> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  void _upload(BuildContext context) {
    if (_selectedImage != null) {
      context.read<ProfilePictureCubit>().uploadProfilePicture(
        _selectedImage!.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: BlocConsumer<ProfilePictureCubit, ProfilePictureState>(
        listener: (context, state) {
          if (state is ProfilePictureSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Profile picture updated!',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfilePictureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose profile pic',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _selectedImage != null
                  ? CircleAvatar(
                      radius: 48,
                      backgroundImage: FileImage(_selectedImage!),
                    )
                  : CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 48, color: Colors.white),
                    ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state is ProfilePictureUploading ? null : _pickImage,
                icon: Icon(Icons.photo_library),
                label: Text('Choose profile pic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      state is ProfilePictureUploading || _selectedImage == null
                      ? null
                      : () => _upload(context),
                  child: state is ProfilePictureUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Update',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
