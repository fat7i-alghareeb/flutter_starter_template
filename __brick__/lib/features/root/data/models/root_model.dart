class RootModel {
  const RootModel({required this.id});

  final String id;

  factory RootModel.fromJson(Map<String, dynamic> json) {
    return RootModel(id: json["id"]);
  }
}
