import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../routes/page_route_builder.dart';
import '../../routes/routes.dart';
import '../../widgets/custom_button.dart';
import '../public_announcements.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  isMobile ? 'assets/01.jpg' : 'assets/03a.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  color: cardColor,
                  elevation: 10,
                  //shadowColor: Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(30),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/logo0.png', width: 160),
                        Text(
                          'Ministerio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: isMobile ? 24 : 30,
                            color: secondaryText,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Viento Recio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: isMobile ? 32 : 50,
                            fontWeight: FontWeight.bold,
                            color: negativeColor,
                          ),
                        ),
                        const SizedBox(height: 60),

                        // BOTONES
                        _buildButtons(context, isMobile),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildButtons(BuildContext context, bool isMobile) {
  // En mobile usamos Column para que los botones se vean mejor dentro de la Card
  return Column(
    children: [
      CustomButton(
        backgroundColor: darkColor,
        text: 'Ver anuncios',
        color: cardColor,
        icon: Icons.event_note,
        iconColor: cardColor,
        onPressed: () => Navigator.push(
          context,
          createFadeRoute(const PublicAnnouncements()),
        ),
        borderColor: alternateColor,
      ),
      const SizedBox(height: 20),
      CustomButton(
        backgroundColor: primaryColor,
        text: 'Iniciar sesión',
        color: infoColor,
        icon: Icons.login_rounded,
        iconColor: infoColor,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
      ),
    ],
  );
}
