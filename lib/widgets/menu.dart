import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../routes/page_route_builder.dart';
import '../routes/routes.dart';
import '../screens/admin/admin.dart';
import '../screens/attendance/attendance_history.dart';
import '../screens/home/dashboard.dart';
import '../screens/members.dart';
import '../screens/ministry/ministries.dart';
import '../screens/network/networks.dart';
import '../screens/reports/reports.dart';
import '../screens/service/services.dart';
import '../services/auth_service.dart';
import '../utils/user_permissions.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final permissions = UserPermissions(authService);

    String displayName = '';
    String displaySubtitle = '';

    if (user != null) {
      if (user.member != null) {
        displayName = "${user.member!.name} ${user.member!.lastName}";
        displaySubtitle = user.role;
      } else {
        displayName = user.username;
        displaySubtitle = user.role;
      }
    } else {
      displayName = authService.userName ?? 'Cargando...';
      displaySubtitle = authService.userRole ?? '';
    }

    return Container(
      width: isMobile ? screenWidth * 0.5 : screenWidth * 0.2,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.shade200,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  displaySubtitle,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 1. INICIO (Todos)
          ListTile(
            leading: const Icon(Icons.home, color: Colors.teal),
            title: const Text('Inicio'),
            selected: _selectedIndex == 0,
            onTap: () {
              if (isMobile) Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                createFadeRoute(const Dashboard()),
              );
              setState(() => _selectedIndex = 0);
            },
          ),

          if (permissions.canSeeServices)
            ListTile(
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.deepOrange,
              ),
              title: const Text('Servicios'),
              selected: _selectedIndex == 1,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Services()),
                );
                setState(() => _selectedIndex = 1);
              },
            ),

          if (permissions.canSeeMembers)
            ListTile(
              leading: const Icon(
                Icons.people_alt_outlined,
                color: primaryColor,
              ),
              title: const Text('Miembros'),
              selected: _selectedIndex == 2,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Members()),
                );
                setState(() => _selectedIndex = 2);
              },
            ),

          if (permissions.canSeeAttendance)
            ListTile(
              leading: const Icon(
                Icons.how_to_reg_outlined,
                color: Colors.cyan,
              ),
              title: const Text('Asistencia'),
              selected: _selectedIndex == 3,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const AttendanceHistory()),
                );
                setState(() => _selectedIndex = 3);
              },
            ),

          if (permissions.canSeeNetworks)
            ListTile(
              leading: const Icon(Icons.group, color: Colors.redAccent),
              title: const Text('Redes'),
              selected: _selectedIndex == 4,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Networks()),
                );
                setState(() => _selectedIndex = 4);
              },
            ),

          if (permissions.canSeeMinistries)
            ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: Colors.indigo,
              ),
              title: const Text('Ministerios'),
              selected: _selectedIndex == 5,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Ministries()),
                );
                setState(() => _selectedIndex = 5);
              },
            ),

          if (permissions.canSeeReports)
            ListTile(
              leading: const Icon(
                Icons.bar_chart_outlined,
                color: Colors.deepPurpleAccent,
              ),
              title: const Text('Reportes'),
              selected: _selectedIndex == 6,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Reports()),
                );
                setState(() => _selectedIndex = 6);
              },
            ),

          if (permissions.canSeeAdmin)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Administración'),
              selected: _selectedIndex == 7,
              onTap: () {
                if (isMobile) Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  createFadeRoute(const Admin()),
                );
                setState(() => _selectedIndex = 7);
              },
            ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: const Text('Mi Perfil'),
            onTap: () {
              if (isMobile) Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirmar', textAlign: TextAlign.center),
                    content: const Text(
                      '¿Estás seguro de que deseas cerrar sesión?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await authService.signOut();
                          if (mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          }
                        },
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
