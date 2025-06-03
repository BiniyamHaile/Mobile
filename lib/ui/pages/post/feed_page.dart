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
  bool _isLoadingPrevious = false;
  late final PostBloc _postBloc;
  static const double _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = PostBloc(postRepository: PostRepository())
      ..add(const FetchPosts(limit: 10));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = MediaQuery.of(context).size.height * 0.2;

    if (maxScroll - currentScroll <= delta && !_isLoadingMore) {
      final state = _postBloc.state;
      if (state is PostLoaded && state.hasMore) {
        setState(() => _isLoadingMore = true);
        _postBloc.add(LoadMorePosts());
      }
    } else if (currentScroll <= _scrollThreshold && !_isLoadingPrevious) {
      final state = _postBloc.state;
      if (state is PostLoaded && state.hasPrevious) {
        setState(() => _isLoadingPrevious = true);
        _postBloc.add(LoadPreviousPosts());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _postBloc,
      child: Scaffold(
        appBar: _appBar(theme, context),
        body: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state is PostLoaded) {
              setState(() {
                _isLoadingMore = false;
                _isLoadingPrevious = false;
              });
            }
          },
          builder: (context, state) {
            if (state is PostInitial || state is PostLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ));
            } else if (state is PostError) {
              return Center(child: Text(state.message));
            } else if (state is PostLoaded) {
              final posts = state.posts.data;

              return RefreshIndicator(
                onRefresh: () async {
                  _postBloc.add(const FetchPosts(limit: 10));
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: posts.length +
                      (_isLoadingMore ? 1 : 0) +
                      (_isLoadingPrevious ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0 && _isLoadingPrevious) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final postIndex = index - (_isLoadingPrevious ? 1 : 0);
                    if (postIndex < posts.length) {
                      return Column(
                        children: [
                          PostCard(
                            post: posts[postIndex],
                            onDeleted: () {
                              setState(() {
                                posts.removeWhere(
                                    (p) => p.id == posts[postIndex].id);
                              });
                            },
                          ),
                          if (postIndex < posts.length - 1)
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
      backgroundColor: const Color.fromRGBO(143, 148, 251, 1), // Add this lin
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
                        Icons.post_add_outlined,
                        color: theme.colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(RouteNames.chat);
                      },
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
