import 'package:app/routes/page_route_builder.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../routes/routes.dart';
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
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(isMobile ? 'assets/06.png' : 'assets/03.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: isMobile ? 200 : 50),
                    isMobile
                        ? Column(
                            children: [
                              Text(
                                'Secretaría',
                                textAlign: TextAlign.center,
                                style: _mobileTextStyle(),
                              ),
                              Text(
                                'Viento Recio',
                                textAlign: TextAlign.center,
                                style: _mobileTextStyle(),
                              ),
                            ],
                          )
                        : Text(
                            'Bienvenido al Ministerio Viento Recio',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(4, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: isMobile ? 120 : 40),
                    _buildButtons(context, isMobile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _mobileTextStyle() {
    return TextStyle(
      color: Colors.black,
      fontSize: 34,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: Colors.white, offset: Offset(3, 3), blurRadius: 7),
      ],
    );
  }
}

Widget _buildButtons(BuildContext context, bool isMobile) {
  return Wrap(
    spacing: 20,
    runSpacing: 20,
    alignment: WrapAlignment.center,
    children: [
      CustomButton(
        text: 'Ver anuncios',
        icon: Icons.event_note,
        onPressed: () => Navigator.push(
          context,
          createFadeRoute(const PublicAnnouncements()),
        ),
      ),
      CustomButton(
        text: 'Iniciar sesión',
        icon: Icons.login_rounded,
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
      ),
    ],
  );
}
