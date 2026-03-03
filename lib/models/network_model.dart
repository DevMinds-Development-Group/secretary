// lib/models/network_model.dart

import 'member_model.dart';

class NetworkModel {
  final String id;
  final String name;
  final String? mission;
  final int membersCount;
  final List<Member> leaders;

  NetworkModel({
    required this.id,
    required this.name,
    this.mission,
    required this.membersCount,
    required this.leaders,
  });

  factory NetworkModel.fromJson(Map<String, dynamic> json) {
    return NetworkModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sin Nombre',
      mission: json['mission'],
      membersCount: json['membersCount'] ?? 0,
      leaders:
          (json['leaders'] as List<dynamic>?)
              ?.map((l) => Member.fromJson(l))
              .toList() ??
          [],
    );
  }

  // Método copyWith para facilitar las actualizaciones
  NetworkModel copyWith({
    String? id,
    String? name,
    String? mission,
    int? membersCount,
    List<Member>? leaders,
  }) {
    return NetworkModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mission: mission ?? this.mission,
      membersCount: membersCount ?? this.membersCount,
      leaders: leaders ?? this.leaders,
    );
  }
}
