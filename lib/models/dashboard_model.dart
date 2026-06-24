class DashboardModel {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int totalNetworks;
  final int totalMinistries;
  final List<WeeklyEvent> weeklyEvents;
  final List<MembershipGrowthPoint> membershipGrowth;

  DashboardModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.totalNetworks,
    required this.totalMinistries,
    required this.weeklyEvents,
    required this.membershipGrowth,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalMembers: json['totalMembers'] ?? 0,
      activeMembers: json['activeMembers'] ?? 0,
      inactiveMembers: json['inactiveMembers'] ?? 0,
      totalNetworks: json['totalNetworks'] ?? 0,
      totalMinistries: json['totalMinistries'] ?? 0,
      weeklyEvents:
          (json['weeklyEvents'] as List?)
              ?.map((e) => WeeklyEvent.fromJson(e))
              .toList() ??
          [],
      membershipGrowth:
          (json['membershipGrowth'] as List?)
              ?.map((e) => MembershipGrowthPoint.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Punto de la serie de crecimiento de membresía (total acumulado por mes).
class MembershipGrowthPoint {
  final String label; // p. ej. "Junio 2026"
  final int count; // total acumulado de miembros ese mes

  MembershipGrowthPoint({required this.label, required this.count});

  factory MembershipGrowthPoint.fromJson(Map<String, dynamic> json) {
    return MembershipGrowthPoint(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class WeeklyEvent {
  final String id;
  final String name;
  final String? description;
  final String type;
  final int dayOfWeek;
  final String startTime;
  final bool enabled;
  final String? specificDate;

  WeeklyEvent({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.dayOfWeek,
    required this.startTime,
    required this.enabled,
    this.specificDate,
  });

  factory WeeklyEvent.fromJson(Map<String, dynamic> json) {
    return WeeklyEvent(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      enabled: json['enabled'],
      specificDate: json['specificDate'],
    );
  }
}
