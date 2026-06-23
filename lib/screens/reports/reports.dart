import 'package:Koinos/screens/reports/total_attendances.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return NavShell(
      current: NavSection.reports,
      title: 'Reportes',
      body: _buildLayout(context, isMobile),
    );
  }

  Widget _buildLayout(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: GridView.count(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCard(context, Icons.how_to_reg_rounded, 'Asistencias'),
          //_buildCard(context, Icons.groups_rounded, 'Membresía'),
          //_buildCard(context, Icons.waves, 'Bautizos'),
          //_buildCard(context, Icons.favorite_border, 'Matrimonios'),
          //_buildCard(context, Icons.history, ''),
        ],
      ),
    );
  }

  // --- Widget Común para las Tarjetas ---
  Widget _buildCard(BuildContext context, IconData icon, String title) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          // Lógica para la navegación
          switch (title) {
            case 'Asistencias':
              Navigator.push(
                context,
                createFadeRoute(const TotalAttendances()),
              );
              break;
            case 'Membresía':
              //Navigator.push(context, createFadeRoute(const Roles()));
              break;
            case 'Bautizos':
              //Navigator.push(context, createFadeRoute();
              break;
          }
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50.0, color: darkColor),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
