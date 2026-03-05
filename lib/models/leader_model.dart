class LeaderModel {
  final String id;
  final String name;

  const LeaderModel({required this.id, required this.name});

  factory LeaderModel.fromJson(Map<String, dynamic> json) {
    return LeaderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Sin nombre',
    );
  }

  // También es buena idea reforzar el método toJson si lo tienes
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
