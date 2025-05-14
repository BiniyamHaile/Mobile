import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/repository/social/post_repository.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/widgets/app_logo.dart';
import 'package:mobile/ui/widgets/layout/responsive_padding.dart';
import 'package:mobile/ui/widgets/post_card.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      final state = context.read<PostBloc>().state;
      if (state is PostLoaded && state.posts.next != null) {
        setState(() => _isLoadingMore = true);
        context.read<PostBloc>().add(FetchPosts(next: state.posts.next));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => PostBloc(
        postRepository: PostRepository(),
      )..add(const FetchPosts()),
      child: Scaffold(
        appBar: _appBar(theme, context),
        body: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state is PostLoaded) {
              setState(() => _isLoadingMore = false);
            }
          },
          builder: (context, state) {
            if (state is PostInitial || state is PostLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PostError) {
              return Center(child: Text(state.message));
            } else if (state is PostLoaded) {
              final posts = state.posts.data;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(const FetchPosts());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.posts.next != null
                      ? posts.length + 1
                      : posts.length,
                  itemBuilder: (context, index) {
                    if (index < posts.length) {
                      return Column(
                        children: [
                          PostCard(post: posts[index]),
                          if (index < posts.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                        ],
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  AppBar _appBar(ThemeData theme, BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: ResponsivePadding(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppLogo(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.push(RouteNames.post);
                      },
                      icon: Icon(
                        Icons.post_add,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.send_sharp,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}