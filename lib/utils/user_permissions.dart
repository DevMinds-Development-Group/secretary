import '../services/auth_service.dart';

class UserPermissions {
  final String? role;

  UserPermissions(AuthService authService) : role = authService.rawRole;

  // --- LÓGICA DE ACCESOS CENTRALIZADA ---

  bool get canSeeServices => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_LIDER',
    'ROLE_SECRETARIO',
  ].contains(role);

  bool get canSeeMembers => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_LIDER',
    'ROLE_SECRETARIO',
  ].contains(role);

  bool get canSeeAttendance => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_SECRETARIO',
    'ROLE_LIDER',
  ].contains(role);

  bool get canSeeNetworks => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_SECRETARIO',
    'ROLE_LIDER',
  ].contains(role);

  bool get canSeeMinistries => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_SECRETARIO',
    'ROLE_LIDER',
  ].contains(role);

  bool get canSeeReports => [
    'ROLE_ADMIN',
    'ROLE_APOSTOL',
    'ROLE_PASTOR',
    'ROLE_SECRETARIO',
  ].contains(role);

  bool get canSeeAdmin => ['ROLE_ADMIN'].contains(role);

  // Ejemplo de permiso de acción (No solo ver, sino HACER)
  bool get canCreateMember => ['ROLE_ADMIN', 'ROLE_SECRETARIO'].contains(role);
}
