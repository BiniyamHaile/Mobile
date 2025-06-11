import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/user_suggestion.dart';
import 'package:mobile/ui/views/reel/upload/widgets/more_options_sheet_content.dart';
import 'package:mobile/ui/views/reel/upload/widgets/post_options_section.dart';
import 'package:mobile/ui/views/reel/upload/widgets/privacy_settings_sheet_content.dart';
import 'package:mobile/ui/views/reel/upload/widgets/suggestion_list_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

bool isWhitespace(String s) {
  return s == ' ' || s == '\n' || s == '\r' || s == '\t';
}

class EditPostScreen extends StatefulWidget {
  final String reelId;
  final String videoUrl;
  final String initialDescription;
  final PrivacyOption initialPrivacy;
  final bool initialAllowComments;
  final bool initialSaveToDevice;
  final bool initialSaveWithWatermark;
  final bool initialAudienceControls;

  const EditPostScreen({
    Key? key,
    required this.reelId,
    required this.videoUrl,
    required this.initialDescription,
    required this.initialPrivacy,
    required this.initialAllowComments,
    required this.initialSaveToDevice,
    required this.initialSaveWithWatermark,
    required this.initialAudienceControls,
  }) : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  String? _thumbnailPath;
  bool _isGeneratingThumbnail = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.initialDescription;

    context.read<PostDetailsBloc>().add(
      LoadInitialDetails(
        initialDescription: widget.initialDescription,
        initialPrivacy: widget.initialPrivacy,
        initialAllowComments: widget.initialAllowComments,
        initialSaveToDevice: widget.initialSaveToDevice,
        initialSaveWithWatermark: widget.initialSaveWithWatermark,
        initialAudienceControls: widget.initialAudienceControls,
        videoUrlForThumbnail: widget.videoUrl,
        videoPath: null,
      ),
    );

    _descriptionController.addListener(_onDescriptionControllerChanged);

