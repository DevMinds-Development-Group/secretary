import 'dashboard_model.dart' show MembershipGrowthPoint;

/// Modelo del dashboard de supervisión (apóstol/pastor).
/// Mapea `ApostolDashboardResponse` del backend (módulo apostol-dashboard).

int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
String? _toStr(dynamic v) => v?.toString();

Map<String, int> _toIntMap(dynamic v) =>
    (v as Map?)?.map(
      (k, val) => MapEntry(k.toString(), (val as num?)?.toInt() ?? 0),
    ) ??
    <String, int>{};

List<String> _toStrList(dynamic v) =>
    (v as List?)?.map((e) => e.toString()).toList() ?? const [];

class ApostolDashboardModel {
  final String? generatedAt;
  final String periodStart;
  final String periodEnd;
  final String periodLabel;
  final OverviewSection overview;
  final StructureSection structure;
  final List<LeaderWork> leaderWork;
  final AttendanceSection attendance;
  final EventsSection events;
  final MembershipSection membership;
  final SystemActivitySection systemActivity;

  ApostolDashboardModel({
    this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.overview,
    required this.structure,
    required this.leaderWork,
    required this.attendance,
    required this.events,
    required this.membership,
    required this.systemActivity,
  });

  factory ApostolDashboardModel.fromJson(Map<String, dynamic> json) {
    return ApostolDashboardModel(
      generatedAt: _toStr(json['generatedAt']),
      periodStart: json['periodStart']?.toString() ?? '',
      periodEnd: json['periodEnd']?.toString() ?? '',
      periodLabel: json['periodLabel']?.toString() ?? '',
      overview: OverviewSection.fromJson(json['overview'] ?? const {}),
      structure: StructureSection.fromJson(json['structure'] ?? const {}),
      leaderWork: (json['leaderWork'] as List?)
              ?.map((e) => LeaderWork.fromJson(e ?? const {}))
              .toList() ??
          const [],
      attendance: AttendanceSection.fromJson(json['attendance'] ?? const {}),
      events: EventsSection.fromJson(json['events'] ?? const {}),
      membership: MembershipSection.fromJson(json['membership'] ?? const {}),
      systemActivity:
          SystemActivitySection.fromJson(json['systemActivity'] ?? const {}),
    );
  }
}

class OverviewSection {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int totalNetworks;
  final int totalMinistries;
  final List<MembershipGrowthPoint> membershipGrowth;

  OverviewSection({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.totalNetworks,
    required this.totalMinistries,
    required this.membershipGrowth,
  });

