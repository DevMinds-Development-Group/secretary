import 'package:flutter/material.dart';

import '../routes/routes.dart';
import '../utils/user_permissions.dart';

/// Identificadores de las secciones principales de la app.
enum NavSection {
  dashboard,
  members,
  attendance,
  services,
  networks,
  ministries,
  reports,
  admin,
}

/// Especificación de un destino de navegación (única fuente de verdad,
/// consumida por `NavShell` para la barra inferior y el riel lateral).
class NavItem {
  final NavSection id;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final bool Function(UserPermissions) canSee;

  const NavItem({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.canSee,
  });
}

/// Todos los destinos, en orden. La barra inferior usa los primeros
/// [kPrimaryCount]; el resto vive en "Más" (móvil) o directamente en el riel.
const List<NavItem> kNavItems = [
  NavItem(
    id: NavSection.dashboard,
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Inicio',
    route: AppRoutes.dashboard,
    canSee: _always,
  ),
  NavItem(
    id: NavSection.members,
    icon: Icons.people_alt_outlined,
    selectedIcon: Icons.people_alt_rounded,
    label: 'Miembros',
    route: AppRoutes.members,
    canSee: _canSeeMembers,
  ),
  NavItem(
    id: NavSection.attendance,
    icon: Icons.fact_check_outlined,
    selectedIcon: Icons.fact_check_rounded,
    label: 'Asistencia',
    route: AppRoutes.attendance_history,
    canSee: _canSeeAttendance,
  ),
  NavItem(
    id: NavSection.services,
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
    label: 'Servicios',
    route: AppRoutes.services,
    canSee: _canSeeServices,
  ),
  NavItem(
    id: NavSection.networks,
    icon: Icons.hub_outlined,
    selectedIcon: Icons.hub_rounded,
    label: 'Redes',
    route: AppRoutes.networks,
    canSee: _canSeeNetworks,
  ),
  NavItem(
    id: NavSection.ministries,
    icon: Icons.diversity_3_outlined,
    selectedIcon: Icons.diversity_3_rounded,
    label: 'Ministerios',
    route: AppRoutes.ministries,
    canSee: _canSeeMinistries,
  ),
  NavItem(
    id: NavSection.reports,
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    label: 'Reportes',
    route: AppRoutes.reports,
    canSee: _canSeeReports,
  ),
  NavItem(
    id: NavSection.admin,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Administración',
    route: AppRoutes.admin,
    canSee: _canSeeAdmin,
  ),
];

/// Cantidad de destinos primarios mostrados en la barra inferior (móvil).
/// El resto se agrupa en "Más".
const int kPrimaryCount = 4;

// Predicados de permisos (funciones top-level para poder ser `const`).
bool _always(UserPermissions p) => true;
bool _canSeeMembers(UserPermissions p) => p.canSeeMembers;
bool _canSeeAttendance(UserPermissions p) => p.canSeeAttendance;
bool _canSeeServices(UserPermissions p) => p.canSeeServices;
bool _canSeeNetworks(UserPermissions p) => p.canSeeNetworks;
bool _canSeeMinistries(UserPermissions p) => p.canSeeMinistries;
bool _canSeeReports(UserPermissions p) => p.canSeeReports;
bool _canSeeAdmin(UserPermissions p) => p.canSeeAdmin;
