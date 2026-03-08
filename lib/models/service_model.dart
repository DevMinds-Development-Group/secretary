// lib/models/service_model.dart
import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String preacher;
  final String worshipMinister;
  final String type;
  final bool enabled;
  final bool recurring;

  ServiceModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    this.preacher = '',
    this.worshipMinister = '',
    this.type = 'REUNION_MINISTERIO',
    this.enabled = true,
    this.recurring = false,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Extraemos la hora del objeto startTime
    final startTime = json['startTime'] as Map<String, dynamic>?;
    final hour = startTime?['hour'] ?? 0;
    final minute = startTime?['minute'] ?? 0;

    return ServiceModel(
      id: json['id'] ?? '',
      title: json['name'] ?? '', // El backend usa 'name'
      // Si el backend no envía 'date', usamos la fecha actual por ahora
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      time: TimeOfDay(hour: hour, minute: minute),
      preacher: json['preacher'] ?? '',
      worshipMinister: json['worshipMinister'] ?? '',
      type: json['type'] ?? 'REUNION_MINISTERIO',
      enabled: json['enabled'] ?? true,
      recurring: json['recurring'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": title, // Mapeamos title -> name para el backend
      "type": type,
      "enabled": enabled,
      "recurring": recurring,
      "startTime": {
        "hour": time.hour,
        "minute": time.minute,
        "second": 0,
        "nano": 0,
      },
      "preacher": preacher,
      "worshipMinister": worshipMinister,
      "date":
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    };
  }
}