  factory OverviewSection.fromJson(Map<String, dynamic> json) {
    return OverviewSection(
      totalMembers: _toInt(json['totalMembers']),
      activeMembers: _toInt(json['activeMembers']),
      inactiveMembers: _toInt(json['inactiveMembers']),
      totalNetworks: _toInt(json['totalNetworks']),
      totalMinistries: _toInt(json['totalMinistries']),
      membershipGrowth: (json['membershipGrowth'] as List?)
              ?.map((e) => MembershipGrowthPoint.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}

class LeaderIdentity {
  final String displayName;
  final String? username;

  LeaderIdentity({required this.displayName, this.username});

  factory LeaderIdentity.fromJson(Map<String, dynamic> json) {
    return LeaderIdentity(
      displayName: json['displayName']?.toString() ?? '—',
      username: _toStr(json['username']),
    );
  }
}

class StructureSection {
  final List<NetworkStructure> networks;
  final List<MinistryStructure> ministries;
  final int networksWithoutLeaders;
  final int ministriesWithoutLeaders;

  StructureSection({
    required this.networks,
    required this.ministries,
    required this.networksWithoutLeaders,
    required this.ministriesWithoutLeaders,
  });

  factory StructureSection.fromJson(Map<String, dynamic> json) {
    return StructureSection(
      networks: (json['networks'] as List?)
              ?.map((e) => NetworkStructure.fromJson(e ?? const {}))
              .toList() ??
          const [],
      ministries: (json['ministries'] as List?)
              ?.map((e) => MinistryStructure.fromJson(e ?? const {}))
              .toList() ??
          const [],
      networksWithoutLeaders: _toInt(json['networksWithoutLeaders']),
      ministriesWithoutLeaders: _toInt(json['ministriesWithoutLeaders']),
    );
  }
}

class NetworkStructure {
  final String name;
  final List<LeaderIdentity> leaders;
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;

  NetworkStructure({
    required this.name,
    required this.leaders,
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
  });

  factory NetworkStructure.fromJson(Map<String, dynamic> json) {
    return NetworkStructure(
      name: json['name']?.toString() ?? '—',
      leaders: (json['leaders'] as List?)
              ?.map((e) => LeaderIdentity.fromJson(e ?? const {}))
              .toList() ??
          const [],
      totalMembers: _toInt(json['totalMembers']),
      activeMembers: _toInt(json['activeMembers']),
      inactiveMembers: _toInt(json['inactiveMembers']),
    );
  }

  String get leaderNames =>
      leaders.isEmpty ? 'Sin líder' : leaders.map((l) => l.displayName).join(', ');
}

class MinistryStructure {
  final String name;
  final List<LeaderIdentity> leaders;
  final int memberCount;

  MinistryStructure({
    required this.name,
    required this.leaders,
    required this.memberCount,
  });

  factory MinistryStructure.fromJson(Map<String, dynamic> json) {
    return MinistryStructure(
      name: json['name']?.toString() ?? '—',
      leaders: (json['leaders'] as List?)
              ?.map((e) => LeaderIdentity.fromJson(e ?? const {}))
              .toList() ??
          const [],
      memberCount: _toInt(json['memberCount']),
    );
  }

  String get leaderNames =>
      leaders.isEmpty ? 'Sin líder' : leaders.map((l) => l.displayName).join(', ');
}

class AttendanceObservation {
  final String? date;
  final String? eventName;
  final String? networkName;
  final String? excerpt;

  AttendanceObservation({this.date, this.eventName, this.networkName, this.excerpt});

  factory AttendanceObservation.fromJson(Map<String, dynamic> json) {
    return AttendanceObservation(
      date: _toStr(json['date']),
      eventName: _toStr(json['eventName']),
      networkName: _toStr(json['networkName']),
      excerpt: _toStr(json['excerpt']),
    );
  }
}

class NetworkAttendanceSummary {
  final String networkName;
  final String? leaderDisplayName;
  final int memberAttendanceTotal;
  final int visitorsTotal;
  final int pastoralVisitsTotal;
  final int newConvertsTotal;
  final int attendanceRecords;

  NetworkAttendanceSummary({
    required this.networkName,
    this.leaderDisplayName,
    required this.memberAttendanceTotal,
    required this.visitorsTotal,
    required this.pastoralVisitsTotal,
    required this.newConvertsTotal,
    required this.attendanceRecords,
  });

  factory NetworkAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return NetworkAttendanceSummary(
      networkName: json['networkName']?.toString() ?? '—',
      leaderDisplayName: _toStr(json['leaderDisplayName']),
      memberAttendanceTotal: _toInt(json['memberAttendanceTotal']),
      visitorsTotal: _toInt(json['visitorsTotal']),
      pastoralVisitsTotal: _toInt(json['pastoralVisitsTotal']),
      newConvertsTotal: _toInt(json['newConvertsTotal']),
      attendanceRecords: _toInt(json['attendanceRecords']),
    );
  }
}

class AttendanceSection {
  final int memberAttendanceTotal;
  final int visitorsTotal;
  final int pastoralVisitsTotal;
  final int newConvertsTotal;
  final List<NetworkAttendanceSummary> networkSummaries;
  final List<String> networksWithoutRecords;
  final List<AttendanceObservation> observations;

  AttendanceSection({
    required this.memberAttendanceTotal,
    required this.visitorsTotal,
    required this.pastoralVisitsTotal,
    required this.newConvertsTotal,
    required this.networkSummaries,
    required this.networksWithoutRecords,
    required this.observations,
  });

  factory AttendanceSection.fromJson(Map<String, dynamic> json) {
    return AttendanceSection(
      memberAttendanceTotal: _toInt(json['memberAttendanceTotal']),
      visitorsTotal: _toInt(json['visitorsTotal']),
      pastoralVisitsTotal: _toInt(json['pastoralVisitsTotal']),
      newConvertsTotal: _toInt(json['newConvertsTotal']),
      networkSummaries: (json['networkSummaries'] as List?)
              ?.map((e) => NetworkAttendanceSummary.fromJson(e ?? const {}))
              .toList() ??
          const [],
      networksWithoutRecords: _toStrList(json['networksWithoutRecords']),
      observations: (json['observations'] as List?)
              ?.map((e) => AttendanceObservation.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}

class LeaderEventAssignment {
  final String? date;
  final String? eventName;
  final String? role;
  final String? displayName;

  LeaderEventAssignment({this.date, this.eventName, this.role, this.displayName});

  factory LeaderEventAssignment.fromJson(Map<String, dynamic> json) {
    return LeaderEventAssignment(
      date: _toStr(json['date']),
      eventName: _toStr(json['eventName']),
      role: _toStr(json['role']),
      displayName: _toStr(json['displayName']),
    );
  }
}

class LeaderStructureScope {
  final List<String> networks;
  final List<String> ministries;
  final int membersUnderResponsibility;

  LeaderStructureScope({
    required this.networks,
    required this.ministries,
    required this.membersUnderResponsibility,
  });

  factory LeaderStructureScope.fromJson(Map<String, dynamic> json) {
    List<String> names(dynamic v) =>
        (v as List?)
            ?.map((e) => (e is Map ? e['name'] : e)?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        const [];
    return LeaderStructureScope(
      networks: names(json['networks']),
      ministries: names(json['ministries']),
      membersUnderResponsibility: _toInt(json['membersUnderResponsibility']),
    );
  }
}

class LeaderAttendanceWork {
  final int attendanceRecords;
  final int memberAttendanceTotal;
  final int visitorsTotal;
  final int pastoralVisitsTotal;
  final int newConvertsTotal;
  final List<AttendanceObservation> observations;

  LeaderAttendanceWork({
    required this.attendanceRecords,
    required this.memberAttendanceTotal,
    required this.visitorsTotal,
    required this.pastoralVisitsTotal,
    required this.newConvertsTotal,
    required this.observations,
  });

  factory LeaderAttendanceWork.fromJson(Map<String, dynamic> json) {
    return LeaderAttendanceWork(
      attendanceRecords: _toInt(json['attendanceRecords']),
      memberAttendanceTotal: _toInt(json['memberAttendanceTotal']),
      visitorsTotal: _toInt(json['visitorsTotal']),
      pastoralVisitsTotal: _toInt(json['pastoralVisitsTotal']),
      newConvertsTotal: _toInt(json['newConvertsTotal']),
      observations: (json['observations'] as List?)
              ?.map((e) => AttendanceObservation.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}

class LeaderSystemUsage {
  final int totalActions;
  final Map<String, int> actionsByModule;
  final String? lastActivityAt;

  LeaderSystemUsage({
    required this.totalActions,
    required this.actionsByModule,
    this.lastActivityAt,
  });

  factory LeaderSystemUsage.fromJson(Map<String, dynamic> json) {
    return LeaderSystemUsage(
      totalActions: _toInt(json['totalActions']),
      actionsByModule: _toIntMap(json['actionsByModule']),
      lastActivityAt: _toStr(json['lastActivityAt']),
    );
  }
}

class LeaderWork {
  final String displayName;
  final String? username;
  final List<String> roles;
  final bool enabled;
  final LeaderStructureScope structureScope;
  final LeaderAttendanceWork attendanceWork;
  final List<LeaderEventAssignment> eventAssignments;
  final LeaderSystemUsage systemUsage;

  LeaderWork({
    required this.displayName,
    this.username,
    required this.roles,
    required this.enabled,
    required this.structureScope,
    required this.attendanceWork,
    required this.eventAssignments,
    required this.systemUsage,
  });

  factory LeaderWork.fromJson(Map<String, dynamic> json) {
    return LeaderWork(
      displayName: json['displayName']?.toString() ?? '—',
      username: _toStr(json['username']),
      roles: _toStrList(json['roles']),
      enabled: json['enabled'] == true,
      structureScope:
          LeaderStructureScope.fromJson(json['structureScope'] ?? const {}),
      attendanceWork:
          LeaderAttendanceWork.fromJson(json['attendanceWork'] ?? const {}),
      eventAssignments: (json['eventAssignments'] as List?)
              ?.map((e) => LeaderEventAssignment.fromJson(e ?? const {}))
              .toList() ??
          const [],
      systemUsage: LeaderSystemUsage.fromJson(json['systemUsage'] ?? const {}),
    );
  }
}

class EventsSection {
  final Map<String, int> enabledDefinitionsByType;
  final int preacherAssignments;
  final int worshipAssignments;
  final List<LeaderEventAssignment> assignments;

  EventsSection({
    required this.enabledDefinitionsByType,
    required this.preacherAssignments,
    required this.worshipAssignments,
    required this.assignments,
  });

  factory EventsSection.fromJson(Map<String, dynamic> json) {
    return EventsSection(
      enabledDefinitionsByType: _toIntMap(json['enabledDefinitionsByType']),
      preacherAssignments: _toInt(json['preacherAssignments']),
      worshipAssignments: _toInt(json['worshipAssignments']),
      assignments: (json['assignments'] as List?)
              ?.map((e) => LeaderEventAssignment.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}

class NetworkMembershipDelta {
  final String networkName;
  final int newMembers;

  NetworkMembershipDelta({required this.networkName, required this.newMembers});

  factory NetworkMembershipDelta.fromJson(Map<String, dynamic> json) {
    return NetworkMembershipDelta(
      networkName: json['networkName']?.toString() ?? '—',
      newMembers: _toInt(json['newMembers']),
    );
  }
}

class MembershipSection {
  final int newMembers;
  final List<NetworkMembershipDelta> byNetwork;

  MembershipSection({required this.newMembers, required this.byNetwork});

  factory MembershipSection.fromJson(Map<String, dynamic> json) {
    return MembershipSection(
      newMembers: _toInt(json['newMembers']),
      byNetwork: (json['byNetwork'] as List?)
              ?.map((e) => NetworkMembershipDelta.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}

class SystemActivityUser {
  final String? username;
  final String displayName;
  final int totalActions;

  SystemActivityUser({
    this.username,
    required this.displayName,
    required this.totalActions,
  });

  factory SystemActivityUser.fromJson(Map<String, dynamic> json) {
    return SystemActivityUser(
      username: _toStr(json['username']),
      displayName: json['displayName']?.toString() ??
          json['username']?.toString() ??
          '—',
      totalActions: _toInt(json['totalActions']),
    );
  }
}

class SystemActivitySection {
  final Map<String, int> actionsByModule;
  final Map<String, int> actionsByType;
  final List<SystemActivityUser> topUsers;

  SystemActivitySection({
    required this.actionsByModule,
    required this.actionsByType,
    required this.topUsers,
  });

  factory SystemActivitySection.fromJson(Map<String, dynamic> json) {
    return SystemActivitySection(
      actionsByModule: _toIntMap(json['actionsByModule']),
      actionsByType: _toIntMap(json['actionsByType']),
      topUsers: (json['topUsers'] as List?)
              ?.map((e) => SystemActivityUser.fromJson(e ?? const {}))
              .toList() ??
          const [],
    );
  }
}
