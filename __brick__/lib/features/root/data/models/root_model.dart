class RootModel {
  const RootModel({required this.id});

  final int id;

  factory RootModel.fromMap(Map<String, dynamic> map) {
    final raw = map['id'];
    final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
    return RootModel(id: id);
  }
}
