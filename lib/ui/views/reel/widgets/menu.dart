import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/views/reel/report/report_flow.dart';
import 'package:mobile/ui/views/reel/report/share_grid_action_item.dart';
import 'package:mobile/ui/views/reel/report/share_profile_item.dart';

final List<ShareProfileItem> _shareProfileItems = [
  ShareProfileItem(
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1744224571/ImageMagic/jwvonkoaqb7f1yjdbl0k.jpg',
    name: 'User 1',
  ),
  ShareProfileItem(
    name: 'User 2 with\na long name',
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1716401395/avatars/aklp5h4yyvfgxvxmmdnr.png',
  ),
  ShareProfileItem(
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1720980717/ImageMagic/brwscsudfwcojfjwvy2s.jpg',
    name: 'User 3',
  ),
  ShareProfileItem(
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1716146820/ImageMagic/orirbqmwf9io6q3dirva.ico',
    name: 'User 4',
  ),
  ShareProfileItem(
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1744224571/ImageMagic/jwvonkoaqb7f1yjdbl0k.jpg',
    name: 'User 5',
  ),
  ShareProfileItem(
    imageUrl:
        'https://res.cloudinary.com/dpmykt0af/image/upload/v1744224571/ImageMagic/jwvonkoaqb7f1yjdbl0k.jpg',
    name: 'User 6',
  ),
];

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({Key? key, required this.reelid}) : super(key: key);

  final String reelid;

  @override
  Widget build(BuildContext context) {
    final List<ShareGridActionItem> _shareGridActionItems = [
      ShareGridActionItem(
        icon: Icons.flag_outlined,
        label: 'Report',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          print('Tapped action: Report');
          Navigator.pop(context);

          final postReelBloc = context.read<ReelFeedAndActionBloc>();

          showReportFlow(
            context: context,
            reelId: reelid,
            bloc: postReelBloc,
          );
        },
      ),
      // ShareGridActionItem(
      //   icon: Icons.heart_broken_outlined,
      //   label: 'Not\ninterested',
      //   bgColor: Colors.grey.shade300,
      //   iconColor: Colors.black87,
      //   onTap: () {
      //     print('Tapped action: Not interested');
      //     Navigator.pop(context);
      //   },
      // ),
      ShareGridActionItem(
        icon: Icons.file_download_outlined,
        label: 'Save',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          print('Tapped action: Save');
          Navigator.pop(context);
        },
      ),
      ShareGridActionItem(
        icon: Icons.edit,
        label: 'Edit',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          print('Tapped action: Edit (reelid: $reelid)');

          final videoFeedState = context.read<ReelFeedAndActionBloc>().state;

          final Iterable<VideoItem> matchingVideos =
              videoFeedState.videos.where((video) => video.id == reelid);

          final VideoItem? videoToEdit =
              matchingVideos.isNotEmpty ? matchingVideos.first : null;

          if (videoToEdit != null) {
            print('Found video to edit: ${videoToEdit.id}');

            final initialEditData = {
              'reelId': videoToEdit.id,
              'videoUrl': videoToEdit.videoUrl,
              'initialDescription': videoToEdit.description,
              'initialPrivacy': videoToEdit.privacy,
              'initialAllowComments': videoToEdit.allowComments,
              'initialSaveToDevice': videoToEdit.allowSaveToDevice,
              'initialSaveWithWatermark': videoToEdit.saveWithWatermark,
              'initialAudienceControls': videoToEdit.audienceControlUnder18,
            };

            print(videoToEdit);
            print(initialEditData);

            Navigator.pop(context);

            context
                .push(
              RouterEnum.editPostScreen.routeName,
              extra: initialEditData,
            )
                .then((editedData) {
              if (editedData != null && editedData is Map<String, dynamic>) {
                print('Received edited data after editing: $editedData');
                // TODO: Here you would typically dispatch an event/call a method
              } else {
                print(
                  'Edit screen was closed without saving or returned null.',
                );
              }
            });
          } else {
            print('Video with id $reelid not found in state. Cannot edit.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not find video details to edit.'),
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
      ShareGridActionItem(
        icon: Icons.delete_outline,
        label: 'Delete',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          final deleteEvent = DeleteReel(reelId: reelid);
          context.read<ReelFeedAndActionBloc>().add(deleteEvent);
          Navigator.pop(context);
        },
      ),
      ShareGridActionItem(
        icon: Icons.copy, 
        label: 'Copy\nLink',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          print('Tapped action: Copy Link for reelid: $reelid');
          // TODO: Implement copy link functionality
          Navigator.pop(context);
        },
      ),
      ShareGridActionItem(
        icon: Icons.share, 
        label: 'Share\nto..',
        bgColor: Colors.grey.shade300,
        iconColor: Colors.black87,
        onTap: () {
          print('Tapped action: Share to for reelid: $reelid');
          // TODO: Implement platform share functionality
          Navigator.pop(context);
        },
      ),
    ];

    const double actionItemHeight = 48 + 4 + 40.0;
    const double actionListHeight = actionItemHeight;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                const Expanded(
                  child: Text(
                    'Send to',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 100.0, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _shareProfileItems.length,
              itemBuilder: (context, index) {
                final profile = _shareProfileItems[index];
                return GestureDetector(
                  onTap: () {
                    print('Tapped profile/app: ${profile.name}');
                    // TODO: Implement logic to share directly to this profile/app
                    Navigator.pop(context); 
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12.0),
                    width: 60, 
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        profile.imageUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider(
                                  profile.imageUrl,
                                ),
                                onBackgroundImageError: (e, stack) {
                                  print('Error loading image: $e');
                                },
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: profile.bgColor ??
                                    Colors.grey, 
                                child: profile.icon !=
                                        null 
                                    ? Icon(
                                        profile.icon,
                                        color:
                                            profile.iconColor ?? Colors.white,
                                        size: 30,
                                      )
                                    : null, 
                              ),
                        const SizedBox(height: 4),
                        Text(
                          profile.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(
            height: 32.0,
            thickness: 0.5,
            indent: 16.0,
            endIndent: 16.0,
          ),

          SizedBox(
            height: actionListHeight, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics:
                  const AlwaysScrollableScrollPhysics(), 
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _shareGridActionItems.length,
              itemBuilder: (context, index) {
                final action = _shareGridActionItems[index];
                return GestureDetector(
                  onTap: action.onTap,
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: action.bgColor,
                          child: Icon(
                            action.icon,
                            color: action.iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
