import 'package:app/screens/home/dashboard.dart';
import 'package:flutter/material.dart';

import '../routes/page_route_builder.dart';
import '../screens/admin/profile.dart';
import '../screens/home/home.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;
  final bool isDrawerEnabled;
  final bool showBackButton;

  CustomAppBar({
    Key? key,
    required this.title,
    this.bottom,
    this.isDrawerEnabled = false,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    Widget leadingWidget;

    if (showBackButton) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.pushReplacement(
              context,
              createFadeRoute(const Dashboard()),
            );
          }
        },
      );
    } else {
      leadingWidget = IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.3)),
        onPressed: null,
      );
    }
    if (!showBackButton && isMobile && isDrawerEnabled) {
      leadingWidget = Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      );
    }

    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.blue.shade800,
      titleSpacing: 0,

      automaticallyImplyLeading: true,

      leading: leadingWidget,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18),
          ),
          SizedBox(width: isMobile ? 5 : 20),
          IconButton(
            tooltip: 'Página principal',
            onPressed: () {
              Navigator.push(context, createFadeRoute(Dashboard()));
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            tooltip: 'Manual de Usuarios',
            onPressed: () {},
            icon: Icon(Icons.help_outline),
          ),
          //SizedBox(width: isMobile ? 10 : 20),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  createFadeRoute(Profile()),
                ); // Navegar a editar perfil
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  createFadeRoute(Home()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'profile', child: Text('Mi Perfil')),
              PopupMenuItem(value: 'logout', child: Text('Cerrar Sesión')),
            ],
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: isMobile ? 22 : 25,
            ),
          ),
        ],
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    // Suma la altura del bottom si está presente
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
