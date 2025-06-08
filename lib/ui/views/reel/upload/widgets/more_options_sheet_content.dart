import 'package:flutter/material.dart';

// This widget defines the UI structure for the more options.
// It expects the current state values and callbacks for when they change.
class MoreOptionsSheetContent extends StatelessWidget {
  final bool allowComments;
  final bool saveToDevice;
  final bool saveWithWatermark;
  final bool audienceControls;

  final ValueChanged<bool> onAllowCommentsChanged;
  final ValueChanged<bool> onSaveToDeviceChanged;
  final ValueChanged<bool> onSaveWithWatermarkChanged;
  final ValueChanged<bool> onAudienceControlsChanged;

  const MoreOptionsSheetContent({
    Key? key,
    required this.allowComments,
    required this.saveToDevice,
    required this.saveWithWatermark,
    required this.audienceControls,
    required this.onAllowCommentsChanged,
    required this.onSaveToDeviceChanged,
    required this.onSaveWithWatermarkChanged,
    required this.onAudienceControlsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Padding for the bottom sheet content
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'More options',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.comment),
              title: const Text('Allow comments'),
              value: allowComments,
              onChanged: onAllowCommentsChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            ),
            const Divider(height: 1),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.download_outlined),
              title: const Text('Save to device'),
              subtitle: const Text(
                  'Your post will be saved to device, unless a violation of Community Guideline is found.',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              value: saveToDevice,
              onChanged: onSaveToDeviceChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            ),
            const Divider(height: 1),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.branding_watermark),
              title: const Text('Save posts with watermark'),
              value: saveWithWatermark,
              onChanged: onSaveWithWatermarkChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            ),
            const Divider(height: 1),
            SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.group_outlined),
              title: const Text('Audience controls'),
              subtitle: const Text(
                  'This video is limited to those aged 18 years and older',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              value: audienceControls,
              onChanged: onAudienceControlsChanged,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.black,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
