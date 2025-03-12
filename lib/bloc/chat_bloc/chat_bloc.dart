import 'dart:async';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _messagesSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
    on<SearchUsers>(_onSearchUsers);
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': _auth.currentUser!.uid,
        'receiverId': event.receiverId,
        'message': event.message,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }
   void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final currentUserId = _auth.currentUser!.uid;

      // Use a StreamSubscription to manage the real-time updates
      _messagesSubscription?.cancel();
     _messagesSubscription = _firestore
          .collection('messages')
          .where('senderId', whereIn: [currentUserId, event.receiverId])
          .where('receiverId', whereIn: [currentUserId, event.receiverId])
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        final messages = snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
        emit(MessagesLoaded(messages: messages));
      });
 
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  // void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
  //   emit(ChatLoading());
  //   try {
  //     final currentUserId = _auth.currentUser!.uid;

  //     // Listen for real-time updates
  //     _firestore
  //         .collection('messages')
  //         .where('senderId', whereIn: [currentUserId, event.receiverId])
  //         .where('receiverId', whereIn: [currentUserId, event.receiverId])
  //         .orderBy('timestamp', descending: false)
  //         .snapshots()
  //         .listen((snapshot) {
  //       final messages = snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  //       emit(MessagesLoaded(messages: messages));
  //     });
  //   } catch (e) {
  //     emit(ChatError('Failed to load messages: $e'));
  //   }
  // }

  void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: event.email)
          .get();

      final users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(ChatError('Failed to search users: $e'));
    }
  }
}