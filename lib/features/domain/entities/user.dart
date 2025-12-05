class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? lab; // BA, IS, SE, STUDIO, NCS (only for admin)

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.lab,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? lab,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      lab: lab ?? this.lab,
    );
  }
}
