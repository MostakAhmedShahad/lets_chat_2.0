part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);

  @override
  List<Object> get props => [error];
}

class AuthenticationFailure extends AuthState {
  final FirebaseAuthException error;

  AuthenticationFailure(this.error);

  @override
  List<Object> get props => [error];
}
