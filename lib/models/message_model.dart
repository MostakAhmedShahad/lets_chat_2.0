 

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      timestamp: data['timestamp'].toDate(),
    );
  }
}