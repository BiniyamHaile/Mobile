import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/profile/profile_bloc.dart';
import 'package:mobile/bloc/profile/profile_picture_cubit.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/ui/pages/auth/preference_page.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'userId';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch data again when the widget becomes visible (e.g., when navigating back to this screen)
    context.read<ProfileBloc>().add(LoadProfile());
    setState(() {});
  }
  // @override
  // void initState() {
  //   super.initState();
  //   // Load the profile data when the page is initialized
  //   context.read<ProfileBloc>().add(LoadProfile());
  // }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final languageService = Provider.of<LanguageService>(context);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go(RouterEnum.profileView.routeName),
        ),
        title: Text(
          languageService.translate(AppStrings.settingsAndPrivacy),
          style: TextStyle(color: theme.colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   languageService.translate(AppStrings.settingsAndPrivacy),
            //   style: const TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 20),
            // Language selection setting
            _buildLanguageSetting(context, languageService),
            const SizedBox(height: 20),
            _buildSection(languageService.translate(AppStrings.account), [
              _buildSettingItem(
                icon: Icons.person,
                title: languageService.translate(
                  AppStrings.changeProfilePicture,
                ),
                onTap: () => _showProfilePicSheet(context),
              ),

              _buildSettingItem(
                icon: Icons.tune,
                title: languageService.translate(AppStrings.contentPreferences),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreferencesPage(),
                    ),
                  );
                },
              ),
            ]),
            _buildSection(
              languageService.translate(AppStrings.supportAndAbout),
              [
                _buildSettingItem(
                  icon: Icons.description,
                  title: languageService.translate(AppStrings.termsAndPolicies),
                  onTap: () {
                    // TODO: Navigate to terms and policies
                  },
                ),
              ],
            ),
            _buildSection('', [
              _buildSettingItem(
                icon: Icons.logout,
                title: languageService.translate(AppStrings.logOut),
                onTap: () => _showLogoutConfirmation(context),
                textColor: Colors.red,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _buildSection(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
      ],
      ...children,
      const SizedBox(height: 24),
    ],
  );
}

Widget _buildSettingItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? textColor,
}) {
  return ListTile(
    leading: Icon(icon, color: textColor),
    title: Text(title, style: TextStyle(color: textColor)),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

void _showLogoutConfirmation(BuildContext context) {
  final languageService = Provider.of<LanguageService>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(languageService.translate(AppStrings.logOut)),
      content: Text(languageService.translate(AppStrings.logOutConfirmation)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(languageService.translate(AppStrings.cancel)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _logout(context);
          },
          child: Text(languageService.translate(AppStrings.logOut)),
        ),
      ],
    ),
  );
}

void _logout(BuildContext context) {
  final languageService = Provider.of<LanguageService>(context, listen: false);

  // Get SharedPreferences instance
  final prefs = SharedPreferences.getInstance();

  const String _tokenKey = 'token';
  const String _userIdKey = 'userId';

  // Clear the token and user ID
  prefs.then((prefs) async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  });

  // Show success message with custom styling
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            languageService.translate(AppStrings.loggedOutSuccess),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );

  context.go(RouteNames.login);
}

Widget _buildLanguageSetting(
  BuildContext context,
  LanguageService languageService,
) {
  final languages = [
    {'code': 'am', 'label': languageService.translate(AppStrings.amharic)},
    {'code': 'om', 'label': languageService.translate(AppStrings.afaanOromo)},
    {'code': 'en', 'label': languageService.translate(AppStrings.english)},
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        languageService.translate(AppStrings.language),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: languages.map((lang) {
          final isSelected = languageService.currentLanguage == lang['code'];
          return Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: ChoiceChip(
              label: Text(lang['label']!, style: TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected && !isSelected) {
                  languageService.changeLanguage(lang['code']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    ],
  );
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
                content: Text('Profile picture updated!'),
                backgroundColor: Colors.green,
              ),
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
