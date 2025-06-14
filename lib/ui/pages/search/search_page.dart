import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';
import 'all_search_page.dart';
import 'people_search_page.dart';
import 'posts_search_page.dart';
import 'videos_search_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(),
      child: DefaultTabController(
        length: 4,
        child: Builder(
          builder: (context) {
            final TabController tabController = DefaultTabController.of(context);
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                context.read<SearchBloc>().add(SearchTabChanged(tabController.index));
              }
            });
            
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                elevation: 0,
                centerTitle: true,
                title: SizedBox(
                  width: 320,
                  child: _SearchBar(),
                ),
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'People'),
                    Tab(text: 'Posts'),
                    Tab(text: 'Videos'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  AllSearchPage(),
                  PeopleSearchPage(),
                  PostsSearchPage(),
                  VideosSearchPage(),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: Color.fromRGBO(143, 148, 251, 1)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        cursorColor: Colors.grey[600],
        onChanged: (query) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
        },
      ),
    );
  }
} 