 import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    await _firestore.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now(),
    });
    print('Message sent');
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    print('Fetching messages...');

    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [userId, otherUserId])
        .where('receiverId', whereIn: [userId, otherUserId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            print('No messages found.');
          }
          return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
        });
  }

  Future<List<UserModel>> searchUsers(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }
}
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:lets_chat/models/user_model.dart';
// import '../models/message_model.dart';

// class ChatRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> sendMessage(String senderId, String receiverId, String message) async {
//     await _firestore.collection('messages').add({
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'message': message,
//       'timestamp': DateTime.now(),
     
//     });
//      print('msg sent');
//   }

//  Stream<List<Message>> getMessages(String userId, String otherUserId) {
//   print('Fetching messages...');
  
//   return _firestore
//       .collection('messages')
//       .where('senderId', whereIn: [userId, otherUserId])
//       .where('receiverId', whereIn: [userId, otherUserId])
//       .orderBy('timestamp', descending: false)
//       .snapshots()
//       .map((snapshot) {
//         if (snapshot.docs.isEmpty) {
//           print('No messages found.');
//         }
//         return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
//       });
// }



//   Future<List<UserModel>> searchUsers(String email) async {
//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .get();

//       return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
//     } catch (e) {
//       print('Error searching users: $e');
//       throw Exception('Failed to search users: $e');
//     }
//   }
// }
