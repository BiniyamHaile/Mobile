part of 'post_bloc.dart';

abstract class PostEvent {
  const PostEvent();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
        other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => 0;
}


class CreatePost extends PostEvent {
  final String? content;
  final List<XFile>? mediaFiles;
  final List<String>? mentions;

  const CreatePost({this.content, this.mediaFiles, this.mentions});

  @override
  List<Object?> get props => [content, mediaFiles];
}


class UpdatePost extends PostEvent {
  final String postId;
  final String? content;
  final List<XFile>? mediaFiles;
  final List<String>? mentions;

  const UpdatePost({
    required this.postId,
    this.content,
    this.mediaFiles,
    this.mentions,
  });
}

class FetchPosts extends PostEvent {
  final int? limit;
  final int? offset;
  final String? next;
  final String? previous;

  const FetchPosts({
    this.limit,
    this.offset,
    this.next,
    this.previous,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FetchPosts &&
        other.limit == limit &&
        other.offset == offset &&
        other.next == next &&
        other.previous == previous;
  }

  @override
  int get hashCode {
    return limit.hashCode ^
        offset.hashCode ^
        next.hashCode ^
        previous.hashCode;
  }
}


class DeletePost extends PostEvent {
  final String postId;

  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class ToggleReaction extends PostEvent {
  final String postId;

  const ToggleReaction({
    required this.postId,
  });

  @override
  List<Object?> get props => [postId];
}