part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String message;

  SendMessage(this.receiverId, this.message);
}

class LoadMessages extends ChatEvent {
  final String receiverId;

  LoadMessages(this.receiverId);
}