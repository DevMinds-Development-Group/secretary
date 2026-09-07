import '../services/auth_service.dart';
import '../services/tenant_scope.dart';

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

  /// El Ministerio entra a Administración por ser el inquilino superior y no por su rol: ahí es
  /// donde da de alta las iglesias, y su usuario lleva ROLE_APOSTOL, no ROLE_ADMIN. Dentro, cada
  /// tarjeta decide lo suyo — la de Iglesias sólo la ve él.
  bool get canSeeAdmin =>
      ['ROLE_ADMIN'].contains(role) || TenantScope.isMinistry;

  // Supervisión: administradores, apóstoles y pastores.
  bool get canSeeSupervision =>
      ['ROLE_ADMIN', 'ROLE_APOSTOL', 'ROLE_PASTOR'].contains(role);

  // Ejemplo de permiso de acción (No solo ver, sino HACER)
  bool get canCreateMember => ['ROLE_ADMIN', 'ROLE_SECRETARIO'].contains(role);
}
