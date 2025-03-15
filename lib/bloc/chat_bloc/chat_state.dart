part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<Message> messages;

  const MessagesLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

class UsersLoaded extends ChatState {
  final List<UserModel> users;

  const UsersLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);

  @override
  List<Object> get props => [error];
}
  
 class UsersWithPreviousChatsLoaded extends ChatState {
  final List<UserModel> users;

  const UsersWithPreviousChatsLoaded({required this.users});

  @override
  List<Object> get props => [users];
}