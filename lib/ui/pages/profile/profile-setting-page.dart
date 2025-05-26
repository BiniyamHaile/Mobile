import 'package:flutter/material.dart';
import 'package:mobile/ui/pages/profile/change-password-page.dart';
import 'package:mobile/ui/pages/profile/change-username-page.dart';

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
            _buildSettingItem(context, 'Change Profile Picture', Icons.photo_camera),

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
}
