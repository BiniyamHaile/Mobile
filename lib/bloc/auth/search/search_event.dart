part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class SearchTabChanged extends SearchEvent {
  final int tabIndex;
  SearchTabChanged(this.tabIndex);
}

class FollowUser extends SearchEvent {
  final String targetId;
  FollowUser(this.targetId);
}

class UnfollowUser extends SearchEvent {
  final String targetId;
  UnfollowUser(this.targetId);
}
