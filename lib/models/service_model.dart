import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String type;
  final List<String> preachers;
  final List<String> worshipMinistries;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.type,
    this.preachers = const [],
    this.worshipMinistries = const [],
  });

  // --- FROM JSON: Para recibir datos del Backend ---
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // El backend envía "startTime": "09:00:00"
    final String startTimeStr = json['startTime'] ?? "00:00:00";
    final List<String> timeParts = startTimeStr.split(':');

    return ServiceModel(
      id: json['id'] ?? '',
      title: json['name'] ?? 'Sin nombre', // Mapeo de 'name' a 'title'
      description: json['description'] ?? '',
      type: json['type'] ?? 'CULTO',
      // El backend envía "specificDate": "2026-03-09"
      date: json['specificDate'] != null
          ? DateTime.parse(json['specificDate'])
          : DateTime.now(),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      // Mapeo seguro de listas dinámicas a List<String>
      preachers:
          (json['preachers'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      worshipMinistries:
          (json['worshipMinistries'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  // --- TO JSON: Para enviar datos al Backend (Crear/Editar) ---
  Map<String, dynamic> toJson() {
    return {
      "id": id.isEmpty ? null : id, // Si es nuevo, el ID suele ser nulo
      "name": title,
      "description": description,
      "type": type,
      // Formato "yyyy-MM-dd"
      "specificDate":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      // Formato "HH:mm:ss"
      "startTime":
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00",
      "preachers": preachers,
      "worshipMinistries": worshipMinistries,
    };
  }
}
