/// Basic user representation used across the app.
///
/// All fields are nullable so the model can represent guest or
/// unauthenticated states while remaining easy to extend with new fields.
class UserEntity {
  const UserEntity({this.id, this.name, this.email, this.photoUrl});

  final String? id;
  final String? name;
  final String? email;

  /// The Google picture. Not editable in the app, so
  /// it is carried as-is and shown where the account is — the home header.
  final String? photoUrl;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );
}
