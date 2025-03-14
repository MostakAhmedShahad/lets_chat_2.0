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

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
    on<SearchUsers>(_onSearchUsers);
    on<LoadUsersWithPreviousChats>(_onLoadUsersWithPreviousChats);
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await _firestore.collection('messages').add({
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'receiverId': event.receiverId,
        'message': event.message,
        'timestamp': DateTime.now(),
      });
       //emit(MessageSent());
        add(LoadMessages(event.receiverId));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch messages where the current user is either the sender or receiver
      final messages = await _firestore
          .collection('messages')
          .where('senderId', whereIn: [currentUserId, event.receiverId])
          .where('receiverId', whereIn: [currentUserId, event.receiverId])
          .orderBy('timestamp', descending: false)
          .get();

      final messageList = messages.docs.map((doc) => Message.fromMap(doc.data())).toList();
      emit(MessagesLoaded(messages: messageList));
    } catch (e) {
      emit(ChatError('Failed to load messages: $e'));
      print(e);
    }
  }

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

  void _onLoadUsersWithPreviousChats(
    LoadUsersWithPreviousChats event, Emitter<ChatState> emit) async {
  emit(ChatLoading());
  try {
    final users = await _chatRepository.getUsersWithPreviousChats(event.userId);
    emit(UsersWithPreviousChatsLoaded(users: users));
  } catch (e) {
    emit(ChatError('Failed to load users with previous chats: $e'));
  }
}

}
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:lets_chat/models/message_model.dart';
// import 'package:lets_chat/models/user_model.dart';

// part 'chat_event.dart';
// part 'chat_state.dart';

// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   ChatBloc() : super(ChatInitial()) {
//     on<SendMessage>(_onSendMessage);
//     on<LoadMessages>(_onLoadMessages);
//     on<SearchUsers>(_onSearchUsers);
//   }

//   void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
//     try {
//       await _firestore.collection('messages').add({
//         'senderId': FirebaseAuth.instance.currentUser!.uid,
//         'receiverId': event.receiverId,
//         'message': event.message,
//         'timestamp': DateTime.now(),
//       });
//     } catch (e) {
//       emit(ChatError('Failed to send message: $e'));
//     }
//   }

//   void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
//     emit(ChatLoading());
//     try {
//       final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//       // Fetch messages where the current user is either the sender or receiver
//       final messages = await _firestore
//           .collection('messages')
//           .where('senderId', isEqualTo: currentUserId)
//           .where('receiverId', isEqualTo: event.receiverId)
//           .orderBy('timestamp', descending: true)
//           .get();

//       final messageList = messages.docs.map((doc) => Message.fromMap(doc.data())).toList();
//       emit(MessagesLoaded(messages: messageList));
//     } catch (e) {
//       emit(ChatError('Failed to load messages: $e'));
//       print(e);
//     }
//   }

//   void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
//     emit(ChatLoading());
//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .where('email', isEqualTo: event.email)
//           .get();

//       final users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
//       emit(UsersLoaded(users: users));
//     } catch (e) {
//       emit(ChatError('Failed to search users: $e'));
//     }
//   }
// }