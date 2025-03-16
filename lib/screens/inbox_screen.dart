import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/bloc/chat_bloc/chat_bloc.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/screens/chat_screen.dart';

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController(); //chatscreen

  @override
  void initState() {
    super.initState();
    final chatBloc = context.read<ChatBloc>();
    if (chatBloc.state is! UsersWithPreviousChatsLoaded) {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      chatBloc.add(LoadUsersWithPreviousChats(currentUserId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          width: 600, // Web-friendly width
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            children: [
              // Search Bar with Glassmorphism Effect
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // Glass effect
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by email',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.deepPurple),
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
              SizedBox(height: 20),

              // User List
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is UsersWithPreviousChatsLoaded ||
                        state is UsersLoaded) {
                      final users = state is UsersWithPreviousChatsLoaded
                          ? state.users
                          : (state as UsersLoaded).users;
                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            'No previous chats found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      // Reverse the users list to show the latest first
                      final reversedUsers = List<UserModel>.from(users.reversed);

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: reversedUsers.length,
                        itemBuilder: (context, index) {
                          final user = reversedUsers[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: context.read<ChatBloc>(),
                                    child: ChatScreen(receiverId: user.uid),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.deepPurple, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey[600]),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(
                        child: Text(state.error,
                            style: TextStyle(color: Colors.red)),
                      );
                    } else if (state is ChatLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Center(
                        child: Text(
                          'Search for users by email or view previous chats',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
