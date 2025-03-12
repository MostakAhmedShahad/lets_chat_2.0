import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isSender;

  const MessageBubble({
    required this.message,
    required this.timestamp,
    required this.isSender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isSender ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute}',
              style: TextStyle(
                color: isSender ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../models/message_model.dart';

// class MessageBubble extends StatelessWidget {
//   final Message message;
//   final bool isMe;

//   MessageBubble({required this.message, required this.isMe});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue : Colors.grey[300],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           message.message,
//           style: TextStyle(color: isMe ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }
// }