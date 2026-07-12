import 'package:transitops/core/constants/enums.dart';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<UserRole> roles;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: (json['first_name'] ?? json['firstName'] ?? '') as String,
      lastName: (json['last_name'] ?? json['lastName'] ?? '') as String,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => UserRole.fromString(e as String))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'roles': roles.map((e) => e.value).toList(),
    };
  }

  @override
  String toString() => 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, roles: $roles)';
}
