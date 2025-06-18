import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/repository/social/post_repository.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/theme/theme_helper.dart';
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
  String? _targetPostId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic> && extra.containsKey('postId')) {
      _targetPostId = extra['postId'] as String;
    }
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

  void _scrollToPost(List posts) {
    if (_targetPostId == null) return;
    
    final index = posts.indexWhere((post) => post.id == _targetPostId);
    if (index != -1) {
      // Calculate approximate height of each post (adjust this value based on your post card height)
      const postHeight = 600.0; // Approximate height of a post card
      final scrollPosition = index * postHeight;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
      
      _targetPostId = null; // Reset after scrolling
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
              if (_targetPostId != null) {
                _scrollToPost(state.posts.data);
              }
            }
          },
          builder: (context, state) {
            final appTheme = AppTheme.getTheme(context);
            if (state is PostInitial || state is PostLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            } else if (state is PostError) {
              return Center(child: Text(state.message));
            } else if (state is PostLoaded) {
              final posts = state.posts.data;

              if (posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.fileText,
                        size: 80,
                        color: appTheme.colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Posts Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: appTheme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Be the first to share a post or check back later!',
                        style: TextStyle(
                          fontSize: 16,
                          color: appTheme.colorScheme.primary.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(RouteNames.search);
                        },
                        icon: Icon(Icons.search,
                            color: appTheme.colorScheme.onPrimary),
                        label: Text(
                          'Search',
                          style:
                              TextStyle(color: appTheme.colorScheme.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

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
                          PostCard(
                            post: posts[index],
                            onDeleted: () {
                              setState(() {
                                posts.removeWhere((p) => p.id == posts[index].id);
                              });
                            },
                          ),
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
    final appTheme = AppTheme.getTheme(context);
    final textTheme = appTheme.textTheme;

    return AppBar(
      backgroundColor: appTheme.colorScheme.onPrimary,
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
                        context.push(RouteNames.search);
                      },
                      icon: Icon(
                        Icons.search,
                        color: appTheme.colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(RouteNames.chat);
                      },
                      icon: Icon(
                        Icons.message_outlined,
                        color: appTheme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.push(RouteNames.notifications);
                      },
                      icon: Icon(
                        LucideIcons.bell,
                        color: appTheme.colorScheme.primary,
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
