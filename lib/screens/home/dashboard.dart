import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../providers/member_provider.dart';
import '../../providers/service_provider.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: cardColor,
      child: Padding(
        padding: isMobile
            ? EdgeInsets.fromLTRB(40, 25, 40, 10)
            : EdgeInsets.fromLTRB(60, 50, 60, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class DashboardListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DashboardListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final memberProvider = context.watch<MemberProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final totalMembers = memberProvider.members.length;

    final upcomingServices = serviceProvider.services
        .where(
          (s) =>
              s.date.isAfter(DateTime.now().subtract(const Duration(days: 1))),
        )
        .toList();
    upcomingServices.sort((a, b) => a.date.compareTo(b.date));

    final now = DateTime.now();
    // 2. Calculamos el inicio de la semana (Lunes).
    //    now.weekday devuelve 1 para Lunes, 2 para Martes, ..., 7 para Domingo.
    //    Restamos (now.weekday - 1) días a la fecha actual para llegar al Lunes.
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Normalizamos a las 00:00:00 para evitar problemas con la hora.
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    // 3. Calculamos el fin de la semana (Domingo).
    //    Sumamos (7 - now.weekday) días a la fecha actual para llegar al Domingo.
    final endOfWeek = now.add(
      Duration(days: DateTime.daysPerWeek - now.weekday),
    );
    // Normalizamos a las 23:59:59 para incluir todo el día Domingo.
    final endOfWeekDate = DateTime(
      endOfWeek.year,
      endOfWeek.month,
      endOfWeek.day,
      23,
      59,
      59,
    );

    // 4. Filtramos los servicios del provider que están dentro de este rango.
    final servicesThisWeek = serviceProvider.services.where((service) {
      return service.date.isAfter(startOfWeekDate) &&
          service.date.isBefore(endOfWeekDate);
    }).toList();

    // 5. Ordenamos los servicios de la semana cronológicamente.
    servicesThisWeek.sort((a, b) => a.date.compareTo(b.date));

    // Contenido principal del dashboard (tarjetas y listas)
    final Widget mainContent = CustomScrollView(
      slivers: [
        //constraints: BoxConstraints(maxWidth: 1200),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 25.0,
                  runSpacing: 16.0,
                  children: [
                    MetricCard(
                      title: 'Total de miembros',
                      value: totalMembers.toString(),
                    ),

                    // MetricCard(
                    //   title: 'Miembros nuevos',
                    //   value: newMembers.toString(),
                    // ),
                    //
                    // MetricCard(
                    //   title: 'Miembros activos',
                    //   value: activeMembers.toString(),
                    // ),
                  ],
                ),

                SizedBox(height: 40),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Servicios de esta semana:',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    Divider(height: 20),
                    const SizedBox(height: 16),
                    if (servicesThisWeek.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'No hay servicios programados para esta semana.',
                        ),
                      )
                    else
                      // Usamos un Column para generar los widgets de la lista
                      Column(
                        children: servicesThisWeek.map((service) {
                          final formattedDate = DateFormat(
                            "EEEE, dd 'de' MMMM",
                            'es',
                          ).format(service.date);
                          final formattedTime = service.time.format(context);
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16.0,
                            ), // Espacio entre elementos
                            child: DashboardListItem(
                              icon: Icons.calendar_month_outlined,
                              title: service.title,
                              subtitle:
                                  '$formattedDate a las $formattedTime', // DATO REAL
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // Menú lateral para vista web

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        //extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          title: 'Inicio',
          isDrawerEnabled: isMobile,
          showBackButton: false,
        ),
        body: isMobile
            ? mainContent
            : Row(
                children: [
                  Menu(),
                  Expanded(child: mainContent),
                ],
              ),
        drawer: isMobile
            ? Drawer(child: Menu())
            : null, // El Drawer solo en móvil
      ),
    );
  }
}
