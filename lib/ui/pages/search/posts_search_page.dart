import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';


class PostsSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // Render results for 'Posts'
        return Center(child: Text('Posts Results'));
      },
    );
  }
} 