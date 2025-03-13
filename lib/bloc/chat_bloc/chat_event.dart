part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  //final String senderId;
  final String message;

  const SendMessage(this.receiverId, this.message );

  @override
  List<Object> get props => [receiverId, message];
}

class LoadMessages extends ChatEvent {
  final String receiverId;
  //final String senderId;


  const LoadMessages(this.receiverId);

  @override
  List<Object> get props => [receiverId];
}

class SearchUsers extends ChatEvent {
  final String email;

  const SearchUsers(this.email);

  @override
  List<Object> get props => [email];
}