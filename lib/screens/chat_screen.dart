import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/screens/inbox_screen.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../models/message_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch messages when the screen is opened
    context.read<ChatBloc>().add(LoadMessages(widget.receiverId));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            //Navigator.pop(context); // Navigate back to InboxScreen
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InboxScreen()),
          );
          },
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.receiverId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error loading user details');
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User not found');
            } else {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final userEmail = userData['email'] ?? 'No email';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chat with ${userData['email']}'),
                  Text(
                    'User ID: ${widget.receiverId}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  final messages = state.messages;
                  // Scroll to the bottom when new messages are loaded
                  _scrollToBottom();
                  return ListView.builder(
                   
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text(state.error));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      context.read<ChatBloc>().add(SendMessage(
                            widget.receiverId,
                            message,
                          ));
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
           
        ],
      ),
    );
  }
}
