import 'package:transitops/core/constants/enums.dart';

class User {
  final String id;
  final String email;
  final List<UserRole> roles;

  User({
    required this.id,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
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
      'roles': roles.map((e) => e.value).toList(),
    };
  }

  @override
  String toString() => 'User(id: $id, email: $email, roles: $roles)';
}
