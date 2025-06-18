import 'dart:convert';

import 'package:mobile/models/profile.dart';

enum NotificationType {
  comment,
  like,
  follow,
  mention,
  reaction,
  share,
  post,
  message,
  friendRequest,
  friendRequestAccepted,
  gift,
  commentRemoved,
  postRemoved,
  reelRemoved,
}

NotificationType? notificationTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'comment':
      return NotificationType.comment;
    case 'like':
      return NotificationType.like;
    case 'follow':
      return NotificationType.follow;
    case 'mention':
      return NotificationType.mention;
    case 'reaction':
      return NotificationType.reaction;
    case 'share':
      return NotificationType.share;
    case 'post':
      return NotificationType.post;
    case 'message':
      return NotificationType.message;
    case 'friend_request':
      return NotificationType.friendRequest;
    case 'friend_request_accepted':
      return NotificationType.friendRequestAccepted;
    case 'gift':
      return NotificationType.gift;
    // New cases
    case 'comment-removed':
      return NotificationType.commentRemoved;
    case 'post-removed':
      return NotificationType.postRemoved;
    case 'reel-removed':
      return NotificationType.reelRemoved;
    default:
      return null;
  }
}

String? notificationTypeToString(NotificationType? type) {
  switch (type) {
    case NotificationType.comment:
      return 'comment';
    case NotificationType.like:
      return 'like';
    case NotificationType.follow:
      return 'follow';
    case NotificationType.mention:
      return 'mention';
    case NotificationType.reaction:
      return 'reaction';
    case NotificationType.share:
      return 'share';
    case NotificationType.post:
      return 'post';
    case NotificationType.message:
      return 'message';
    case NotificationType.friendRequest:
      return 'friend_request';
    case NotificationType.friendRequestAccepted:
      return 'friend_request_accepted';
    case NotificationType.gift:
      return 'gift';
    // New cases
    case NotificationType.commentRemoved:
      return 'comment-removed';
    case NotificationType.postRemoved:
      return 'post-removed';
    case NotificationType.reelRemoved:
      return 'reel-removed';
    default:
      return null;
  }
}

String _getActionText(NotificationType type) {
  switch (type) {
    case NotificationType.like:
      return 'liked your post';
    case NotificationType.comment:
      return 'commented on your post';
    case NotificationType.follow:
      return 'started following you';
    case NotificationType.mention:
      return 'mentioned you';
    case NotificationType.reaction:
      return 'reacted to your post';
    case NotificationType.share:
      return 'shared your post';
    case NotificationType.post:
      return 'posted something';
    case NotificationType.message:
      return 'sent you a message';
    case NotificationType.friendRequest:
      return 'sent you a friend request';
    case NotificationType.friendRequestAccepted:
      return 'accepted your friend request';
    case NotificationType.gift:
      return 'sent you a gift';
    // New action texts
    case NotificationType.commentRemoved:
      return 'Your comment was removed';
    case NotificationType.postRemoved:
      return 'Your post was removed';
    case NotificationType.reelRemoved:
      return 'Your reel was removed';
    default:
      return 'interacted with you';
  }
}

class NotificationModel {
  final String receiverId;
  final List<Profile> senders;
  final String message;
  final NotificationType type;
  final List<String> entityIds;
  final bool isRead;
  final DateTime time;
  final String text;

  NotificationModel({
    required this.receiverId,
    required this.senders,
    required this.message,
    required this.type,
    required this.entityIds,
    required this.text,
    this.isRead = false,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> senderJsonList = json['senders'] ?? [];
    final List<Profile> senderProfiles = senderJsonList
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();

    final NotificationType type =
        notificationTypeFromString(json['type']) ?? NotificationType.comment;

    String text;
    
    // Determine the core action text first.
    String actionText;
    if (type == NotificationType.gift) {
      // For gifts, the 'message' field is the amount.
      // We construct a more descriptive action text that includes the amount.
      final String amount = json['message'] as String;
      actionText = 'sent you a gift of $amount';
    }else if(type == NotificationType.commentRemoved ||
              type == NotificationType.postRemoved ||
              type == NotificationType.reelRemoved) {
      actionText = "${_getActionText(type)} ${json['message']}";
    }
     else {
      actionText = _getActionText(type);
    }

    // Now, construct the final display text using the sender information.
    if (senderProfiles.isEmpty) {
      // Handles sender-less notifications like "Your post was removed".
      // For a sender-less gift, this provides a clear message to the user.
      if (type == NotificationType.gift) {
        final String amount = json['message'] as String;
        text = 'You have received a gift of $amount';
      } else {
        text = actionText;
      }
    } else {
      // Constructs the text with one or more sender names.
      if (senderProfiles.length == 1) {
        text = '${senderProfiles[0].firstName} ${senderProfiles[0].lastName} $actionText';
      } else if (senderProfiles.length == 2) {
        text =
            '${senderProfiles[0].firstName} ${senderProfiles[0].lastName} and ${senderProfiles[1].firstName} ${senderProfiles[1].lastName} $actionText';
      } else {
        final remaining = senderProfiles.length - 2;
        text =
            '${senderProfiles[0].firstName} ${senderProfiles[0].lastName}, ${senderProfiles[1].firstName} ${senderProfiles[1].lastName} and $remaining other${remaining > 1 ? 's' : ''} $actionText';
      }
    }

    return NotificationModel(
      receiverId: json['receiverId'] as String,
      senders: senderProfiles,
      message: json['message'] as String,
      type: type,
      entityIds: List<String>.from(json['entityIds'] ?? []),
      isRead: json['isRead'] ?? false,
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      text: text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'senders': senders.map((e) => e.toJson()).toList(),
      'message': message,
      'type': notificationTypeToString(type),
      'entityIds': entityIds,
      'isRead': isRead,
      'time': time.toIso8601String(),
      'text': text,
    };
  }

  NotificationModel copyWith({
    String? receiverId,
    List<Profile>? senders,
    String? message,
    NotificationType? type,
    List<String>? entityIds,
    bool? isRead,
    DateTime? time,
    String? text,
  }) {
    return NotificationModel(
      receiverId: receiverId ?? this.receiverId,
      senders: senders ?? this.senders,
      message: message ?? this.message,
      type: type ?? this.type,
      entityIds: entityIds ?? this.entityIds,
      isRead: isRead ?? this.isRead,
      time: time ?? this.time,
      text: text ?? this.text,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}