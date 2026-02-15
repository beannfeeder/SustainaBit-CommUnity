/// User roles in the application.
/// 'user' is the default role. 'management' can be set manually in Firebase Console.
enum UserRole {
  user,
  management;

  static UserRole fromString(String? value) {
    if (value == 'management') return UserRole.management;
    return UserRole.user;
  }
}

/// Example user model
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final int impactScore;
  final DateTime createdAt;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.impactScore,
    required this.createdAt,
    this.role = UserRole.user,
  });

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      impactScore: json['impactScore'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: UserRole.fromString(json['role'] as String?),
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'impactScore': impactScore,
      'createdAt': createdAt.toIso8601String(),
      'role': role.name,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    int? impactScore,
    DateTime? createdAt,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      impactScore: impactScore ?? this.impactScore,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  bool get isManagement => role == UserRole.management;
}
