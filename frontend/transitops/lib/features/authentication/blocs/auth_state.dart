import 'package:transitops/features/authentication/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
}
