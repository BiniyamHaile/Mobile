import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/new_user.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostingScreen extends StatefulWidget {
  final dynamic post;

  const PostingScreen({super.key, this.post});

  @override
  _PostingScreenState createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedMedia = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
  final List<String> _existingMediaUrls = [];
  final List<User> _mentionableUsers = [];
  final List<String> _mentions = [];
  final LayerLink _mentionLayerLink = LayerLink();
  final FocusNode _textFocusNode = FocusNode();

  Post? _editingPost;
  bool _isSubmitting = false;
  bool _isLoadingMentions = false;
  String currentProfilePic = '';
  String currentUserFullname = '';
  OverlayEntry? _mentionOverlay;
  String _currentMentionQuery = '';
  int _currentMentionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePostData();
    fetchCurrentUserData();
    _loadMentionableUsers();
    _textFocusNode.addListener(_onTextFocusChange);
    _textController.addListener(_onTextChanged);
  }

  Future<List<User>> getCurrentUserFollowing() async {
    var prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token') ?? '';

    try {
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/following',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        print('Failed to fetch following users');
        return [];
      }
    } catch (e) {
      print('Error fetching following users: $e');
      return [];
    }
  }

  Future<void> fetchCurrentUserData() async {
    var prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token') ?? '';

    try {
      final loggedUser = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      currentProfilePic = loggedUser.data['profilePic'] ?? '';
      currentUserFullname =
          '${loggedUser.data['firstName']} ${loggedUser.data['lastName']}';

      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _loadMentionableUsers() async {
    setState(() => _isLoadingMentions = true);
    try {
      final users = await getCurrentUserFollowing();
      setState(() => _mentionableUsers.addAll(users));
    } catch (e) {
      print('Error loading mentionable users: $e');
    } finally {
      setState(() => _isLoadingMentions = false);
    }
  }

  void _initializePostData() {
    final post = widget.post;
    if (post != null && post is Post) {
      _editingPost = post;
      _textController.text = post.content;
      _existingMediaUrls.addAll(post.files);
      if (post.mentions != null) {
        _mentions.addAll(post.mentions!);
      }
    }
  }

  void _onTextFocusChange() {
    if (!_textFocusNode.hasFocus && _mentionOverlay != null) {
      _mentionOverlay?.remove();
      _mentionOverlay = null;
    }
  }

  void _onTextChanged() {
    final text = _textController.text;
    final mentionMatch = RegExp(r'@(\w*)$').firstMatch(text);
    if (mentionMatch != null) {
      _currentMentionQuery = mentionMatch.group(1) ?? '';
      _showMentionOverlay();
    } else if (_mentionOverlay != null) {
      _mentionOverlay?.remove();
      _mentionOverlay = null;
    }
  }

  void _showMentionOverlay() {
    if (_mentionOverlay != null) {
      _mentionOverlay?.remove();
    }

    final filteredUsers = _mentionableUsers.where((user) {
      final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
      final username = user.username?.toLowerCase() ?? '';
      return fullName.contains(_currentMentionQuery.toLowerCase()) ||
          username.contains(_currentMentionQuery.toLowerCase());
    }).toList();

    if (filteredUsers.isEmpty) return;

    _mentionOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _mentionLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 40),
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.profilePic != null
                          ? CachedNetworkImageProvider(user.profilePic!)
                          : null,
                      child: user.profilePic == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text('@${user.username}'),
                    onTap: () => _insertMention(user),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_mentionOverlay!);
  }

  void _insertMention(User user) {
    final text = _textController.text;
    final mentionStart = text.lastIndexOf('@');
    final newText = '${text.substring(0, mentionStart)}@${user.username} ';
    _textController.text = newText;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );

    if (!_mentions.contains(user.id)) {
      setState(() => _mentions.add(user.id));
    }

    _mentionOverlay?.remove();
    _mentionOverlay = null;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _selectedMedia.addAll(pickedFiles));
      }
    } catch (e) {
      if (mounted) _showError(AppStrings.errorSelectingPhotos.tr(context));
    }
  }

  Future<void> _pickVideos() async {
    if (!mounted) return;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result != null && mounted) {
        for (final file in result.files) {
          final filePath = file.path;
          if (filePath != null) {
            final controller = VideoPlayerController.file(File(filePath));
            await controller.initialize();
            controller.setLooping(true);
            controller.pause();
            if (mounted) {
              setState(() {
                _selectedMedia.add(XFile(filePath));
                _videoControllers[filePath] = controller;
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) _showError(AppStrings.errorSelectingVideos.tr(context));
    }
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() => _selectedMedia.add(pickedFile));
      }
    } catch (e) {
      if (mounted) _showError(AppStrings.errorTakingPhoto.tr(context));
    }
  }

  void _removeMedia(int index) {
    if (!mounted) return;
    if (index < _existingMediaUrls.length) {
      setState(() => _existingMediaUrls.removeAt(index));
    } else {
      final localIndex = index - _existingMediaUrls.length;
      final removed = _selectedMedia.removeAt(localIndex);
      _videoControllers.remove(removed.path)?.dispose();
      setState(() {});
    }
  }

  void _submitPost() {
    if (!mounted || _isSubmitting) return;

    final content = _textController.text.trim();
    if (content.isEmpty &&
        _selectedMedia.isEmpty &&
        _existingMediaUrls.isEmpty) {
      _showError(AppStrings.addContentToPost.tr(context));
      return;
    }

    setState(() => _isSubmitting = true);

    final postBloc = context.read<PostBloc>();
    if (postBloc.isClosed) {
      _showError(AppStrings.postingServiceUnavailable.tr(context));
      return;
    }

    if (_editingPost != null) {
      postBloc.add(
        UpdatePost(
          postId: _editingPost!.id,
          content: content,
          mediaFiles: _selectedMedia,
          mentions: _mentions,
        ),
      );
    } else {
      postBloc.add(
        CreatePost(
          content: content,
          mediaFiles: _selectedMedia,
          mentions: _mentions,
        ),
      );
    }
  }

  Widget _buildMediaPreview() {
    final totalItems = _existingMediaUrls.length + _selectedMedia.length;
    if (totalItems == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          AppStrings.mediaPreview.tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalItems, (index) {
              final isUrl = index < _existingMediaUrls.length;
              final path = isUrl
                  ? _existingMediaUrls[index]
                  : _selectedMedia[index - _existingMediaUrls.length].path;
              final isVideo =
                  path.toLowerCase().endsWith('.mp4') ||
                  path.toLowerCase().endsWith('.mov');

              Widget mediaWidget;
              if (isUrl) {
                mediaWidget = isVideo
                    ? Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            color: Colors.black12,
                          ),
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ],
                      )
                    : CachedNetworkImage(
                        imageUrl: path,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      );
              } else {
                mediaWidget = isVideo
                    ? (_videoControllers.containsKey(path)
                          ? AspectRatio(
                              aspectRatio:
                                  _videoControllers[path]!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(_videoControllers[path]!),
                                  Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                  const Icon(
                                    Icons.play_circle_fill,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          : const Center(child: CircularProgressIndicator()))
                    : Image.file(
                        File(path),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: mediaWidget,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMentionsPreview() {
    if (_mentions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          AppStrings.mentionedUsers.tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _mentions.map((userId) {
            final userIndex = _mentionableUsers.indexWhere(
              (u) => u.id == userId,
            );

            // User not found case
            if (userIndex == -1) {
              return Chip(
                avatar: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person_off, size: 16, color: Colors.white),
                ),
                label: Text(
                  'User not found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _mentions.remove(userId));
                  _removeMentionFromText(userId);
                },
                backgroundColor: Colors.grey[200],
              );
            }

            // User found case
            final user = _mentionableUsers[userIndex];
            return Chip(
              avatar: CircleAvatar(
                backgroundImage: user.profilePic != null
                    ? CachedNetworkImageProvider(user.profilePic!)
                    : null,
                child: user.profilePic == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              label: Text('@${user.username}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _mentions.remove(userId));
                _removeMentionFromText(user.username!);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _removeMentionFromText(String usernameOrId) {
    final username = usernameOrId.startsWith('@')
        ? usernameOrId.substring(1)
        : usernameOrId;
    _textController.text = _textController.text
        .replaceAll('@$username ', '')
        .replaceAll('@$username', '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _mentionOverlay?.remove();
    _videoControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostCreationSuccess || state is PostUpdateSuccess) {
          if (mounted) {
            setState(() => _isSubmitting = false);

            ScaffoldMessenger.of(context).clearSnackBars();

            if (state is PostCreationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.postCreatedSuccess.tr(context),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (state is PostUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text(AppStrings.postUpdatedSuccess.tr(context), style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }

            if (_editingPost != null) {
              _editingPost = null;
              _textController.clear();
              _selectedMedia.clear();
              _existingMediaUrls.clear();
              _mentions.clear();
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else if (state is PostCreationFailure || state is PostUpdateFailure) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            _showError(AppStrings.postCreationFailed.tr(context) + state.toString());
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (_isSubmitting) return;
              Navigator.pop(context);
            },
          ),
          title: Text(
            _editingPost != null ? AppStrings.editPost.tr(context) : AppStrings.createPost.tr(context),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              backgroundColor: Color.fromRGBO(143, 148, 251, 1),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: (currentProfilePic.isNotEmpty)
                              ? CachedNetworkImageProvider(currentProfilePic)
                              : null,
                          child: (currentProfilePic.isNotEmpty)
                              ? null
                              : Icon(Icons.person, color: Colors.grey.shade800),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          currentUserFullname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CompositedTransformTarget(
                      link: _mentionLayerLink,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          decoration: InputDecoration(
                            hintText: AppStrings.whatsOnYourMind.tr(context),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          maxLines: 8,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          minLines: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MediaButton(
                          icon: Icons.photo_library,
                          label: AppStrings.gallery.tr(context),
                          color: Colors.blue,
                          onPressed: _pickImage,
                        ),
                        _MediaButton(
                          icon: Icons.video_library,
                          label: AppStrings.video.tr(context),
                          color: Colors.purple,
                          onPressed: _pickVideos,
                        ),
                        _MediaButton(
                          icon: Icons.camera_alt,
                          label: AppStrings.camera.tr(context),
                          color: Colors.green,
                          onPressed: _takePhoto,
                        ),
                      ],
                    ),
                    _buildMediaPreview(),
                    _buildMentionsPreview(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _editingPost != null ? AppStrings.updatePost.tr(context) : AppStrings.createPost.tr(context),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 40),
          color: color,
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }
}
