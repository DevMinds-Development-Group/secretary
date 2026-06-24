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
    this.observations = "",
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    Set<String> extractedIds = {};

    if (json['presentMembers'] != null) {
      extractedIds = (json['presentMembers'] as List)
          .map((member) => member['id'].toString())
          .toSet();
    } else if (json['presentMembers'] != null) {
      extractedIds = (json['presentMembers'] as List)
          .map((id) => id.toString())
          .toSet();
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
