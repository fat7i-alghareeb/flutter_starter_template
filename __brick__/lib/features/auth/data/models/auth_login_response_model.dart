/// What the sign-in endpoint returns.
class AuthLoginResponseModel {
  const AuthLoginResponseModel({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
    this.name,
    this.email,
    this.photoUrl,
    this.phone,
  });

  factory AuthLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponseModel(
      id: json['id'] as String? ?? '',
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phone: json['phone'] as String?,
    );
  }

  final String id;
  final String accessToken;
  final String refreshToken;

  final String? name;
  final String? email;

  /// The account picture, if the backend has one.
  final String? photoUrl;
  final String? phone;
}
