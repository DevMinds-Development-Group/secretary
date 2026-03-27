import 'package:Koinos/screens/user_help.dart';
import 'package:flutter/material.dart';

import '../routes/page_route_builder.dart';
import '../screens/home/dashboard.dart';

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
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.blue.shade800,
      titleSpacing: 0,
      automaticallyImplyLeading: true,
      leading: leadingWidget,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          isMobile
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
          SizedBox(width: isMobile ? 5 : 20),
          IconButton(
            tooltip: 'Página principal',
            onPressed: () =>
                Navigator.push(context, createFadeRoute(const Dashboard())),
            icon: const Icon(Icons.home),
          ),
          IconButton(
            tooltip: 'Manual de Usuarios',
            onPressed: () =>
                Navigator.push(context, createFadeRoute(const UserHelp())),
            icon: const Icon(Icons.help_outline),
          ),
          const SizedBox(width: 10),
        ],
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
