class UserModel {
  final String idUser;
  final String username;
  final String email;
  final String role;
  final String? fullName;
  final String? bio;
  final String? profilePictureUrl;
  final String? createdAt;

  const UserModel({
    required this.idUser,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
    this.bio,
    this.profilePictureUrl,
    this.createdAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: (json['id_user'] ?? json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      fullName: json['full_name'] as String?,
      bio: json['bio'] as String?,
      profilePictureUrl: (json['profile_picture_url'] ?? json['avatar_url']) as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'email': email,
      'role': role,
      'full_name': fullName,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    String? idUser,
    String? username,
    String? email,
    String? role,
    String? fullName,
    String? bio,
    String? profilePictureUrl,
    String? createdAt,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String? token;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    this.token,
    this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json),
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }
}
