import 'member_model.dart';

class AttendanceModel {
  final String id;
  final String definitionId;
  final String? definitionName;
  final String networkId;
  final String? networkName;
  final DateTime date;
  final int visitorsCount;
  final int pastoralVisitsCount;
  final int newConvert;
  final Set<String> presentMemberIds;

  /// Miembros presentes tal como los devuelve el backend (proyección histórica:
  /// id/name/lastName/phone). Se renderizan directamente en el detalle, sin
  /// depender de `MemberProvider.allMembers` (que puede no estar cargado).
  final List<Member> presentMembers;
  final String observations;

  AttendanceModel({
    required this.id,
    required this.definitionId,
    this.definitionName,
    required this.networkId,
    this.networkName,
    required this.date,
    required this.visitorsCount,
    required this.pastoralVisitsCount,
    required this.newConvert,
    required this.presentMemberIds,
    this.presentMembers = const [],
    this.observations = "",
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final List<Member> present = [];
    final Set<String> extractedIds = {};

    final raw = json['presentMembers'];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          final member = Member.fromJson(entry);
          present.add(member);
          extractedIds.add(member.id);
        } else if (entry != null) {
          extractedIds.add(entry.toString());
        }
      }
    }

    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      definitionId: json['definitionId']?.toString() ?? '',
      definitionName:
          json['eventName'] ?? json['definitionName'] ?? 'Sin nombre',
      networkName: json['networkName']?.toString(),
      networkId: json['networkId']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      visitorsCount: json['visitorsCount'] ?? 0,
      pastoralVisitsCount: json['pastoralVisitsCount'] ?? 0,
      newConvert: json['newConvert'] ?? 0,
      observations: json['observations'] ?? '',
      presentMemberIds: extractedIds,
      presentMembers: present,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      if (id.isNotEmpty) "id": id,
      "definitionId": definitionId,
      "networkId": networkId,
      "date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "visitorsCount": visitorsCount,
      "pastoralVisitsCount": pastoralVisitsCount,
      "newConvert": newConvert,
      "observations": observations,
      "presentMemberIds": presentMemberIds.toList(),
    };

    if (id.isNotEmpty) {
      data["id"] = id;
    }

    return data;
  }
}