    _generateThumbnailFromUrl(widget.videoUrl);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionControllerChanged);
    _descriptionController.dispose();
    if (_thumbnailPath != null) {
      try {
        File(_thumbnailPath!).delete();
      } catch (e) {
        print("Error deleting thumbnail file: $e");
      }
    }
    super.dispose();
  }

  Future<void> _generateThumbnailFromUrl(String videoUrl) async {
    if (mounted) {
      setState(() {
        _isGeneratingThumbnail = true;
        _thumbnailPath = null;
      });
    }

    File? tempVideoFile;

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_temp.mp4';
      tempVideoFile = File(tempFilePath);

      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        await tempVideoFile.writeAsBytes(response.bodyBytes);

        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: tempVideoFile.path,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 150,
          quality: 75,
        );

        if (mounted) {
          setState(() {
            _thumbnailPath = thumbnailPath;
          });
        }
      } else {
        print("Failed to download video: ${response.statusCode}");
      }
    } catch (e) {
      print("Error generating thumbnail from URL: $e");
    } finally {
      if (tempVideoFile != null && await tempVideoFile.exists()) {
        try {
          await tempVideoFile.delete();
        } catch (e) {
          print("Error deleting temp video file: $e");
        }
      }
      if (mounted) {
        setState(() {
          _isGeneratingThumbnail = false;
        });
      }
    }
  }

  void _onDescriptionControllerChanged() {
    context.read<PostDetailsBloc>().add(
      DescriptionChanged(
        _descriptionController.text,
        _descriptionController.selection,
      ),
    );
  }

  int _findWordStartIndex(String text, int cursorPosition) {
    if (cursorPosition <= 0) return 0;
    int i = cursorPosition - 1;
    while (i >= 0 && i < text.length && !isWhitespace(text[i])) {
      i--;
    }
    if (i < 0) return 0;
    return i + 1;
  }

  void _insertSuggestion(
    String textToInsert, {
    UserSuggestion? userSuggestion,
  }) {
    final currentText = _descriptionController.text;
    final cursorPosition = _descriptionController.selection.baseOffset;

    int wordStartIndex = _findWordStartIndex(currentText, cursorPosition);

    String finalSuggestionText = textToInsert;
    bool shouldAddSpace =
        !finalSuggestionText.endsWith(' ') &&
        (cursorPosition == currentText.length ||
            (cursorPosition < currentText.length &&
                isWhitespace(currentText[cursorPosition])) ||
            cursorPosition == 0);

    if (shouldAddSpace) {
      finalSuggestionText += ' ';
    }

    int effectiveReplaceStartIndex = wordStartIndex;

    final newText = currentText.replaceRange(
      effectiveReplaceStartIndex,
      cursorPosition,
      finalSuggestionText,
    );
    final int newCursorPosition =
        effectiveReplaceStartIndex + finalSuggestionText.length;
    final newSelection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );

    _descriptionController.removeListener(_onDescriptionControllerChanged);
    _descriptionController.value = TextEditingValue(
      text: newText,
      selection: newSelection,
    );
    _descriptionController.addListener(_onDescriptionControllerChanged);

    context.read<PostDetailsBloc>().add(
      SuggestionSelected(textToInsert, userSuggestion: userSuggestion),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showModalBottomSheet<PrivacyOption>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: context.read<PostDetailsBloc>(),
          child: PrivacySettingsSheetContent(
            initialPrivacy: sheetContext
                .read<PostDetailsBloc>()
                .state
                .selectedPrivacy,
            onPrivacySelected: (newPrivacy) {
              sheetContext.read<PostDetailsBloc>().add(
                UpdatePrivacyOption(newPrivacy as PrivacyOption),
              );
            },
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: context.read<PostDetailsBloc>(),
          child: StatefulBuilder(
            builder:
                (BuildContext innerSheetContext, StateSetter sheetSetState) {
                  final detailsState = innerSheetContext
                      .watch<PostDetailsBloc>()
                      .state;

                  return MoreOptionsSheetContent(
                    allowComments: detailsState.allowComments,
                    saveToDevice: detailsState.saveToDevice,
                    saveWithWatermark: detailsState.saveWithWatermark,
                    audienceControls: detailsState.audienceControls,
                    onAllowCommentsChanged: (newValue) {
                      innerSheetContext.read<PostDetailsBloc>().add(
                        UpdateAllowCommentsOption(newValue),
                      );
                    },
                    onSaveToDeviceChanged: (newValue) {
                      innerSheetContext.read<PostDetailsBloc>().add(
                        UpdateSaveToDeviceOption(newValue),
                      );
                    },
                    onSaveWithWatermarkChanged: (newValue) {
                      innerSheetContext.read<PostDetailsBloc>().add(
                        UpdateSaveWithWatermarkOption(newValue),
                      );
                    },
                    onAudienceControlsChanged: (newValue) {
                      innerSheetContext.read<PostDetailsBloc>().add(
                        UpdateAudienceControlsOption(newValue),
                      );
                    },
                  );
                },
          ),
        );
      },
    );
  }

  void _saveChanges() {
    final currentDetailsState = context.read<PostDetailsBloc>().state;

    final updateEvent = UpdateReel(
      reelId: widget.reelId,
      description: _descriptionController.text,
      mentionedUsers: currentDetailsState.mentionedUsers,
      privacy: currentDetailsState.selectedPrivacy,
      allowComments: currentDetailsState.allowComments,
      allowSaveToDevice: currentDetailsState.saveToDevice,
      saveWithWatermark: currentDetailsState.saveWithWatermark,
      audienceControlUnder18: currentDetailsState.audienceControls,
    );

    print("Saving Changes - Dispatching UpdateReel Event: $updateEvent");

    context.read<ReelFeedAndActionBloc>().add(updateEvent);
  }

  @override
  Widget build(BuildContext context) {
    final postDetailsState = context.watch<PostDetailsBloc>().state;

    final postReelState = context.watch<ReelFeedAndActionBloc>().state;
    final bool isLoading = postReelState == ReelActionStatus.loading;

    bool showSuggestions = postDetailsState.activeSuggestionType != '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isLoading) {
              return;
            }
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit Post'),
      ),
      body: BlocListener<ReelFeedAndActionBloc, ReelFeedAndActionState>(
        listener: (context, state) {
          if (state.actionStatus == ReelActionStatus.updateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Reel updated successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
            context.pop(true);
          } else if (state.actionStatus == ReelActionStatus.updateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Failed to update reel: ${state.lastActionError}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (postDetailsState.activeSuggestionType != '') {
              context.read<PostDetailsBloc>().add(
                const HideSuggestions(suggestionType: ''),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 150,
                        child: TextFormField(
                          controller: _descriptionController,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Edit description...',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_thumbnailPath != null)
                                  Image.file(
                                    File(_thumbnailPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                else if (_isGeneratingThumbnail)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  Center(
                                    child: Icon(
                                      Icons.videocam_off,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        AppBar().preferredSize.height -
                        16.0 -
                        150.0 -
                        16.0 -
                        (kBottomNavigationBarHeight + 8.0),
                  ),
                  child: Column(
                    children: [
                      if (showSuggestions)
                        Expanded(
                          child: SuggestionListView(
                            hashtags: postDetailsState.filteredHashtags,
                            users: postDetailsState.filteredUsers,
                            activeType: postDetailsState.activeSuggestionType,
                            onSuggestionSelected: _insertSuggestion,
                          ),
                        )
                      else
                        PostOptionsSection(
                          selectedPrivacy: postDetailsState.selectedPrivacy,
                          onPrivacyTap: () => _showPrivacySettings(context),
                          onMoreOptionsTap: () => _showMoreOptions(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child:
                    BlocBuilder<ReelFeedAndActionBloc, ReelFeedAndActionState>(
                      builder: (context, state) {
                        final bool buttonIsLoading =
                            state.actionStatus == ReelActionStatus.loading;
                        debugPrint("buttonIsLoading $buttonIsLoading");
                        return ElevatedButton.icon(
                          onPressed: buttonIsLoading ? null : _saveChanges,
                          icon: buttonIsLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: buttonIsLoading
                              ? const Text('Saving...')
                              : const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
