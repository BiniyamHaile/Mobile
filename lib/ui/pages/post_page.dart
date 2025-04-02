import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<XFile> _selectedVideos = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Called when the user taps the "Post" button
  void _postContent() {
    // Implement your posting logic here
    print("Posting content: ${_textController.text}");
  }

  // Called when the user taps the plus icon to add media
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
                    final List<XFile>? pickedFiles =
                        await _picker.pickMultiImage();
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
                    final XFile? pickedFile =
                        await _picker.pickVideo(source: ImageSource.gallery);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 56.0),
          child: Column(
            children: [
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
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                minLines: 10,
                maxLines: 10,
              ),
              SizedBox(height: 10),
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
                            // The image
                            Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            // The red unselect icon at top left
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
                            // Optionally, add an unselect icon for videos as well.
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
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
