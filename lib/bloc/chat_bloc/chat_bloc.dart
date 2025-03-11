import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/models/user_model.dart';
  

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatBloc() : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
    on<SearchUsers>(_onSearchUsers);
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'receiverId': event.receiverId,
        'message': event.message,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
  emit(ChatLoading());
  try {
    final messages = await _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: event.receiverId)
        .orderBy('timestamp', descending: true)
        .get();
    emit(ChatLoaded(messages: messages.docs.map((doc) => Message.fromMap(doc.data())).toList())); // Correct usage
  } catch (e) {
    emit(ChatError(e.toString()));
  }
}

//  void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
//   emit(ChatLoading());
//   try {
//     final snapshot = await _firestore
//         .collection('users')
//         .where('email', isEqualTo: event.email)
//         .get();
//     final users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
//     emit(ChatLoaded(users: users)); // Correct usage with named parameters
//   } catch (e) {
//     emit(ChatError(e.toString()));
//   }
// }
// void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
//   emit(ChatLoading());
//   try {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .where('email', isEqualTo: event.email)
//         .get();

//     final users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
//     emit(ChatLoaded(users: users));
//   } catch (e) {
//     emit(ChatError('Failed to search users: $e'));
//   }
// }
void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
  emit(ChatLoading());
  try {
    print('Searching for email: ${event.email}');
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: event.email)
        .get();

    print('Search results: ${snapshot.docs.length}');
    final users = snapshot.docs.map((doc) {
      print('User data: ${doc.data()}');
      return UserModel.fromMap(doc.data());
    }).toList();

    emit(ChatLoaded(users: users));
  } catch (e) {
    print('Search error: $e');
    emit(ChatError('Failed to search users: $e'));
  }
}


}