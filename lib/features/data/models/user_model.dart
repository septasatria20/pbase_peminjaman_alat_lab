import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String name,
    required String email,
    required String role,
    String? lab,
  }) : super(
          id: id,
          name: name,
          email: email,
          role: role,
          lab: lab,
        );

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      lab: json['lab'], // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (lab != null) 'lab': lab,
    };
  }
}
