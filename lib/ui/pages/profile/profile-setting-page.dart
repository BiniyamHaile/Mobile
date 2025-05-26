import 'package:flutter/material.dart';
import 'package:mobile/ui/pages/profile/change-password-page.dart';
import 'package:mobile/ui/pages/profile/change-username-page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/profile/profile_picture_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings and Privacy',
            style: TextStyle(color:  Colors.black)), // White title
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white, // Black background
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // White back arrow
          onPressed: () => Navigator.of(context).pop(),
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
            _buildSettingItem(context, 'Change Username', Icons.person_outline, onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangeUsernamePage()),
              ),
            ),
            _buildSettingItem(context, 'Change Profile Picture', Icons.photo_camera, onTap: () => _showProfilePicSheet(context)),

            // Content & Display Section
            _buildSectionHeader('Preference'),
            _buildSettingItem(context, 'Notifications', Icons.notifications),
            _buildSettingItem(context, 'LIVE', Icons.live_tv),
            _buildSettingItem(context, 'Activity center', Icons.history),
            _buildSettingItem(context, 'Content preferences', Icons.tune),
            _buildSettingItem(context, 'Audience controls', Icons.people),
            _buildSettingItem(context, 'Ads', Icons.ads_click),
            _buildSettingItem(context, 'Playback', Icons.play_circle_outline),
            _buildSettingItem(context, 'Display', Icons.display_settings),

            // Support Section
            _buildSectionHeader('Support & about'),
            _buildSettingItem(context, 'Support', Icons.support_agent),
            // _buildSettingItem(context, 'Report a Problem', Icons.report),
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
                      color: Colors.black,
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

Widget _buildSettingItem(BuildContext context, String title, IconData icon,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap ?? () => print('$title tapped'),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform logout
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logged out successfully')),
                );
              },
              child: Text('Log Out', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showProfilePicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
  State<_ProfilePicSheetContent> createState() => _ProfilePicSheetContentState();
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
      context.read<ProfilePictureCubit>().uploadProfilePicture(_selectedImage!.path);
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
              SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
            );
          } else if (state is ProfilePictureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose profile pic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  onPressed: state is ProfilePictureUploading || _selectedImage == null ? null : () => _upload(context),
                  child: state is ProfilePictureUploading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
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
