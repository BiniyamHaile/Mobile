import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';
import 'package:mobile/ui/routes/route_names.dart';

class PostsSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is SearchLoaded) {
          final posts = state.results;
          if (posts.isEmpty) {
            return Center(child: Text('No posts found.'));
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final post = posts[index];
              return _PostCard(post: post);
            },
          );
        }
        if (state is SearchError) {
          return Center(child: Text(state.error));
        }
        return Center(child: Text('Search for posts'));
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final dynamic post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final owner = post['owner'] ?? {};
    final firstName = owner['firstName'] ?? '';
    final lastName = owner['lastName'] ?? '';
    final username = owner['username'] ?? '';
    
    return GestureDetector(
      onTap: () {
        context.go(RouteNames.feed, extra: {'postId': post['id']});
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: Text(
                  firstName.isNotEmpty && lastName.isNotEmpty
                      ? '${firstName[0]}${lastName[0]}'
                      : '?',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                firstName.isNotEmpty && lastName.isNotEmpty
                    ? '$firstName $lastName'
                    : 'Unknown User',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                username.isNotEmpty ? '@$username' : '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            if (post['content'] != null && post['content'].toString().isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  post['content'].toString(),
                  style: TextStyle(fontSize: 15),
                ),
              ),
            if (post['files'] != null && 
                post['files'] is List && 
                (post['files'] as List).isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(post['files'][0]),
                    fit: BoxFit.cover,
                    alignment: Alignment(0, -0.3),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PostActionButton(
                    icon: Icons.favorite_border,
                    label: '${(post['likedBy'] as List?)?.length ?? 0}',
                    onTap: () {},
                  ),
                  _PostActionButton(
                    icon: Icons.comment_outlined,
                    label: '${(post['commentIds'] as List?)?.length ?? 0}',
                    onTap: () {},
                  ),
                  _PostActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _formatDate(post['createdAt']?.toString()),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 