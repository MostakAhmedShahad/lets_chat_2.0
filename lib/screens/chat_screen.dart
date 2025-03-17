import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/bloc/chat_bloc/chat_bloc.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/screens/inbox_screen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({required this.receiverId}); //resizeToAvoidBottomInset

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    // Start listening for messages
    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(LoadMessages(widget.receiverId));

    // Listen for real-time updates
    _messagesSubscription = FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', whereIn: [FirebaseAuth.instance.currentUser!.uid, widget.receiverId])
        .where('receiverId', whereIn: [FirebaseAuth.instance.currentUser!.uid, widget.receiverId])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      chatBloc.add(MessagesUpdated(messages)); // Add a new event to update the state
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel(); // Dispose of the listener
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure the screen resizes when the keyboard appears
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
              return Text('Loading...', style: TextStyle(color: Colors.white));
            } else if (snapshot.hasError) {
              return Text('Error loading user', style: TextStyle(color: Colors.white));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('User not found', style: TextStyle(color: Colors.white));
            } else {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(userData['email'] ?? 'No email'),
                ],
              );
            }
          },
        ),
        backgroundColor: Colors.green,
        elevation: 5,
      ),
      body: Center(
        child: Container(
          width: 600, // Web-friendly width
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  buildWhen: (previous, current) {
                    return current is MessagesLoaded || current is ChatError;
                  },
                  builder: (context, state) {
                    if (state is MessagesLoaded) {
                      final messages = state.messages;
                      _scrollToBottom(); // Scroll to the bottom when new messages arrive
                      return ScrollConfiguration(
                        behavior: NoScrollBehavior(),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == currentUserId;

                            return Align(
                              alignment:
                                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 6),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.green.withOpacity(0.9)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message.message,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else if (state is ChatError) {
                      return Center(
                        child: Text(state.error, style: TextStyle(color: Colors.red)),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),

              // Message Input Box
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      backgroundColor: Colors.green,
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
                      child: Icon(Icons.send, color: Colors.white),
                      mini: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Removes the scroll bar
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Removes the overscroll indicator
  }
}