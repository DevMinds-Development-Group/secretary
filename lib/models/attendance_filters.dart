/// Filtros del listado de asistencias. Se envían como query params al backend
/// (`GET /event-attendances`), interpretados por `EventAttendanceSpecification`:
/// `networkName` → LIKE (case-insensitive); `date` → fecha exacta (yyyy-MM-dd).
class AttendanceFilters {
  final String networkName;
  final DateTime? date;

  const AttendanceFilters({this.networkName = '', this.date});

  bool get isEmpty => networkName.trim().isEmpty && date == null;
  bool get isNotEmpty => !isEmpty;

  AttendanceFilters copyWith({String? networkName, Object? date = _unset}) {
    return AttendanceFilters(
      networkName: networkName ?? this.networkName,
      date: identical(date, _unset) ? this.date : date as DateTime?,
    );
  }

  Map<String, String> toQuery() {
    final q = <String, String>{};
    if (networkName.trim().isNotEmpty) q['networkName'] = networkName.trim();
    if (date != null) {
      final d = date!;
      q['date'] =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
    return q;
  }
}

const Object _unset = Object();
