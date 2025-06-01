
part of 'post_bloc.dart';



abstract class PostState {
  const PostState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
        other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => 0;
}


// Add these to your existing post_state.dart
class PostCreationInProgress extends PostState {}

class PostCreationLoading extends PostState {}

class PostCreationSuccess extends PostState {
  final Post createdPost;
  
  const PostCreationSuccess(this.createdPost);

  @override
  List<Object?> get props => [createdPost];
}

class PostCreationFailure extends PostState {
  final String error;
  
  const PostCreationFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final FindResult<Post> posts;

  const PostLoaded({required this.posts});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostLoaded && other.posts == posts;
  }

  @override
  int get hashCode => posts.hashCode;
}

class PostError extends PostState {
  final String message;

  const PostError({required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}


class PostUpdateInProgress extends PostState {}

class PostUpdateLoading extends PostState {}

class PostUpdateSuccess extends PostState {
  final Post updatedPost;

  const PostUpdateSuccess(this.updatedPost);

  @override
  List<Object?> get props => [updatedPost];
}

class PostUpdateFailure extends PostState {
  final String error;

  const PostUpdateFailure(this.error);

  @override
  List<Object?> get props => [error];
}


class PostDeleteLoading extends PostState {}

class PostDeleteSuccess extends PostState {
  final String deletedPostId;

  const PostDeleteSuccess(this.deletedPostId);

  @override
  List<Object?> get props => [deletedPostId];
}

class PostDeleteFailure extends PostState {
  final String error;

  const PostDeleteFailure(this.error);

  @override
  List<Object?> get props => [error];
}


class PostReactionLoading extends PostState {
  final String postId;

  const PostReactionLoading(this.postId);

  @override
  List<Object?> get props => [postId];
}

class PostReactionSuccess extends PostState {
  final Post updatedPost;

  const PostReactionSuccess(this.updatedPost);

  @override
  List<Object?> get props => [updatedPost];
}

class PostReactionFailure extends PostState {
  final String postId;
  final String error;

  const PostReactionFailure({
    required this.postId,
    required this.error,
  });

  @override
  List<Object?> get props => [postId, error];
}

