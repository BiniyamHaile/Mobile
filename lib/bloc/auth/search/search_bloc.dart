import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchTabChanged>(_onTabChanged);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
  }

  // Future<void> _onQueryChanged(
  //     SearchQueryChanged event, Emitter<SearchState> emit) async {
  //   emit(SearchLoading());
  //   await Future.delayed(Duration(milliseconds: 500));
  //   // Mock people data
  //   final mockPeople = [
  //     {
  //       'name': 'Bini Yenatu Lii',
  //       'subtitle': '15 mutual friends',
  //       'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
  //       'canAddFriend': true,
  //     },
  //     {
  //       'name': 'Bini Meng',
  //       'subtitle': 'Digital creator · 166 followers · @bini.mena.830719',
  //       'avatarUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
  //       'isFollowing': true,
  //     },
  //     {
  //       'name': 'Bini Man',
  //       'subtitle': 'Digital creator · 3.9K followers · @bini.man.142',
  //       'avatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
  //     },
  //     {
  //       'name': 'Bini Dechtu',
  //       'subtitle': '',
  //       'avatarUrl': 'https://randomuser.me/api/portraits/men/4.jpg',
  //       'canAddFriend': true,
  //     },
  //     {
  //       'name': 'Bini Jhon',
  //       'subtitle': 'Lives in Addis Ababa, Ethiopia',
  //       'avatarUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
  //     },
  //   ];
  //   // Filter by query
  //   final filtered = event.query.isEmpty
  //       ? mockPeople
  //       : mockPeople
  //           .where((p) =>
  //               (p['name'] as String?)?.toLowerCase().contains(event.query.toLowerCase()) ?? false)
  //           .toList();
  //   emit(SearchLoaded(filtered));
  // }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final currentTab = prefs.getInt('currentSearchTab') ?? 0;

      String endpoint;
      Map<String, dynamic> queryParams = {};

      switch (currentTab) {
        // case 0: // All
        //   // Handle all search
        //   return;
        case 0: // People
          endpoint = '${ApiEndpoints.baseUrl}/auth/search-users';
          queryParams = {'q': event.query};
          break;
        case 1: // Posts
          endpoint = '${ApiEndpoints.baseUrl}/social/posts/search';
          queryParams = {'search': event.query};
          break;
        case 2: // Videos
          // Handle videos search
          return;
        default:
          endpoint = '${ApiEndpoints.baseUrl}/auth/search-users';
          queryParams = {'q': event.query};
      }

      final response = await Dio().get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      List results;
      if (currentTab == 1) { // Posts search returns FindResult
        results = response.data['data'] as List;
      } else { // Users search returns array directly
        results = response.data as List;
        print('Searcheeeeeeeeeeeeeeeeeeeeeeeeed  users: $results');
      }
      
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError('Failed to search: ${e.toString()}'));
    }
  }

  Future<void> _onTabChanged(
    SearchTabChanged event,
    Emitter<SearchState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentSearchTab', event.tabIndex);
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/follow/${event.targetId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        final updatedResults = currentState.results.map((person) {
          if (person['id'] == event.targetId) {
            return {...person, 'isFollowing': true};
          }
          return person;
        }).toList();
        emit(SearchLoaded(updatedResults));
      }
    } catch (e) {
      emit(SearchError('Failed to follow user: ${e.toString()}'));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUser event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/unfollow/${event.targetId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        final updatedResults = currentState.results.map((person) {
          if (person['id'] == event.targetId) {
            return {...person, 'isFollowing': false};
          }
          return person;
        }).toList();
        emit(SearchLoaded(updatedResults));
      }
    } catch (e) {
      emit(SearchError('Failed to unfollow user: ${e.toString()}'));
    }
  }
}
