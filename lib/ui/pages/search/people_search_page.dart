import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/search/search_bloc.dart';


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
            return Center(child: Text('No people found.'));
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
        return Center(child: Text('Search for people'));
      },
    );
  }
}

class _PeopleListTile extends StatelessWidget {
  final dynamic person; // Replace with your Person model

  const _PeopleListTile({required this.person});

  @override
  Widget build(BuildContext context) {
    // Example fields: person['name'], person['subtitle'], person['avatarUrl'], person['isFriend'], person['isFollowing']
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
    if (person['isFollowing'] == true) {
  return OutlinedButton(
    onPressed: () {},
    child: Text('Following'),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color.fromRGBO(143, 148, 251, 1),
      side: BorderSide(color: Color.fromRGBO(143, 148, 251, 1)),
    ),
  );
}
return ElevatedButton(
  onPressed: () {},
  child: Text('Follow'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[50],
    foregroundColor: Colors.blue[800],
    elevation: 0,
  ),
);
  }
}