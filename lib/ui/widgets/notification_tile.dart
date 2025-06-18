import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:mobile/ui/theme/theme_helper.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  late NotificationModel _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
  }

  @override
  void didUpdateWidget(covariant NotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _notification = widget.notification;
  }

  void onReadAll() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final DateTime dateTime = widget.notification.time;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _notification.isRead
            ? theme.colorScheme.surface
            : theme.primaryColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26.5,
                backgroundColor: DateTime.now().millisecond.isEven
                    ? ColorScheme.of(context).greenColor2
                    : Colors.transparent,
                child: CircleAvatar(
                  radius: 24.5,
                  backgroundImage: (widget.notification.senders.isNotEmpty &&
                          widget.notification.senders[0].profilePic != null)
                      ? CachedNetworkImageProvider(
                          widget.notification.senders[0].profilePic!,
                        ) as ImageProvider<Object>
                      :  AssetImage(
                         widget.notification.senders.isNotEmpty ?  'assets/images/user.png' :  'assets/app_logo.png',
                        ),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    switch (widget.notification.type) {
                      NotificationType.like => Icons.favorite,
                      NotificationType.comment => Icons.chat_bubble,
                      NotificationType.follow => Icons.person_add,
                      _ => Icons.notifications,
                    },
                    color: theme.colorScheme.greenColor2,
                    size: 10,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.notification.text,
                  style: TextStyle(
                    color: _notification.isRead
                        ? theme.colorScheme.onSurface.withAlpha(150)
                        : null,
                    fontSize: 14
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                  style: TextStyle(color: theme.disabledColor),
                ),
              ],
            ),
          ),
          Icon(Icons.more_horiz)
        ],
      ),
    );
  }
}
