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
  final String firstName;
  final String lastName;
  final UserRole role;

  const AuthRegisterSubmitted({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
  });
}

class AuthLogoutRequested extends AuthEvent {}
