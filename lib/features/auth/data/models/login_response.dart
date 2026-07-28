class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.type,
    required this.userId,
    required this.email,
    required this.role,
  });

  final String token;
  final String type;
  final int userId;
  final String email;
  final String role;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      type: json['type'] as String? ?? 'Bearer',
      userId: json['userId'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'userId': userId,
      'email': email,
      'role': role,
    };
  }
}
