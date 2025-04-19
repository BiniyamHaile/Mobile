import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Custom TextEditingController that highlights hashtags in blue.
class HashtagTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'(\#[a-zA-Z0-9_]+)');
    int start = 0;
    final matches = regex.allMatches(text);
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: style));
      }
      spans.add(TextSpan(text: match.group(0), style: style?.copyWith(color: Colors.blue)));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }
    return TextSpan(children: spans, style: style);
  }
}

/// Sample User model for mention suggestions.
class User {
  final String name;
  final String avatarUrl;
  User({required this.name, required this.avatarUrl});
}

/// Widget for displaying mention suggestions.
class MentionSuggestions extends StatelessWidget {
  final List<User> suggestions;
  final Function(User) onUserSelected;
  const MentionSuggestions({
    Key? key,
    required this.suggestions,
    required this.onUserSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: Container(
        // Approximate height: 60px per suggestion.
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        height: suggestions.length * 50.0,
        child: ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final user = suggestions[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              title: Text(user.name),
              onTap: () => onUserSelected(user),
            );
          },
        ),
      ),
    );
  }
}

class PostingScreen extends StatefulWidget {
  @override
  _PostingScreenState createState() => _PostingScreenState();

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (_) {
        return PostingScreen();
      },
    );
  }
}

class _PostingScreenState extends State<PostingScreen> {
  final HashtagTextEditingController _textController = HashtagTextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<XFile> _selectedVideos = [];

  // Sample user list for mention suggestions.
  List<User> sampleUsers = [
    User(name: "Alice", avatarUrl: "https://media.api-sports.io/football/players/50.png"),
    User(name: "Bob", avatarUrl: "https://media.api-sports.io/football/players/51.png"),
    User(name: "Charlie", avatarUrl: "https://media.api-sports.io/football/players/52.png"),
    User(name: "David", avatarUrl: "https://media.api-sports.io/football/players/53.png"),
    User(name: "Eve", avatarUrl: "https://media.api-sports.io/football/players/54.png"),
  ];

  List<User> filteredUsers = [];
  bool showMentionSuggestions = false;
  String mentionQuery = "";

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Called when the user taps the "Post" button.
  void _postContent() {
    print("Posting content: ${_textController.text}");
  }

  // Handle text changes to detect mention trigger (@) and filter users.
  void _handleTextChanged(String value) {
    final RegExp regExp = RegExp(r'@(\w+)$');
    final match = regExp.firstMatch(value);
    if (match != null) {
      setState(() {
        mentionQuery = match.group(1)!;
        filteredUsers = sampleUsers
            .where((user) =>
                user.name.toLowerCase().contains(mentionQuery.toLowerCase()))
            .toList();
        showMentionSuggestions = true;
      });
    } else {
      if (showMentionSuggestions) {
        setState(() {
          showMentionSuggestions = false;
        });
      }
    }
  }

  // Called when a user is selected from the mention suggestions.
  void _onUserSelected(User user) {
    final text = _textController.text;
    // Replace the last mention trigger with the selected user's name.
    final newText = text.replaceAll(RegExp(r'@(\w+)$'), '@${user.name} ');
    setState(() {
      _textController.text = newText;
      _textController.selection =
          TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
      showMentionSuggestions = false;
    });
  }

  // Called when the user taps the plus icon to add media.
  Future<void> _addMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Photo(s)'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
                    if (pickedFiles != null && pickedFiles.isNotEmpty) {
                      setState(() {
                        _selectedImages.addAll(pickedFiles);
                      });
                      print('Selected photos: ${pickedFiles.map((e) => e.path).toList()}');
                    } else {
                      print('No photo selected');
                    }
                  } catch (e) {
                    print('Error picking photos: $e');
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('Video'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedVideos.add(pickedFile);
                      });
                      print('Selected video: ${pickedFile.path}');
                    } else {
                      print('No video selected');
                    }
                  } catch (e) {
                    print('Error picking video: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Build the media preview section (images & videos).
  Widget _buildMediaPreview() {
    return Column(
      children: [
        // Display selected photos with an unselect icon.
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    children: [
                      Image.file(
                        File(_selectedImages[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        // Display selected videos as a thumbnail placeholder.
        if (_selectedVideos.isNotEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedVideos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        color: Colors.black12,
                        child: Center(
                          child: Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVideos.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 56.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row with "Create a Post", add media and post buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Create a Post", style: TextStyle(fontSize: 24)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _addMedia,
                        icon: Icon(Icons.add),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _postContent,
                        child: Text(
                          "Post",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              // Custom TextField for mentions and hashtags.
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                minLines: 10,
                maxLines: 10,
                onChanged: _handleTextChanged,
              ),
              // Display mention suggestions when applicable.
              if (showMentionSuggestions && filteredUsers.isNotEmpty)
                MentionSuggestions(
                  suggestions: filteredUsers,
                  onUserSelected: _onUserSelected,
                ),
              SizedBox(height: 10),
              _buildMediaPreview(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
