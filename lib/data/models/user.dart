/// User model for authentication and profile management
class User {
  final String uid;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? role; // admin, pharmacist, cashier, manager
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const User({
    required this.uid,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role = 'user',
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  /// Create User from JSON (Firebase)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String? ?? 'user',
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? json['lastLoginAt'] is DateTime
              ? json['lastLoginAt'] as DateTime
              : DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role,
        'profileImageUrl': profileImageUrl,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'isEmailVerified': isEmailVerified,
      };

  /// Create a copy with modified fields
  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() =>
      'User(uid: $uid, email: $email, fullName: $fullName, role: $role)';
}

