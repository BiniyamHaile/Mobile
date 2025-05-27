part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<dynamic> results;
  SearchLoaded(this.results);
}

class SearchError extends SearchState {
  final String error;
  SearchError(this.error);
}
