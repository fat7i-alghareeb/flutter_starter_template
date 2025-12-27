class AuthModel {
  const AuthModel({required this.id});

  final int id;

  factory AuthModel.fromMap(Map<String, dynamic> map) {
    final raw = map['id'];
    final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
    return AuthModel(id: id);
  }
}
