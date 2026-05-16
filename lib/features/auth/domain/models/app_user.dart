enum UserRole {
  admin,
  apprentice,
}

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
}
