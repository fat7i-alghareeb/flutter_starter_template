class AuthLoginResponseModel {
  const AuthLoginResponseModel({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
  });

  final String id;
  final String accessToken;
  final String refreshToken;

  factory AuthLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseModel(
      id: json['id'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
