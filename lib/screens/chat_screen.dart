
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/widgets/message_bubble.dart';
import '../bloc/chat_bloc/chat_bloc.dart';
import '../models/message_model.dart';


class ChatScreen extends StatelessWidget {
  final String receiverId;
  final _messageController = TextEditingController();

  ChatScreen({required this.receiverId});

  @override
  Widget build(BuildContext context) {
    // Fetch messages when the screen is opened
    context.read<ChatBloc>().add(LoadMessages(receiverId));

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  final messages = state.messages;
                  return ListView.builder(
                    reverse: false, // Oldest at the top, newest at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.senderId == FirebaseAuth.instance.currentUser!.uid;

                      return MessageBubble(
                        message: message.message,
                        timestamp: message.timestamp,
                        isSender: isSender,
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
                            receiverId,
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/chat_bloc/chat_bloc.dart';
// import '../models/message_model.dart';

// class ChatScreen extends StatelessWidget {
//   final String receiverId;
//   final _messageController = TextEditingController();

//   ChatScreen({required this.receiverId});

//   @override
//   Widget build(BuildContext context) {
//     // Fetch messages when the screen is opened
//     context.read<ChatBloc>().add(LoadMessages(receiverId));

//     return Scaffold(
//       appBar: AppBar(title: Text('Chat')),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is MessagesLoaded) {
//                   final messages = state.messages;
//                   return ListView.builder(
//                     reverse: true, // Show latest messages at the bottom
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//                       return ListTile(
//                         title: Text(message.message),
//                         subtitle: Text(
//                           '${message.timestamp.toLocal()}',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       );
//                     },
//                   );
//                 } else if (state is ChatError) {
//                   return Center(child: Text(state.error));
//                 } else {
//                   return Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(labelText: 'Type a message'),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     final message = _messageController.text.trim();
//                     if (message.isNotEmpty) {
//                       context.read<ChatBloc>().add(SendMessage(
//                             receiverId,
//                             message,
//                           ));
//                       _messageController.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
