import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inbox')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    final email = _searchController.text.trim();
                    if (email.isNotEmpty) {
                      context.read<ChatBloc>().add(SearchUsers(email));
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is UsersLoaded) {
                  final users = state.users;
                  if (users.isEmpty) {
                    return Center(child: Text('No users found'));
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(receiverId: user.uid),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text(state.error));
                } else if (state is ChatLoading) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Center(child: Text('Search for users by email'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 