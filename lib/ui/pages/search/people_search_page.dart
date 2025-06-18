import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/theme/app_theme.dart';

class PeopleSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is SearchLoaded) {
          final people = state.results; // Should be a List<Person>
          if (people.isEmpty) {
            return Center(child: Text(AppStrings.noResultsFound.tr(context)));
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: people.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final person = people[index];
              return _PeopleListTile(person: person);
            },
          );
        }
        if (state is SearchError) {
          return Center(child: Text(state.error));
        }
        return Center(child: Text(AppStrings.searchPeople.tr(context)));
      },
    );
  }
}

class _PeopleListTile extends StatelessWidget {
  final dynamic person;

  const _PeopleListTile({required this.person});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: person['profilePic'] != null
            ? NetworkImage(person['profilePic'])
            : AssetImage('assets/images/default_avatar.jpg') as ImageProvider,
      ),
      title: Text(
        person['firstName'] ?? '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        person['lastName'] ?? '',
        style: TextStyle(color: Colors.grey[700], fontSize: 13),
      ),
      trailing: _PeopleActionButton(person: person),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _PeopleActionButton extends StatelessWidget {
  final dynamic person;
  const _PeopleActionButton({required this.person});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    
    if (person['isFollowing'] == true) {
      return OutlinedButton(
        onPressed: () {
          context.read<SearchBloc>().add(UnfollowUser(person['id']));
        },
        child: Text(AppStrings.following.tr(context)),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
        ),
      );
    }
    return ElevatedButton(
      onPressed: () {
        context.read<SearchBloc>().add(FollowUser(person['id']));
      },
      child: Text(AppStrings.follow.tr(context)),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
    );
  }
}