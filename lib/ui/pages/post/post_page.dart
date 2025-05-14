import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';

import 'package:video_player/video_player.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:file_picker/file_picker.dart';

import 'package:mobile/models/post.dart';

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

  Post? _editingPost;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializePostData();
  }

  void _initializePostData() {
    final post = widget.post;
    if (post != null && post is Post) {
      _editingPost = post;
      _textController.text = post.content;
      _existingMediaUrls.addAll(post.files);
    }
  }

  Future<void> _pickImage() async {
    if (!mounted) return;
    try {
      final List<XFile> pickedFiles =
          await _picker.pickMultiImage(imageQuality: 85);
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _selectedMedia.addAll(pickedFiles));
      }
    } catch (e) {
      if (mounted) _showError('Error selecting photos');
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
      if (mounted) _showError('Error selecting videos');
    }
  }

  Future<void> _takePhoto() async {
    if (!mounted) return;
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (pickedFile != null && mounted) {
        setState(() => _selectedMedia.add(pickedFile));
      }
    } catch (e) {
      if (mounted) _showError('Error taking photo');
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
      _showError('Please add some content to post');
      return;
    }

    setState(() => _isSubmitting = true);

    final postBloc = context.read<PostBloc>();
    if (postBloc.isClosed) {
      _showError('Posting service unavailable');
      return;
    }

    if (_editingPost != null) {
      postBloc.add(UpdatePost(
        postId: _editingPost!.id,
        content: content,
        mediaFiles: _selectedMedia,
      ));
    } else {
      postBloc.add(CreatePost(
        content: content,
        mediaFiles: _selectedMedia,
      ));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildMediaPreview() {
    final totalItems = _existingMediaUrls.length + _selectedMedia.length;
    if (totalItems == 0) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Media Preview',
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
              final isVideo = path.toLowerCase().endsWith('.mp4') ||
                  path.toLowerCase().endsWith('.mov');

              Widget mediaWidget;
              if (isUrl) {
                mediaWidget = isVideo
                    ? Stack(
                        children: [
                          Container(
                              width: 120, height: 120, color: Colors.black12),
                          const Center(
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 40)),
                        ],
                      )
                    : Image.network(path,
                        width: 120, height: 120, fit: BoxFit.cover);
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
                                Container(color: Colors.black.withOpacity(0.4)),
                                const Icon(Icons.play_circle_fill,
                                    size: 40, color: Colors.white),
                              ],
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()))
                    : Image.file(File(path),
                        width: 120, height: 120, fit: BoxFit.cover);
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          SizedBox(width: 120, height: 120, child: mediaWidget),
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
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
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

  @override
  void dispose() {
    _textController.dispose();
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _editingPost != null
                      ? 'Post Updated Successfully'
                      : 'Post Created Successfully',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (_editingPost != null) {
              _editingPost = null;
              _textController.clear();
              _selectedMedia.clear();
              _existingMediaUrls.clear();
            }

            // Optionally, you can navigate back or refresh the feed
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FeedPage()));
            // Navigator.pop(context);
          }
        } else if (state is PostCreationFailure || state is PostUpdateFailure) {
          if (mounted) {
            setState(() => _isSubmitting = false);
            _showError("Post creation failed: ${state}");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (_isSubmitting) return;
              Navigator.pop(context);
            },
          ),
          title: Text(
            _editingPost != null ? 'Edit Post' : 'Create Post',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        SizedBox(width: 10),
                        Text('Dawit Minale',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MediaButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          color: Colors.blue,
                          onPressed: _pickImage,
                        ),
                        _MediaButton(
                          icon: Icons.video_library,
                          label: 'Video',
                          color: Colors.purple,
                          onPressed: _pickVideos,
                        ),
                        _MediaButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          color: Colors.green,
                          onPressed: _takePhoto,
                        ),
                      ],
                    ),
                    _buildMediaPreview(),
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
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _editingPost != null ? 'Update Post' : 'Create Post'),
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
