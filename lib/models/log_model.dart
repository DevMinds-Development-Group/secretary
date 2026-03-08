// lib/models/log_model.dart

class Log {
  final String id;
  final String username;
  final String module;
  final String action;
  final String? type;
  final String details;
  final DateTime timestamp;

  Log({
    required this.id,
    required this.timestamp,
    required this.username,
    required this.details,
    required this.module,
    required this.action,
    this.type,
  });
  factory Log.fromJson(Map<String, dynamic> json) {
    String dateStr =
        json['timestamp'] ??
        json['createdAt'] ??
        DateTime.now().toIso8601String();

    return Log(
      id: json['id'].toString(),
      username: json['username'] ?? 'N/A',
      module: json['module'] ?? '',
      action: json['action'] ?? '',
      type: json['type'],
      details: json['details'],
      timestamp: DateTime.parse(
        json['timestamp'] ?? json['createdAt'],
      ).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'module': module,
      'action': action,
      'type': type,
      'details': details,
    };
  }
}
