import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/models/user_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now(),
    });
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId, otherUserId])
        .where('receiverId', whereIn: [userId, otherUserId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

 Future<List<UserModel>> searchUsers(String email) async {
  try {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      return []; // Return an empty list if no users are found
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (data != null) {
        return UserModel.fromMap(data);
      } else {
        throw Exception('User data is null');
      }
    }).toList();
  } catch (e) {
    print('Error searching users: $e');
    throw Exception('Failed to search users: $e');
  }
}
}