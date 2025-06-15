import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/user_suggestion.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';

import 'widgets/more_options_sheet_content.dart';
import 'widgets/post_options_section.dart';
import 'widgets/privacy_settings_sheet_content.dart';
import 'widgets/suggestion_list_view.dart';

bool isWhitespace(String s) {
  return s == ' ' || s == '\n' || s == '\r' || s == '\t';
}

class PostScreen extends StatefulWidget {
  final String videoPath;

  const PostScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PostDetailsBloc>().add(
      LoadInitialDetails(
        videoUrlForThumbnail: widget.videoPath,
        videoPath: widget.videoPath,
      ),
    );

    _descriptionController.addListener(_onDescriptionControllerChanged);
  }

  void _onDescriptionControllerChanged() {
    context.read<PostDetailsBloc>().add(
      DescriptionChanged(
        _descriptionController.text,
        _descriptionController.selection,
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onDescriptionControllerChanged);
    _descriptionController.dispose();
    super.dispose();
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
                UpdatePrivacyOption(newPrivacy),
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

  @override
  Widget build(BuildContext context) {
    final postDetailsState = context.watch<PostDetailsBloc>().state;

    final postReelState = context.watch<ReelFeedAndActionBloc>().state;
    final bool isLoading = postReelState == ReelActionStatus.loading;

    bool showSuggestions = postDetailsState.activeSuggestionType != '';
    bool showDefaultOptions = !showSuggestions;

        final theme = AppTheme.getTheme(context);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back,color: theme.colorScheme.primary,),
          onPressed: () {
            if (isLoading) {
              return;
            }
            Navigator.pop(context);
          },
        ),
        title:  Text('Create Post',style: TextStyle(color: theme.colorScheme.primary),),
      ),
      body: BlocListener<ReelFeedAndActionBloc, ReelFeedAndActionState>(
        listenWhen: (previousState, currentState) {
          return previousState.actionStatus != currentState.actionStatus;
        },
        listener: (context, state) {
          if (state.actionStatus == ReelActionStatus.postSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  'Reel posted successfully!',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            );

            context.read<ReelFeedAndActionBloc>().add(
              const MarkMoreVideosAvailable(),
            );

            context.go(RouterEnum.videoFeedView.routeName);
          } else if (state.actionStatus == ReelActionStatus.postFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  'Failed to post reel: ${state.lastActionError}',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            context.read<PostDetailsBloc>().add(
              const HideSuggestions(suggestionType: ''),
            );
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
                          decoration:  InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.onPrimary,
                            hintText: 'Add description...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.primary.withOpacity(0.6),
                            ),
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
                            color: theme.colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (postDetailsState.thumbnailPath != null)
                                  Image.file(
                                    File(postDetailsState.thumbnailPath!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                else
                                  const Center(
                                    child: CircularProgressIndicator(),
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
            // Expanded(
            //   child: TextButton.icon(
            //     onPressed: isLoading
            //         ? null
            //         : () {
            //             print('Drafts tapped');
            //           },
            //     icon: const Icon(Icons.save),
            //     label: const Text('Drafts'),
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BlocBuilder<ReelFeedAndActionBloc, ReelFeedAndActionState>(
                  builder: (context, state) {
                    final bool buttonIsLoading =
                        state.actionStatus == ReelActionStatus.loading;

                    return ElevatedButton.icon(
                      onPressed: buttonIsLoading
                          ? null
                          : () {
                              final currentDetailsState = context
                                  .read<PostDetailsBloc>()
                                  .state;

                              if (currentDetailsState.durationInSeconds == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      'Please wait, video duration is loading...',
                                      style: TextStyle(color: theme.colorScheme.primary),
                                    ),
                                  ),
                                );
                                return;
                              }

                              final List<MentionedUser> mentionedUsersToPost =
                                  currentDetailsState.mentionedUsers;

                              print(
                                "Post Button Tapped - Current Details State: ${currentDetailsState}",
                              );

                              context.read<ReelFeedAndActionBloc>().add(
                                PostReel(
                                  videoPath: widget.videoPath,
                                  description: _descriptionController.text,
                                  duration:
                                      currentDetailsState.durationInSeconds,
                                  isPremiumContent: false,
                                  mentionedUsers: mentionedUsersToPost,
                                  selectedPrivacy:
                                      currentDetailsState.selectedPrivacy,
                                  allowComments:
                                      currentDetailsState.allowComments,
                                  allowSaveToDevice:
                                      currentDetailsState.saveToDevice,
                                  saveWithWatermark:
                                      currentDetailsState.saveWithWatermark,
                                  audienceControlUnder18:
                                      currentDetailsState.audienceControls,
                                ),
                              );
                            },
                      icon: buttonIsLoading
                          ?  SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                                strokeWidth: 3,
                              ),
                            )
                          :  Icon(Icons.send, color: theme.colorScheme.primary,),
                      label: buttonIsLoading
                          ?  Text('Posting...', style: TextStyle(color: theme.colorScheme.primary),)
                          :  Text('Post',style: TextStyle(color: theme.colorScheme.primary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.onPrimary,
                        foregroundColor: theme.colorScheme.primary,
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
