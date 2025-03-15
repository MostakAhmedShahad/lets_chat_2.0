import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class InboxScreen extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch users with previous chats when the screen is opened
    context.read<ChatBloc>().add(LoadUsersWithPreviousChats(currentUserId));

    return Scaffold(
      appBar: AppBar(title: Text('Inbox')),
      body: Column(
        children: [
          // Search Bar
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
          // List of Users
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is UsersWithPreviousChatsLoaded) {
                  // Display users with previous chats
                  final users = state.users;
                  if (users.isEmpty) {
                    return Center(child: Text('No previous chats found'));
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
                } else if (state is UsersLoaded) {
                  // Display users found by email search
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
                  return Center(child: Text('Search for users by email or view previous chats'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}