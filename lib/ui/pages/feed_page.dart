import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/widgets/widgets.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _appBar(theme, context),
      body: ResponsivePadding(
        child: ListView(
          children: [
            SizedBox(
              height: 110,
              child: ListView.builder(
                itemCount: UserStory.dummyUserStories.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 4 : 0,
                      right: index == UserStory.dummyUserStories.length - 1
                          ? 4
                          : 0,
                    ),
                    child: UserStoryTile(index: index),
                  );
                },
              ),
            ),
            ListView.separated(
              itemCount: Post.dummyPosts.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (_, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 4),
                );
              },
              itemBuilder: (_, index) => PostCard(),
            )
          ],
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
