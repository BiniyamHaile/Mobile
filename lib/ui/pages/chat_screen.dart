import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:mobile/models/message_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.user, required this.friend, required this.initialMessages});

  final types.User user;
  final types.User friend;
  final List<ChatMessage> initialMessages;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];

  types.TextMessage? _editingMessage;
  final TextEditingController _editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _addInitialChat(widget.initialMessages);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addInitialChat(List<ChatMessage> chatMessages) {
    for (var chatMessage in chatMessages) {
      _addChatMessage(chatMessage);
    }
  }

  void _addChatMessage(ChatMessage chatMessage) {
    final author = chatMessage.senderId == widget.user.id ? widget.user : widget.friend;
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    if (chatMessage.text != null) {
      final urlRegExp = RegExp(r"(https?:\/\/[^\s]+)");
      final matches = urlRegExp.allMatches(chatMessage.text!);

      if (matches.isNotEmpty) {
        String text = chatMessage.text!;
        for (var match in matches) {
          final url = text.substring(match.start, match.end);

          final textMessage = types.TextMessage(
              author: author,
              createdAt: createdAt,
              id: const Uuid().v4(),
              text: text,
              previewData: types.PreviewData(link: url)
          );

          _addMessage(textMessage);
          break;
        }

      }
      else {

        final textMessage = types.TextMessage(
          author: author,
          createdAt: createdAt,
          id: const Uuid().v4(),
          text: chatMessage.text!,
        );
        _addMessage(textMessage);
      }

    } else if (chatMessage.file != null) {
      final fileMessage = types.FileMessage(
        author: author,
        createdAt: createdAt,
        id: const Uuid().v4(),
        name: chatMessage.file!.name,
        uri: chatMessage.file!.uri,
        mimeType: lookupMimeType(chatMessage.file!.uri),
        size: 0,
      );
      _addMessage(fileMessage);
    } else if (chatMessage.image != null) {
      _loadImage(chatMessage.image!.uri).then((imageData) {
        if (imageData != null) {
          decodeImageFromList(imageData).then((decodedImage) {
            final imageMessage = types.ImageMessage(
              author: author,
              createdAt: createdAt,
              id: const Uuid().v4(),
              name: chatMessage.image!.name,
              uri: chatMessage.image!.uri,
              width: decodedImage.width.toDouble(),
              height: decodedImage.height.toDouble(),
              size: imageData.length,
            );
            _addMessage(imageMessage);
          });
        } else {
          print("Failed to load image: ${chatMessage.image!.uri}");
        }
      });
    }
  }

  void _editMessage(types.TextMessage message) {
    setState(() {
      _editingMessage = message;
      _editingController.text = message.text;
    });
  }

  void _deleteMessage(types.Message message) {
    setState(() {
      _messages.remove(message);
    });
  }


  Future<Uint8List?> _loadImage(String imagePath) async {
    try {
      if (imagePath.startsWith('assets/')) {
        final ByteData imageData = await rootBundle.load(imagePath);
        return imageData.buffer.asUint8List();
      } else {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          return Uint8List.fromList(await imageFile.readAsBytes());
        } else {
          print("File not found: $imagePath");
          return null;
        }
      }
    } catch (e) {
      print("Error loading image: $e");
      return null;
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final chatMessage = ChatMessage(senderId: widget.user.id, receiverId: widget.friend.id, file: ChatFile(uri: result.files.single.path!, name: result.files.single.name));
      _addInitialChat([chatMessage]);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final chatMessage = ChatMessage(senderId: widget.user.id, receiverId: widget.friend.id, image: ChatImage(uri: result.path, name: result.name));
      _addInitialChat([chatMessage]);
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.TextMessage && message.previewData?.link != null) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Open Link?'),
          content: Text('Do you want to open this link in your browser?\n${message.previewData!.link!}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      ).then((value) async {
        if (value == true) {
          final Uri url = Uri.parse(message.previewData!.link!);
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch URL: $e')),
            );
          }
        }
      });
    }
    else if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    if (_editingMessage != null) {
      final index = _messages.indexOf(_editingMessage!);
      if (index >= 0) {
        setState(() {
          _messages[index] = _editingMessage!.copyWith(text: _editingController.text) as types.Message;
          _editingMessage = null;
          _editingController.clear();
        });
      }
    } else {
      final chatMessage = ChatMessage(senderId: widget.user.id, receiverId: widget.friend.id, text: message.text);
      _addInitialChat([chatMessage]);
    }
  }

  void _handleEditSendPressed() {
    if (_editingMessage != null) {
      final index = _messages.indexOf(_editingMessage!);
      if (index >= 0) {
        setState(() {
          _messages[index] = _editingMessage!.copyWith(text: _editingController.text) as types.Message;
          _editingMessage = null;
          _editingController.clear();
        });
      }
    }
  }

  void _loadMessages() async {
    //Load initial message from asset if needed
    // final response = await rootBundle.loadString('assets/messages.json');
    // final messages = (jsonDecode(response) as List)
    //     .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
    //     .toList();
    //
    // setState(() {
    //   _messages = messages;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.friend.imageUrl != null ? AssetImage(widget.friend.imageUrl!) : null, // Use AssetImage if imageUrl is available
              child: widget.friend.imageUrl == null ? Text(widget.friend.firstName![0].toUpperCase()) : null, // Display first letter if no image
            ),
            const SizedBox(width: 8),
            Text(widget.friend.firstName ?? 'Unknown'),
          ],
        ),
      ),
      body: Chat(
        messages: _messages,
        onAttachmentPressed: _handleAttachmentPressed,
        onMessageTap: _handleMessageTap,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: (types.PartialText partialText) => _handleSendPressed(partialText),
        showUserAvatars: true,
        showUserNames: true,
        user: widget.user,
        textMessageBuilder: (types.TextMessage message,
            {required int messageWidth, required bool showName}) {
          return _buildTextMessage(message, messageWidth, showName);
        },
        imageMessageBuilder: (types.ImageMessage message,
            {required int messageWidth}) {
          return _buildImageMessage(message, messageWidth);
        },
        fileMessageBuilder: (types.FileMessage message,
            {required int messageWidth}) {
          return _buildFileMessage(message, messageWidth);
        },
        customBottomWidget: _editingMessage != null
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editingController,
                  decoration: const InputDecoration(
                    hintText: 'Edit your message...',
                  ),
                  onChanged: (text) {
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _handleEditSendPressed,
              ),
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    _editingMessage = null;
                    _editingController.clear();
                  });
                },
              ),
            ],
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildTextMessage(types.TextMessage message, int messageWidth, bool showName) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: TextMessage(
            message: message,
            showName: showName,
            usePreviewData: true,
            hideBackgroundOnEmojiMessages: false,
            emojiEnlargementBehavior: EmojiEnlargementBehavior.multi,
          ),
        ),
        if (message.author.id == widget.user.id)
          _buildOptionsButton(context, message),
      ],
    );
  }

  Widget _buildImageMessage(types.ImageMessage message, int messageWidth) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
       Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(
      child: ImageMessage(
        message: message,
        imageHeaders: const {},
        messageWidth: messageWidth,
      ),
    ),
    if (message.author.id == widget.user.id)
      _buildOptionsButton(context, message),
  ],
),
if (message.author.id != widget.user.id)
  Positioned(
    top: 0,
    right: 0,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          print('Close button tapped for image: ${message.name}');
          int index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            setState(() {
              _messages.removeAt(index);
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.7),
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
  ),
      ],
    );
  }

  Widget _buildFileMessage(types.FileMessage message, int messageWidth) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FileMessage(message: message),
        ),
        if (message.author.id == widget.user.id)
          _buildOptionsButton(context, message),
      ],
    );
  }

  Widget _buildOptionsButton(BuildContext context, types.Message message) {
    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        _showMessageOptions(context, message);
      },
    );
  }

  void _showMessageOptions(BuildContext context, types.Message message) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            if (message is types.TextMessage)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message);
              },
            ),
          ],
        );
      },
    );
  }
}