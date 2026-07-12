import 'package:transitops/core/constants/enums.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});
}

class AuthRegisterSubmitted extends AuthEvent {
  final String email;
  final String password;
  final UserRole role;

  const AuthRegisterSubmitted({
    required this.email,
    required this.password,
    required this.role,
  });
}

class AuthLogoutRequested extends AuthEvent {}
