import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lets_chat/models/message_model.dart';
import 'package:lets_chat/models/user_model.dart';
import 'package:lets_chat/repositories/chat_repositories.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatRepository _chatRepository;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
    on<SearchUsers>(_onSearchUsers);
    on<LoadUsersWithPreviousChats>(_onLoadUsersWithPreviousChats);
    on<MessagesUpdated>(_onMessagesUpdated);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel(); // Dispose of the listener
    return super.close();
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(MessagesLoaded(messages: event.messages));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final timestamp = DateTime.now();

      // Add message to Firestore
      await _firestore.collection('messages').add({
        'senderId': currentUserId,
        'receiverId': event.receiverId,
        'message': event.message,
        'timestamp': timestamp,
      });

      // Update last message timestamp for both users
      await _firestore.collection('users').doc(currentUserId).update({
        'lastMessageTimestamp': timestamp,
      });

      await _firestore.collection('users').doc(event.receiverId).update({
        'lastMessageTimestamp': timestamp,
      });

      // Reload messages and inbox
      add(LoadUsersWithPreviousChats(currentUserId));
      add(LoadMessages(event.receiverId));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Listen for real-time updates in the messages collection
      _messagesSubscription = _firestore
          .collection('messages')
          .where('senderId', whereIn: [currentUserId, event.receiverId])
          .where('receiverId', whereIn: [currentUserId, event.receiverId])
          .orderBy('timestamp', descending: false)
          .snapshots()
          .listen((snapshot) {
        final messageList =
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
        add(MessagesUpdated(messageList)); // Emit updated messages
      });
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: event.email)
          .get();

      final users =
          snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      emit(UsersLoaded(users: users));
    } catch (e) {
      emit(ChatError('Failed to search users: $e'));
    }
  }

  void _onLoadUsersWithPreviousChats(
      LoadUsersWithPreviousChats event, Emitter<ChatState> emit) async {
    if (state is ChatLoading) return; // Prevent multiple loaders
    emit(ChatLoading());

    try {
      final users = await _chatRepository.getUsersWithPreviousChats(event.userId);

      // Sort users by last message timestamp
      users.sort((b, a) {
        if (a.lastMessageTimestamp == null && b.lastMessageTimestamp == null) {
          return 0;
        } else if (a.lastMessageTimestamp == null) {
          return 1;
        } else if (b.lastMessageTimestamp == null) {
          return -1;
        } else {
          return b.lastMessageTimestamp!.compareTo(a.lastMessageTimestamp!);
        }
      });

      emit(UsersWithPreviousChatsLoaded(users: users));
    } catch (e) {
      emit(ChatError('Failed to load users: $e'));
    }
  }
}