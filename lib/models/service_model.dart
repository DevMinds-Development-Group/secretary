import 'package:app/models/member_model.dart';
import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String type;
  final bool recurring;
  final String weekDay;
  final List<Member> preachers;
  final List<Member> worshipMinistries;
  final List<String> preacherIds;
  final List<String> worshipMinistryIds;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    this.recurring = false,
    this.weekDay = '1',
    this.preachers = const [],
    this.worshipMinistries = const [],
    this.preacherIds = const [],
    this.worshipMinistryIds = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final String startTimeStr = json['startTime']?.toString() ?? "00:00:00";
    final List<String> timeParts = startTimeStr.split(':');
    final TimeOfDay timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    List<String> extractIds(dynamic list) {
      if (list == null || !(list is List)) return [];
      return list.map((item) {
        if (item is Map) return item['id']?.toString() ?? '';
        return item.toString();
      }).toList();
    }

    print("JSON RECIBIDO DEL SERVIDOR: $json");

    return ServiceModel(
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'CULTO',
      recurring: json['recurring'] == true,
      weekDay: json['dayOfWeek']?.toString() ?? '1',
      date: json['specificDate'] != null
          ? DateTime.parse(json['specificDate'])
          : DateTime.now(),
      time: timeOfDay,
      preachers:
          (json['preachers'] as List<dynamic>?)
              ?.map((l) => Member.fromJson(l))
              .toList() ??
          [],
      worshipMinistries:
          (json['worshipMinistries'] as List<dynamic>?)
              ?.map((l) => Member.fromJson(l))
              .toList() ??
          [],
      preacherIds: extractIds(json['preacherIds']),
      worshipMinistryIds: extractIds(json['worshipMinistryIds']),
    );
  }

  Map<String, dynamic> toJson() {
    final String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

    // Formato YYYY-MM-DD requerido por Swagger
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return {
      "id": id.isEmpty ? null : id,
      "name": title,
      "description": description,
      "type": type,
      "dayOfWeek": recurring ? _getDayNumber(weekDay) : null,
      "startTime": formattedTime,
      "enabled": true,
      "specificDate": recurring ? null : formattedDate,
      "preacherIds": preacherIds.where((id) => id.isNotEmpty).toList(),
      "worshipMinistryIds": worshipMinistryIds
          .where((id) => id.isNotEmpty)
          .toList(),
      "recurring": recurring,
    };
  }

  int _getDayNumber(String day) {
    final int? parsed = int.tryParse(day);
    if (parsed != null) return parsed;
    switch (day.toUpperCase()) {
      case 'LUNES':
        return 1;
      case 'MARTES':
        return 2;
      case 'MIÉRCOLES':
        return 3;
      case 'JUEVES':
        return 4;
      case 'VIERNES':
        return 5;
      case 'SÁBADO':
        return 6;
      case 'DOMINGO':
        return 7;
      default:
        return 1;
    }
  }
}
