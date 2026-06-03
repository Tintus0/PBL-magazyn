class AppUser {
  final int id;
  final String username;
  final String fullName;
  final String role;

  AppUser({required this.id, required this.username, required this.fullName, required this.role});

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int,
        username: map['username'] as String,
        fullName: map['full_name'] as String,
        role: map['role'] as String,
      );
}
