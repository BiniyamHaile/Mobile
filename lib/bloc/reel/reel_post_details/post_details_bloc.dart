import 'package:bloc/bloc.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_event.dart';
import 'package:mobile/bloc/reel/reel_post_details/post_details_state.dart';
import 'package:mobile/models/reel/hashtag_suggestion.dart';
import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/user_suggestion.dart';
import 'package:mobile/services/utls/list_equality.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

bool isWhitespace(String s) {
  return s == ' ' || s == '\n' || s == '\r' || s == '\t';
}

int _findWordStartIndex(String text, int cursorPosition) {
    if (cursorPosition <= 0) return 0;
    int i = cursorPosition - 1;
    while (i >= 0 && !isWhitespace(text[i])) {
        i--;
    }
    return i + 1;
}

final _uuid = const Uuid();


class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final List<HashtagSuggestion> _simulatedHashtags = [
    HashtagSuggestion('ethiopian_tik_tok', '16.0M posts'),
    HashtagSuggestion('ethiopia', '12.6M posts'),
    HashtagSuggestion('orthodox', '2.1M posts'),
    HashtagSuggestion('funny', '1.3M posts'),
    HashtagSuggestion('habesha', '1.1M posts'),
     HashtagSuggestion('ethiopianmusic', '557.3K posts'),
    HashtagSuggestion('art', '289.9K posts'),
    HashtagSuggestion('dance', '351.1K posts'),
    HashtagSuggestion('travel', '541.9K posts'),
    HashtagSuggestion('food', '490.2K posts'),
    HashtagSuggestion('nature', '380.5K posts'),
    HashtagSuggestion('technology', '210.7K posts'),
    HashtagSuggestion('fashion', '620.8K posts'),
    HashtagSuggestion('sports', '450.1K posts'),
    HashtagSuggestion('education', '180.3K posts'),
    HashtagSuggestion('business', '250.6K posts'),
    HashtagSuggestion('health', '310.9K posts'),
    HashtagSuggestion('coding', '150.0K posts'),
    HashtagSuggestion('photography', '700.0K posts'),
    HashtagSuggestion('motivation', '580.4K posts'),
  ];

  final List<UserSuggestion> _simulatedUsers = [
    UserSuggestion(id: _uuid.v4(), name: 'Abebe Kebede', username: 'abebe_k', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Tigist Lemma', username: 'tigist_l', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Biruk Tesfaye', username: 'biruk_t', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Sara Getachew', username: 'sara_g', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Dawit Mekonnen', username: 'dawit_m', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Elsa Demise', username: 'elsa_d', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Fitsum Adane', username: 'fitsum_a', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Genet Hailu', username: 'genet_h', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Haile Gebre', username: 'haile_g', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
    UserSuggestion(id: _uuid.v4(), name: 'Ibrahim Ali', username: 'ibrahim_a', imageUrl: 'https://res.cloudinary.com/dpmykt0af/image/upload/v1718263493/uw0ntdwx2qryozprp61n.png'),
  ];


  PostDetailsBloc() : super(PostDetailsState.initial()) {
    on<LoadInitialDetails>(_onLoadInitialDetails);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<HideSuggestions>(_onHideSuggestions);
    on<UpdatePrivacyOption>(_onUpdatePrivacyOption);
    on<UpdateAllowCommentsOption>(_onUpdateAllowCommentsOption);
    on<UpdateSaveToDeviceOption>(_onUpdateSaveToDeviceOption);
    on<UpdateSaveWithWatermarkOption>(_onUpdateSaveWithWatermarkOption);
    on<UpdateAudienceControlsOption>(_onUpdateAudienceControlsOption);
  }

   @override
  void onChange(Change<PostDetailsState> change) {
    super.onChange(change);
    print('PostDetailsBloc State Change: ${change.currentState} -> ${change.nextState}');
     print('New State Mentioned Users: ${change.nextState.mentionedUsers}');
  }

  List<MentionedUser> _parseMentions(String text) {
    final RegExp mentionRegex = RegExp(r'@([\w.-]+)');
    final List<MentionedUser> foundMentions = [];
    final Set<String> addedUserIds = {};

    Iterable<RegExpMatch> matches = mentionRegex.allMatches(text);

    for (final match in matches) {
      final String? username = match.group(1);
      if (username != null && username.isNotEmpty) {
        final UserSuggestion? user = _simulatedUsers.firstWhereOrNull(
          (u) => u.username == username,
        );
        if (user != null) {
          if (!addedUserIds.contains(user.id)) {
             foundMentions.add(MentionedUser(userId: user.id, username: user.username));
             addedUserIds.add(user.id);
          }
        }
      }
    }
    return foundMentions;
  }

  Future<void> _onLoadInitialDetails(LoadInitialDetails event, Emitter<PostDetailsState> emit) async {
     print('Handling LoadInitialDetails event...');

     PostDetailsState nextState = state.copyWith();

    if (event.videoPath != null) {
      print('Loading details for new video from path: ${event.videoPath}');
      nextState = nextState.copyWith(
         descriptionText: '',
         selectedPrivacy: PrivacyOption.onlyYou,
         allowComments: true,
         saveToDevice: true,
         saveWithWatermark: false,
         audienceControls: false,
         mentionedUsers: [],
         durationInSeconds: 0,
         thumbnailPath: null,
      );

      try {
        final tempDir = await getTemporaryDirectory();
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: event.videoPath!,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 150,
          quality: 75,
        );
       if (thumbnailPath != null) {
         nextState = nextState.copyWith(thumbnailPath: thumbnailPath);
       } else {
          print('Thumbnail generation from path failed.');
       }
      } catch (e) {
        print("Error generating thumbnail from path in Bloc: $e");
      }

      VideoPlayerController? controller;
      try {
        controller = VideoPlayerController.file(File(event.videoPath!));
        await controller.initialize();
        nextState = nextState.copyWith(durationInSeconds: controller.value.duration.inSeconds);
       print('Video Duration from path loaded: ${nextState.durationInSeconds} seconds');
      } catch (e) {
        print("Error getting duration from path in Bloc: $e");
      } finally {
         controller?.dispose();
      }

    } else if (event.initialDescription != null) {
       print('Loading details for editing post...');
       nextState = nextState.copyWith(
         descriptionText: event.initialDescription!,
         selectedPrivacy: event.initialPrivacy ?? PrivacyOption.onlyYou,
         allowComments: event.initialAllowComments ?? true,
         saveToDevice: event.initialSaveToDevice ?? true,
         saveWithWatermark: event.initialSaveWithWatermark ?? false,
         audienceControls: event.initialAudienceControls ?? false,
         durationInSeconds: 0,
         thumbnailPath: null,
        //  isPremiumContent: false,
      );

       final initialMentionedUsers = _parseMentions(event.initialDescription!);
       nextState = nextState.copyWith(mentionedUsers: initialMentionedUsers);
       print('Parsed initial mentioned users: ${initialMentionedUsers.map((u) => u.username).join(', ')}');


      if (event.videoUrlForThumbnail != null) {
        print('Generating thumbnail from URL: ${event.videoUrlForThumbnail}');
         _generateThumbnailFromUrl(event.videoUrlForThumbnail!, emit);
      } else {
          print('No video URL provided for thumbnail in edit mode.');
      }
    } else {
       print('LoadInitialDetails called without videoPath or initialDescription.');
       nextState = PostDetailsState.initial();
    }

     if (state != nextState) {
       emit(nextState);
     } else {
        print('LoadInitialDetails did not result in a state change (state was already the same).');
     }

     print('Finished handling LoadInitialDetails event.');
  }

   Future<void> _generateThumbnailFromUrl(String videoUrl, Emitter<PostDetailsState> emit) async {
      File? tempVideoFile;
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_temp.mp4';
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

          if (thumbnailPath != null) {
             emit(state.copyWith(thumbnailPath: thumbnailPath));
             print('Thumbnail generated from URL: $thumbnailPath');
          } else {
             print('Thumbnail generation from URL returned null.');
          }
        } else {
          print("Failed to download video for thumbnail: ${response.statusCode}");
        }
      } catch (e) {
        print("Error generating thumbnail from URL in Bloc: $e");
      } finally {
        if (tempVideoFile != null && await tempVideoFile.exists()) {
          try {
            await tempVideoFile.delete();
          } catch(e) {
             print("Error deleting temp video file for thumbnail: $e");
          }
        }
      }
   }


  void _onDescriptionChanged(DescriptionChanged event, Emitter<PostDetailsState> emit) {
      final text = event.text;
      final cursorPosition = event.selection.baseOffset;

      String potentialWord = '';
      int wordStartIndex = -1;

      if (cursorPosition > 0) {
          wordStartIndex = _findWordStartIndex(text, cursorPosition);
           if (wordStartIndex >= 0 && wordStartIndex <= text.length) {
             potentialWord = text.substring(wordStartIndex, cursorPosition);
          }
      } else {
           wordStartIndex = 0;
      }


      String nextActiveSuggestionType = '';
      String filterText = '';
      List<HashtagSuggestion> nextFilteredHashtags = [];
      List<UserSuggestion> nextFilteredUsers = [];


      if (potentialWord.startsWith('#')) {
          nextActiveSuggestionType = '#';
          filterText = potentialWord.substring(1);
          nextFilteredHashtags = _filterHashtags(filterText);
          nextFilteredUsers = [];
      } else if (potentialWord.startsWith('@')) {
          nextActiveSuggestionType = '@';
          filterText = potentialWord.substring(1);
          nextFilteredUsers = _filterUsers(filterText);
          nextFilteredHashtags = [];
      } else {
          nextActiveSuggestionType = '';
          nextFilteredHashtags = [];
          nextFilteredUsers = [];
      }

      final List<MentionedUser> updatedMentionedUsers = _parseMentions(text);

       final bool hashtagsChanged = !listsEqual(state.filteredHashtags, nextFilteredHashtags);
       final bool usersChanged = !listsEqual(state.filteredUsers, nextFilteredUsers);
       final bool mentionedUsersChanged = !listsEqual(state.mentionedUsers, updatedMentionedUsers);


      if (state.descriptionText != text ||
           state.activeSuggestionType != nextActiveSuggestionType ||
           hashtagsChanged ||
           usersChanged ||
           mentionedUsersChanged
           ) {
             emit(state.copyWith(
                 descriptionText: text,
                 filteredHashtags: nextFilteredHashtags,
                 filteredUsers: nextFilteredUsers,
                 activeSuggestionType: nextActiveSuggestionType,
                 mentionedUsers: updatedMentionedUsers,
             ));
       }
  }


  List<HashtagSuggestion> _filterHashtags(String filterText) {
    if (filterText.isEmpty) {
      return _simulatedHashtags.take(10).toList();
    }
    return _simulatedHashtags
        .where((h) => h.hashtag.toLowerCase().startsWith(filterText.toLowerCase()))
        .toList();
  }

  List<UserSuggestion> _filterUsers(String filterText) {
     if (filterText.isEmpty) {
      return _simulatedUsers.take(10).toList();
    }
    return _simulatedUsers
        .where((u) =>
            u.username.toLowerCase().startsWith(filterText.toLowerCase()) ||
            u.name.toLowerCase().startsWith(filterText.toLowerCase()))
        .toList();
  }

  void _onSuggestionSelected(SuggestionSelected event, Emitter<PostDetailsState> emit) {
      print('Handling SuggestionSelected event...');

       if (state.activeSuggestionType != '' || state.filteredHashtags.isNotEmpty || state.filteredUsers.isNotEmpty) {
           emit(state.copyWith(
             filteredHashtags: [],
             filteredUsers: [],
             activeSuggestionType: '',
           ));
           print('Suggestion state cleared.');
       } else {
          print('SuggestionSelected event did not result in a state change (suggestions already hidden).');
       }
        print('Finished handling SuggestionSelected event.');
  }

  void _onHideSuggestions(HideSuggestions event, Emitter<PostDetailsState> emit) {
       print('Handling HideSuggestions event...');
      if (state.activeSuggestionType != '') {
        emit(state.copyWith(
            filteredHashtags: [],
            filteredUsers: [],
            activeSuggestionType: '',
        ));
      } else {
         print('HideSuggestions event did not result in a state change.');
      }
       print('Finished handling HideSuggestions event.');
  }

  void _onUpdatePrivacyOption(UpdatePrivacyOption event, Emitter<PostDetailsState> emit) {
     print('Handling UpdatePrivacyOption event: ${event.privacy}');
     if (state.selectedPrivacy != event.privacy) {
        emit(state.copyWith(selectedPrivacy: event.privacy));
     } else {
         print('UpdatePrivacyOption event did not result in a state change.');
     }
      print('Finished handling UpdatePrivacyOption event.');
  }

  void _onUpdateAllowCommentsOption(UpdateAllowCommentsOption event, Emitter<PostDetailsState> emit) {
     print('Handling UpdateAllowCommentsOption event: ${event.allowed}');
     if (state.allowComments != event.allowed) {
        emit(state.copyWith(allowComments: event.allowed));
     } else {
         print('UpdateAllowCommentsOption event did not result in a state change.');
     }
      print('Finished handling UpdateAllowCommentsOption event.');
  }

  void _onUpdateSaveToDeviceOption(UpdateSaveToDeviceOption event, Emitter<PostDetailsState> emit) {
     print('Handling UpdateSaveToDeviceOption event: ${event.save}');
      if (state.saveToDevice != event.save) {
         emit(state.copyWith(saveToDevice: event.save));
      } else {
         print('UpdateSaveToDeviceOption event did not result in a state change.');
      }
       print('Finished handling UpdateSaveToDeviceOption event.');
  }

  void _onUpdateSaveWithWatermarkOption(UpdateSaveWithWatermarkOption event, Emitter<PostDetailsState> emit) {
     print('Handling UpdateSaveWithWatermarkOption event: ${event.withWatermark}');
      if (state.saveWithWatermark != event.withWatermark) {
         emit(state.copyWith(saveWithWatermark: event.withWatermark));
      } else {
         print('UpdateSaveWithWatermarkOption event did not result in a state change.');
      }
       print('Finished handling UpdateSaveWithWatermarkOption event.');
  }

  void _onUpdateAudienceControlsOption(UpdateAudienceControlsOption event, Emitter<PostDetailsState> emit) {
      print('Handling UpdateAudienceControlsOption event: ${event.controlsEnabled}');
      if (state.audienceControls != event.controlsEnabled) {
          emit(state.copyWith(audienceControls: event.controlsEnabled));
      } else {
         print('UpdateAudienceControlsOption event did not result in a state change.');
      }
      print('Finished handling UpdateAudienceControlsOption event.');
  }
}