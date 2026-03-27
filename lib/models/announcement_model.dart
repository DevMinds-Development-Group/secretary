import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final String name;
  final String description;
  final String type;
  final int dayOfWeek; // 1=Lunes, 7=Domingo
  final String startTime;
  final String specificDate; // Guardamos el string "2026-03-22"
  final List<String> preachers;
  final List<String> worshipMinistry;

  Announcement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.dayOfWeek,
    required this.startTime,
    required this.specificDate,
    required this.preachers,
    required this.worshipMinistry,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    var preachersList =
        (json['preachers'] as List?)
            ?.map((p) => "${p['name']} ${p['lastName']}")
            .toList() ??
        [];

    var worshipMinistryList =
        (json['worshipMinistries'] as List?)
            ?.map((p) => "${p['name']} ${p['lastName']}")
            .toList() ??
        [];

    return Announcement(
      id: json['id'],
      name: json['name'] ?? 'Servicio',
      description: json['description'] ?? '',
      type: json['type'] ?? 'CULTO',
      dayOfWeek: json['dayOfWeek'] ?? 7,
      // Limpiamos el "09:00:00" a "09:00"
      startTime: (json['startTime'] as String).substring(0, 5),
      specificDate: json['specificDate'] ?? '',
      preachers: List<String>.from(preachersList),
      worshipMinistry: List<String>.from(worshipMinistryList),
    );
  }

  // Helper para obtener el nombre corto del día manualmente
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return "LUN";
      case 2:
        return "MAR";
      case 3:
        return "MIE";
      case 4:
        return "JUE";
      case 5:
        return "VIE";
      case 6:
        return "SAB";
      case 7:
        return "DOM";
      default:
        return "DÍA";
    }
  }

  // Extraer el número del día del string "2026-03-22" -> "22"
  String get dayNumber => specificDate.split('-').last;

  Color get color {
    return const Color(0xFF1E293B);
  }

  // Dentro de tu clase Announcement
  String get formattedTime {
    try {
      // El startTime viene como "09:00:00" o "19:30:00"
      List<String> parts = startTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = hour >= 12 ? 'PM' : 'AM';

      // Convertir hora de 24 a 12
      int hour12 = hour % 12;
      if (hour12 == 0) hour12 = 12; // El 00:00 y 12:00 son las 12

      // Formatear minutos para que siempre tengan 2 dígitos (ej: 09:05)
      String minuteStr = minute.toString().padLeft(2, '0');

      return "$hour12:$minuteStr $period";
    } catch (e) {
      return startTime; // Si algo falla, devuelve la hora original
    }
  }
}
