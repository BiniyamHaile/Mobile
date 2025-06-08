import 'package:flutter/material.dart';
import 'package:mobile/models/reel/privacy_option.dart';

class PrivacySettingsSheetContent extends StatefulWidget {
  final PrivacyOption initialPrivacy;
  final ValueChanged<PrivacyOption> onPrivacySelected;

  const PrivacySettingsSheetContent({
    Key? key,
    required this.initialPrivacy,
    required this.onPrivacySelected,
  }) : super(key: key);

  @override
  State<PrivacySettingsSheetContent> createState() =>
      _PrivacySettingsSheetContentState();
}

class _PrivacySettingsSheetContentState
    extends State<PrivacySettingsSheetContent> {
  late PrivacyOption _tempSelectedOption;

  @override
  void initState() {
    super.initState();
    _tempSelectedOption = widget.initialPrivacy;
  }

  void _selectOption(PrivacyOption value) {
    setState(() {
      _tempSelectedOption = value;
    });
    widget.onPrivacySelected(value);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Privacy settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Who can view this post',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Followers'),
            subtitle: const Text(
              'Visible only to followers on your private account',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            leading: Radio<PrivacyOption>(
              value: PrivacyOption.followers,
              groupValue: _tempSelectedOption,
              activeColor: Colors.red,
              onChanged: (PrivacyOption? value) {
                if (value != null) {
                  _selectOption(value);
                }
              },
            ),
            onTap: () => _selectOption(
              PrivacyOption.followers,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Friends'),
            subtitle: const Text(
              'Followers you follow back',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            leading: Radio<PrivacyOption>(
              value: PrivacyOption.friends,
              groupValue: _tempSelectedOption,
              activeColor: Colors.red,
              onChanged: (PrivacyOption? value) {
                if (value != null) {
                  _selectOption(value);
                }
              },
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _selectOption(PrivacyOption.friends);
            },
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Only you'),
            leading: Radio<PrivacyOption>(
              value: PrivacyOption.onlyYou,
              activeColor: Colors.red,
              groupValue: _tempSelectedOption,
              onChanged: (PrivacyOption? value) {
                if (value != null) {
                  _selectOption(value);
                }
              },
            ),
            onTap: () => _selectOption(
              PrivacyOption.onlyYou,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
