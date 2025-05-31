import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:mobile/bloc/chat/retrieve_messages/retrieve_messages_bloc.dart';
import 'package:mobile/bloc/chat/send_message/send_message_bloc.dart';
import 'package:mobile/models/chat/chat_messages.dart';
import 'package:mobile/services/socket/websocket-service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

// import http
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      required this.user,
      required this.friend,
      required this.roomId});

  final types.User user;
  final types.User friend;
  final String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];

  types.TextMessage? _editingMessage;
  final TextEditingController _editingController = TextEditingController();
// define a boolean to track typing status
  bool isTyping = false;
  @override
  void initState() {
    super.initState();
    context
        .read<RetrieveMessagesBloc>()
        .add(RetrieveMessages(roomId: widget.roomId));

    final socketService = WebSocketService();
    socketService.connect(widget.user.id);
    socketService.joinRoom(widget.roomId);

    socketService.onNewMessage((data) {
      print("New message received: $data");
      final message = ChatMessage.fromJson(data);
      context
          .read<RetrieveMessagesBloc>()
          .add(AddMessageToQueue(message: message));
    });

    socketService.onTyping((_) {
      setState(() => isTyping = true);
    });

    socketService.onStopTyping((_) {
      setState(() => isTyping = false);
    });

    // _loadMessages();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    context
        .read<RetrieveMessagesBloc>()
        .add(AddMessageToQueue(message: message));
  }

  void _sendMessage(String content, String receiverId, String? replyTo) {
    context.read<SendMessageBloc>().add(SendMessage(
          receiverId: receiverId,
          text: content,
          replyTo: replyTo,
        ));
  }

  Widget _buildVideoMessage(types.VideoMessage message, int messageWidth) {
    return _VideoPlayerWidget(
        videoUrl: message.uri, width: messageWidth.toDouble());
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
    print("handle file selection called");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    print("result: $result");

    if (result == null) {
      print("User canceled the picker or no file selected.");
      return;
    }

    print("Picked files: ${result.files}");

    for (final file in result.files) {
      print("file path: ${file.path}");
      print("file name: ${file.name}");
    }

    final filePaths = result.paths.whereType<String>().toList();

    if (filePaths.isEmpty) {
      print("All selected files had null paths.");
      return;
    }

    print("Sending files: $filePaths");

    context.read<SendMessageBloc>().add(SendMessage(
          receiverId: widget.friend.id,
          text: '',
          filePaths: filePaths,
        ));
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      print("Picked image: ${result.path}");

      context.read<SendMessageBloc>().add(SendMessage(
            receiverId: widget.friend.id,
            text: '',
            filePaths: [result.path],
          ));
    } else {
      print("No image selected.");
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.TextMessage && message.previewData?.link != null) {
      showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Open Link?'),
          content: Text(
              'Do you want to open this link in your browser?\n${message.previewData!.link!}'),
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
    } else if (message is types.FileMessage) {
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

  void _handleSendPressed(types.PartialText partialText) {
    final content = partialText.text.trim();
    if (content.isEmpty) return;

    _sendMessage(
      content,
      widget.friend.id, // or whatever identifies the receiver
      _editingMessage?.id, // pass this if you're supporting replies
    );

    // Clear editing state if necessary
    setState(() {
      _editingMessage = null;
      _editingController.clear();
    });
  }

  void _handleEditSendPressed() {
    if (_editingMessage != null) {
      final index = _messages.indexOf(_editingMessage!);
      if (index >= 0) {
        setState(() {
          _messages[index] = _editingMessage!
              .copyWith(text: _editingController.text) as types.Message;
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
              backgroundImage: widget.friend.imageUrl != null
                  ? AssetImage(widget.friend.imageUrl!)
                  : null, // Use AssetImage if imageUrl is available
              child: widget.friend.imageUrl == null
                  ? Text(widget.friend.firstName![0].toUpperCase())
                  : null, // Display first letter if no image
            ),
            const SizedBox(width: 8),
            Text(widget.friend.firstName ?? 'Unknown'),
          ],
        ),
      ),
      body: BlocListener<SendMessageBloc, SendMessageState>(
        listener: (context, state) {
          print("state of send message: $state");
          if (state is SendMessageSuccess) {
            // Add the sent message to the chat
            print("message sent: ${state.message}");
            _addMessage(state.message);
          } else if (state is SendMessageFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to send message: ${state.error}')),
            );
          }
        },
        child: BlocBuilder<RetrieveMessagesBloc, RetrieveMessagesState>(
          builder: (context, state) {
            if (state is RetrieveMessagesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RetrieveMessagesFailure) {
              return Center(child: Text('Error: ${state.error}'));
            } else if (state is RetrieveMessagesSuccess) {
              final chatMessages = state.messages
                  .map((message) => message.toFlutterMessage())
                  .toList();

              final senderIds = chatMessages
                  .map((message) => message.author.id);

              print("Sender IDs: $senderIds");
              print("user ID: ${widget.user.id}");
              print("Friend ID: ${widget.friend.id}");
              print(
                "roomId: ${widget.roomId}",
              );
              return Chat(
                messages: chatMessages,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _handleMessageTap,
                videoMessageBuilder: (types.VideoMessage message,
                    {required int messageWidth}) {
                  return _buildVideoMessage(message, messageWidth);
                },
                onPreviewDataFetched: _handlePreviewDataFetched,
                onSendPressed: (types.PartialText partialText) =>
                    _handleSendPressed(partialText),
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
                                onChanged: (text) {},
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
              );
            }

            return const Center(child: Text('No messages available.'));
          },
        ),
      ),
    );
  }

  Widget _buildTextMessage(
      types.TextMessage message, int messageWidth, bool showName) {
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
              title: const Text('Delete Message',
                  style: TextStyle(color: Colors.red)),
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

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double width;

  const _VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.width,
  }) : super(key: key);

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: _initialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
