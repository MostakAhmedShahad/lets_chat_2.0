import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
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
          return snapshot.docs
              .map((doc) => Message.fromMap(doc.data()))
              .toList();
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

  Future<List<UserModel>> getUsersWithPreviousChats(String userId) async {
    try {
      // Fetch messages where the current user is either the sender or receiver
      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId)
          .get();

      // Extract unique user IDs from the messages
      final receiverIds = messagesSnapshot.docs
          .map((doc) => doc['receiverId'] as String)
          .toSet()
          .toList();

      // Fetch user details for the receiver IDs
      final users = await Future.wait(
        receiverIds.map((receiverId) async {
          final userSnapshot =
              await _firestore.collection('users').doc(receiverId).get();
          return UserModel.fromMap(userSnapshot.data()!);
        }),
      );

      return users;
    } catch (e) {
      print('Error fetching users with previous chats: $e');
      throw Exception('Failed to fetch users with previous chats: $e');
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
