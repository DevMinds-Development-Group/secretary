import 'member_model.dart';

class MinistryModel {
  final String id;
  String name;
  final String description;
  final List<Member> leaders;
  final List<Member> members;
  final int membersCount;

  MinistryModel({
    required this.id,
    required this.name,
    required this.description,
    this.leaders = const [],
    this.members = const [],
    this.membersCount = 0,
  });

  MinistryModel copyWith({
    String? id,
    String? name,
    String? description,
    List<Member>? leaders,
    List<Member>? members,
    int? membersCount,
  }) {
    return MinistryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      leaders: leaders ?? this.leaders,
      members: members ?? this.members,
      membersCount: membersCount ?? this.membersCount,
    );
  }

  factory MinistryModel.fromJson(Map<String, dynamic> json) {
    return MinistryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      membersCount: json['membersCount'] ?? 0,
      leaders:
          (json['leaders'] as List<dynamic>?)
              ?.map((l) => Member.fromJson(l))
              .toList() ??
          [],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((m) => Member.fromJson(m))
              .toList() ??
          [],
    );
  }
}
