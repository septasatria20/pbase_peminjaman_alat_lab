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
}
