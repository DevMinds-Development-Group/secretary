/// Filtros de la lista de miembros. Se envían como query params al backend
/// (`GET /members`), que los interpreta vía `MemberSpecification`:
/// `name`/`lastName`/`phone` → LIKE (case-insensitive); `enabled` → booleano.
class MemberFilters {
  final String name;
  final String lastName;
  final String phone;

  /// `null` = todos, `true` = activos, `false` = inactivos.
  final bool? enabled;

  const MemberFilters({
    this.name = '',
    this.lastName = '',
    this.phone = '',
    this.enabled,
  });

  bool get isEmpty =>
      name.trim().isEmpty &&
      lastName.trim().isEmpty &&
      phone.trim().isEmpty &&
      enabled == null;

  bool get isNotEmpty => !isEmpty;

  MemberFilters copyWith({
    String? name,
    String? lastName,
    String? phone,
    Object? enabled = _unset,
  }) {
    return MemberFilters(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      enabled: identical(enabled, _unset) ? this.enabled : enabled as bool?,
    );
  }

  /// Solo incluye las claves con valor (para no enviar filtros vacíos).
  Map<String, String> toQuery() {
    final q = <String, String>{};
    if (name.trim().isNotEmpty) q['name'] = name.trim();
    if (lastName.trim().isNotEmpty) q['lastName'] = lastName.trim();
    if (phone.trim().isNotEmpty) q['phone'] = phone.trim();
    if (enabled != null) q['enabled'] = enabled! ? 'true' : 'false';
    return q;
  }
}

const Object _unset = Object();
