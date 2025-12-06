/// Basic user representation used across the app.
///
/// All fields are nullable so the model can represent guest or
/// unauthenticated states while remaining easy to extend with new fields.
class UserEntity {
  const UserEntity({
    this.id,
    this.name,
    this.email,
  });

  final String? id;
  final String? name;
  final String? email;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as String?,
        name: json['name'] as String?,
        email: json['email'] as String?,
      );
}
