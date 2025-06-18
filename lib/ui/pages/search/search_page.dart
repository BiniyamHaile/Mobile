import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'all_search_page.dart';
import 'people_search_page.dart';
import 'posts_search_page.dart';
import 'videos_search_page.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     final theme = AppTheme.getTheme(context);
    final textTheme = theme.textTheme;
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
                leading: IconButton(onPressed: context.pop, icon: Icon(Icons.arrow_back)),
                backgroundColor: theme.colorScheme.onPrimary,
                elevation: 0,
                centerTitle: true,
                title: SizedBox(
                  width: 320,
                  child: _SearchBar(),
                ),
                bottom: TabBar(
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  dividerColor: Colors.transparent,
                  tabs: [
              //  Tab(text: AppStrings.all.tr(context)),
                Tab(text: AppStrings.people.tr(context)),
                Tab(text: AppStrings.posts.tr(context)),
                Tab(text: AppStrings.videos.tr(context)),
                  ],
                ),
              ),
              body: TabBarView(
                
                children: [
                  // AllSearchPage(),
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
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: AppStrings.searchHint.tr(context),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
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