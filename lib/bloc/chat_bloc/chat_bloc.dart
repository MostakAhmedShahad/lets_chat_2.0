import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatBloc() : super(ChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<LoadMessages>(_onLoadMessages);
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
      emit(ChatLoaded(messages.docs.map((doc) => Message.fromMap(doc.data())).toList()));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}