import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../routes/page_route_builder.dart';
import '../screens/admin/admin.dart';
import '../screens/attendance/attendance_history.dart';
import '../screens/home/dashboard.dart';
import '../screens/members.dart';
import '../screens/ministry/ministries.dart';
import '../screens/network/networks.dart';
import '../screens/reports/reports.dart';
import '../screens/service/services.dart';
import '../services/auth_service.dart';

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
    final isInsideDrawer = Scaffold.of(context).hasDrawer && isMobile;

    final authService = Provider.of<AuthService>(context);

    print(
      "MENU RE-DIBUJADO. Usuario: ${authService.userName}, Rol: ${authService.userRole}",
    );

    return Container(
      width: isMobile ? screenWidth * 0.5 : screenWidth * 0.2,
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.shade200,
                  child: Text(
                    (authService.userName?.isNotEmpty == true)
                        ? authService.userName![0].toUpperCase()
                        : "U",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  authService.userName ?? 'Cargando usuario...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  authService.userRole ?? 'Obteniendo rol...',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.teal),
            title: const Text('Inicio', style: TextStyle(color: Colors.black)),
            selected: _selectedIndex == 0,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Dashboard()));
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.deepOrange,
            ),
            title: const Text('Servicios'),
            selected: _selectedIndex == 1,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Services()));
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.people_alt_outlined, color: primaryColor),
            title: const Text(
              'Miembros',
              style: TextStyle(color: Colors.black),
            ),
            selected: _selectedIndex == 2,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Members()));
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_reg_outlined, color: Colors.cyan),
            title: const Text('Asistencia'),
            selected: _selectedIndex == 3,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(
                context,
                createFadeRoute(AttendanceHistory()),
              );
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.group, color: Colors.redAccent),
            title: const Text('Redes'),
            selected: _selectedIndex == 4,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Networks()));
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.indigo,
            ),
            title: const Text('Ministerios'),
            selected: _selectedIndex == 5,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Ministries()));
              setState(() {
                _selectedIndex = 5;
              });
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.bar_chart_outlined,
              color: Colors.deepPurpleAccent,
            ),
            title: const Text('Reportes'),
            selected: _selectedIndex == 6,
            onTap: () {
              if (isMobile) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, createFadeRoute(Reports()));
              setState(() {
                _selectedIndex = 6;
              });
            },
          ),
          if (authService.rawRole == 'ROLE_ADMIN')
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Administración'),
              selected: _selectedIndex == 7,
              onTap: () {
                if (isMobile) {
                  Navigator.pop(context);
                }
                Navigator.pushReplacement(context, createFadeRoute(Admin()));
                setState(() {
                  _selectedIndex = 7;
                });
              },
            ),
        ],
      ),
    );
  }
}
