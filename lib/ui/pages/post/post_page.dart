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
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostingScreen extends StatefulWidget {
  final dynamic post;

  const PostingScreen({Key? key, this.post}) : super(key: key);

  @override
  _PostingScreenState createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedMedia = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
  final List<String> _existingMediaUrls = [];
  final List<User> _mentionableUsers = [];
  final List<String> _mentions = [];
  final LayerLink _mentionLayerLink = LayerLink();
  OverlayEntry? _mentionOverlay;
  String _currentMentionQuery = '';
  bool _isSubmitting = false;
  bool _isLoadingMentions = false;
  String currentProfilePic = '';
  String currentUserFullname = '';
  Post? _editingPost;

  @override
  void initState() {
    super.initState();
    _initializePostData();
    fetchCurrentUserData();
    _loadMentionableUsers();
    _textFocusNode.addListener(_onTextFocusChange);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _mentionOverlay?.remove();
    for (var c in _videoControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initializePostData() {
    final post = widget.post;
    if (post is Post) {
      _editingPost = post;
      _textController.text = post.content;
      _existingMediaUrls.addAll(post.files);
      if (post.mentions != null) _mentions.addAll(post.mentions!);
    }
  }

  Future<void> fetchCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final resp = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      currentProfilePic = resp.data['profilePic'] ?? '';
      currentUserFullname =
          '${resp.data['firstName']} ${resp.data['lastName']}';
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<List<User>> getCurrentUserFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final resp = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/following',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (resp.statusCode == 200) {
        return (resp.data as List)
            .map((j) => User.fromJson(j))
            .toList();
      }
    } catch (e) {
      print('Error fetching following users: $e');
    }
    return [];
  }

  Future<void> _loadMentionableUsers() async {
    setState(() => _isLoadingMentions = true);
    try {
      final users = await getCurrentUserFollowing();
      _mentionableUsers.addAll(users);
    } catch (e) {
      print('Error loading mentionable users: $e');
    } finally {
      setState(() => _isLoadingMentions = false);
    }
  }

  void _onTextFocusChange() {
    if (!_textFocusNode.hasFocus) {
      _mentionOverlay?.remove();
      _mentionOverlay = null;
    }
  }

  void _onTextChanged() {
    final match = RegExp(r'@(\w*)$').firstMatch(_textController.text);
    if (match != null) {
      _currentMentionQuery = match.group(1) ?? '';
      _showMentionOverlay();
    } else {
      _mentionOverlay?.remove();
      _mentionOverlay = null;
    }
  }

  void _showMentionOverlay() {
    _mentionOverlay?.remove();
    final filtered = _mentionableUsers.where((u) {
      final full = '${u.firstName} ${u.lastName}'.toLowerCase();
      final usr = u.username?.toLowerCase() ?? '';
      return full.contains(_currentMentionQuery.toLowerCase()) ||
          usr.contains(_currentMentionQuery.toLowerCase());
    }).toList();
    if (filtered.isEmpty) return;

    final theme = AppTheme.getTheme(context);
    final isDark = theme.brightness == Brightness.dark;

    _mentionOverlay = OverlayEntry(
      builder: (_) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _mentionLayerLink,
          offset: const Offset(0, 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final u = filtered[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDark
                          ? AppTheme.appColors.darkGreyColor5
                          : AppTheme.appColors.accent2,
                      child:
                          Icon(Icons.person, color: theme.colorScheme.onSurface),
                    ),
                    title: Text(
                      '${u.firstName} ${u.lastName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text('@${u.username}',
                        style: theme.textTheme.bodySmall),
                    onTap: () => _insertMention(u),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)!.insert(_mentionOverlay!);
  }

  void _insertMention(User u) {
    final text = _textController.text;
    final idx = text.lastIndexOf('@');
    final newText = '${text.substring(0, idx)}@${u.username} ';
    _textController.text = newText;
    _textController.selection =
        TextSelection.fromPosition(TextPosition(offset: newText.length));
    if (!_mentions.contains(u.id)) _mentions.add(u.id);
    _mentionOverlay?.remove();
    _mentionOverlay = null;
  }

  void _removeMentionFromText(String name) {
    final uname = name.replaceFirst('@', '');
    _textController.text = _textController.text
        .replaceAll('@$uname ', '')
        .replaceAll('@$uname', '');
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    try {
      final imgs = await _picker.pickMultiImage(imageQuality: 85);
      if (imgs.isNotEmpty) setState(() => _selectedMedia.addAll(imgs));
    } catch (_) {
      _showError(AppStrings.errorSelectingPhotos.tr(context));
    }
  }

  Future<void> _pickVideos() async {
    if (!mounted) return;
    try {
      final res = await FilePicker.platform
          .pickFiles(type: FileType.video, allowMultiple: true);
      if (res != null) {
        for (var f in res.files) {
          if (f.path != null) {
            final c = VideoPlayerController.file(File(f.path!));
            await c.initialize();
            c.setLooping(true);
            c.pause();
            _selectedMedia.add(XFile(f.path!));
            _videoControllers[f.path!] = c;
          }
        }
        setState(() {});
      }
    } catch (_) {
      _showError(AppStrings.errorSelectingVideos.tr(context));
    }
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;
    try {
      final p = await _picker.pickImage(
          source: ImageSource.camera, imageQuality: 85);
      if (p != null) setState(() => _selectedMedia.add(p));
    } catch (_) {
      _showError(AppStrings.errorTakingPhoto.tr(context));
    }
  }

  void _removeMedia(int i) {
    if (i < _existingMediaUrls.length) {
      _existingMediaUrls.removeAt(i);
    } else {
      final removed = _selectedMedia.removeAt(i - _existingMediaUrls.length);
      _videoControllers.remove(removed.path)?.dispose();
    }
    setState(() {});
  }

  void _submitPost() {
    if (_isSubmitting) return;
    final content = _textController.text.trim();
    if (content.isEmpty &&
        _selectedMedia.isEmpty &&
        _existingMediaUrls.isEmpty) {
      _showError(AppStrings.addContentToPost.tr(context));
      return;
    }
    setState(() => _isSubmitting = true);
    final bloc = context.read<PostBloc>();
    if (bloc.isClosed) {
      _showError(AppStrings.postingServiceUnavailable.tr(context));
      return;
    }
    final event = _editingPost != null
        ? UpdatePost(
            postId: _editingPost!.id,
            content: content,
            mediaFiles: _selectedMedia,
            mentions: _mentions,
          )
        : CreatePost(
            content: content,
            mediaFiles: _selectedMedia,
            mentions: _mentions,
          );
    bloc.add(event);
  }

  void _showError(String message) {
    if (!mounted) return;
    final theme = AppTheme.getTheme(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onError),
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }

  Widget _buildMediaPreview(bool isDark) {
    final total = _existingMediaUrls.length + _selectedMedia.length;
    if (total == 0) return const SizedBox();
    final theme = AppTheme.getTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(AppStrings.mediaPreview.tr(context),
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(total, (i) {
              final isUrl = i < _existingMediaUrls.length;
              final path = isUrl
                  ? _existingMediaUrls[i]
                  : _selectedMedia[i - _existingMediaUrls.length].path;
              final isVideo = path.toLowerCase().endsWith('.mp4') ||
                  path.toLowerCase().endsWith('.mov');
              Widget w;
              if (isUrl) {
                if (isVideo) {
                  w = Stack(children: [
                    Container(
                      width: 120,
                      height: 120,
                      color: isDark
                          ? AppTheme.appColors.darkGreyColor5
                          : AppTheme.appColors.accent2,
                    ),
                    Center(
                        child: Icon(Icons.play_circle_fill,
                            size: 40, color: theme.colorScheme.onSurface)),
                  ]);
                } else {
                  w = CachedNetworkImage(
                    imageUrl: path,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 120,
                      height: 120,
                      color: isDark
                          ? AppTheme.appColors.darkGreyColor5
                          : AppTheme.appColors.accent2,
                      child: Center(
                          child: CircularProgressIndicator(
                              color: theme.colorScheme.onSurface)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: isDark
                          ? AppTheme.appColors.darkGreyColor5
                          : AppTheme.appColors.accent2,
                      child: Icon(Icons.broken_image,
                          color: theme.colorScheme.onSurface),
                    ),
                  );
                }
              } else {
                if (isVideo && _videoControllers.containsKey(path)) {
                  w = AspectRatio(
                    aspectRatio: _videoControllers[path]!.value.aspectRatio,
                    child: Stack(alignment: Alignment.center, children: [
                      VideoPlayer(_videoControllers[path]!),
                      Container(
                          color:
                              theme.colorScheme.surface.withOpacity(0.4)),
                      Icon(Icons.play_circle_fill,
                          size: 40, color: theme.colorScheme.onSurface),
                    ]),
                  );
                } else if (isVideo) {
                  w = Center(
                      child: CircularProgressIndicator(
                          color: theme.colorScheme.onSurface));
                } else {
                  w = Image.file(File(path),
                      width: 120, height: 120, fit: BoxFit.cover);
                }
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 120, height: 120, child: w),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _removeMedia(i),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 16, color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMentionsPreview(bool isDark) {
    if (_mentions.isEmpty) return const SizedBox();
    final theme = AppTheme.getTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(AppStrings.mentionedUsers.tr(context),
            style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _mentions.map((uid) {
            final idx = _mentionableUsers.indexWhere((u) => u.id == uid);
            if (idx == -1) {
              return Chip(
                avatar: CircleAvatar(
                    backgroundColor: theme.hintColor,
                    child: Icon(Icons.person_off,
                        size: 16, color: theme.colorScheme.onSurface)),
                label: Text(AppStrings.userNotFound.tr(context),
                    style: theme.textTheme.bodySmall),
                deleteIcon: Icon(Icons.close,
                    size: 16, color: theme.colorScheme.onSurface),
                onDeleted: () => setState(() => _mentions.remove(uid)),
                backgroundColor: isDark
                    ? AppTheme.appColors.darkGreyColor5
                    : AppTheme.appColors.accent2,
              );
            }
            final u = _mentionableUsers[idx];
            return Chip(
              avatar: CircleAvatar(
                backgroundImage: u.profilePic != null
                    ? CachedNetworkImageProvider(u.profilePic!)
                    : null,
                backgroundColor: isDark
                    ? AppTheme.appColors.darkGreyColor5
                    : AppTheme.appColors.accent2,
                child: u.profilePic == null
                    ? Icon(Icons.person,
                        size: 16, color: theme.colorScheme.onSurface)
                    : null,
              ),
              label: Text('@${u.username}', style: theme.textTheme.bodySmall),
              deleteIcon: Icon(Icons.close,
                  size: 16, color: theme.colorScheme.onSurface),
              onDeleted: () {
                setState(() => _mentions.remove(uid));
                _removeMentionFromText(u.username ?? uid);
              },
              backgroundColor: isDark
                  ? AppTheme.appColors.darkGreyColor5
                  : AppTheme.appColors.accent2,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<PostBloc, PostState>(
      listener: (ctx, state) {
        if (state is PostCreationSuccess || state is PostUpdateSuccess) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(ctx).clearSnackBars();
          final msg = state is PostCreationSuccess
              ? AppStrings.postCreatedSuccess.tr(ctx)
              : AppStrings.postUpdatedSuccess.tr(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(msg,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              backgroundColor: theme.colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.push(
              ctx, MaterialPageRoute(builder: (_) => const HomePage()));
        } else if (state is PostCreationFailure ||
            state is PostUpdateFailure) {
          setState(() => _isSubmitting = false);
          final err = state is PostCreationFailure
              ? AppStrings.postCreationFailed.tr(ctx)
              : AppStrings.postUpdateFailed.tr(ctx);
          _showError(err);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.onPrimary,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          ),
          title: Text(
            _editingPost != null
                ? AppStrings.editPost.tr(context)
                : AppStrings.createPost.tr(context),
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        body: Container(
          color: theme.colorScheme.surface,
          child: Column(
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
                            backgroundColor: isDark
                                ? AppTheme.appColors.darkGreyColor5
                                : AppTheme.appColors.accent2,
                            backgroundImage: currentProfilePic.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    currentProfilePic)
                                : null,
                            child: currentProfilePic.isEmpty
                                ? Icon(Icons.person,
                                    color: theme.colorScheme.onSurface)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(currentUserFullname,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CompositedTransformTarget(
                        link: _mentionLayerLink,
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          minLines: 4,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText:
                                AppStrings.whatsOnYourMind.tr(context),
                            hintStyle: theme.textTheme.bodyMedium
                                ?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor:
                                theme.colorScheme.surfaceVariant,
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
                            color: theme.colorScheme.primary,
                            iconColor: theme.colorScheme.primary,
                            onPressed: _pickImage,
                          ),
                          _MediaButton(
                            icon: Icons.video_library,
                            label: AppStrings.video.tr(context),
                            color: theme.colorScheme.primary,
                            iconColor: theme.colorScheme.primary,
                            onPressed: _pickVideos,
                          ),
                          _MediaButton(
                            icon: Icons.camera_alt,
                            label: AppStrings.camera.tr(context),
                            color: theme.colorScheme.primary,
                            iconColor: theme.colorScheme.primary,
                            onPressed: _takePhoto,
                          ),
                        ],
                      ),
                      _buildMediaPreview(isDark),
                      _buildMentionsPreview(isDark),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary)
                        : Text(
                            _editingPost != null
                                ? AppStrings.updatePost.tr(context)
                                : AppStrings.createPost.tr(context),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                                    color:
                                        theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: iconColor);
    return Column(
      children: [
        IconButton(icon: Icon(icon, size: 30), color: color, onPressed: onPressed),
        Text(label, style: textStyle),
      ],
    );
  }
}
