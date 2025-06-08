import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/bloc/auth/login/login_bloc.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/services/utls/get-userId.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchTabChanged>(_onTabChanged);
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
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final currentUserId =
          await getCurrentUserId(); 
      print('Current User ID: $currentUserId');
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/search-users',
        queryParameters: {'q': event.query},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final people = response.data as List;
      emit(SearchLoaded(people));
    } catch (e) {
      emit(SearchError('Failed to search users'));
    }
  }

  Future<void> _onTabChanged(
      SearchTabChanged event, Emitter<SearchState> emit) async {
    // Optionally handle tab-specific logic
  }
}
