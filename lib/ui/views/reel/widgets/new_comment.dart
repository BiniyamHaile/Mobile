import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  final TextEditingController controller;
  final String inputLabel;
  final String? targetName;
  final bool isEditing;

  final Function(String text) onSend;
  final Function(String text) onUpdate;
  final VoidCallback? onCancelAction;

  const NewMessage({
    Key? key,
    required this.controller,
    required this.inputLabel,
    this.targetName,
    required this.isEditing,
    required this.onSend,
    required this.onUpdate,
    this.onCancelAction,
  }) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  bool _showEmojiPicker = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _handleSendOrUpdate() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    if (widget.isEditing) {
      widget.onUpdate(text);
    } else {
      widget.onSend(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.trim().isNotEmpty;
    final Color sendButtonColor =
        hasText ? Theme.of(context).primaryColor : Colors.grey;
    final IconData sendButtonIcon = widget.isEditing ? Icons.check : Icons.send;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.targetName != null || widget.isEditing)
            Container(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
              child: Row(
                children: [
                  Icon(
                    widget.isEditing ? Icons.edit : Icons.reply,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.isEditing
                          ? 'Editing ${widget.targetName ?? "your comment"}'
                          : 'Replying to ${widget.targetName ?? "comment"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.onCancelAction != null)
                    GestureDetector(
                      onTap: widget.onCancelAction,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.close, size: 16, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          const Divider(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: widget.inputLabel,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12.0,
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                onPressed: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                },
              ),
              IconButton(
                icon: Icon(sendButtonIcon, color: sendButtonColor),
                onPressed: hasText ? _handleSendOrUpdate : null,
              ),
            ],
          ),
          Offstage(
            offstage: !_showEmojiPicker,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  widget.controller.text += emoji.emoji;
                  widget.controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: widget.controller.text.length),
                  );
                  setState(() {});
                },
                onBackspacePressed: () {
                  if (widget.controller.text.isNotEmpty) {
                    widget.controller.text = widget.controller.text.substring(
                      0,
                      widget.controller.text.length - 1,
                    );
                    widget.controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: widget.controller.text.length),
                    );
                    setState(() {});
                  }
                },
                config: const Config(
                  emojiViewConfig: EmojiViewConfig(),
                  categoryViewConfig: CategoryViewConfig(),
                  skinToneConfig: SkinToneConfig(),
                  bottomActionBarConfig: BottomActionBarConfig(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
