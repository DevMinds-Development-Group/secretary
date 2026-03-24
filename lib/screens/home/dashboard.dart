import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/custom_card_container.dart';
import 'package:app/widgets/menu.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/service_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Providers
    final memberProvider = context.watch<MemberProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final ministryProvider = context.watch<MinistryProvider>();

    // --- LÓGICA DE MIEMBROS Y CRECIMIENTO ---
    final allMembers = memberProvider.allMembers;
    final totalMembers = allMembers.length;

    // --- LÓGICA DE ACTIVOS (30 días) ---
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final Set<String> recentAttendees = {};
    for (var record in attendanceProvider.records.values) {
      if (record.date.isAfter(thirtyDaysAgo)) {
        recentAttendees.addAll(record.presentMemberIds);
      }
    }

    final int activeMembers = allMembers
        .where((m) => recentAttendees.contains(m.id))
        .length;
    final int inactiveMembers = totalMembers - activeMembers;

    // 1. Creamos la lista de los 3 items base
    final List<Widget> metricItems = [
      _buildMetricItem(
        "Total Miembros",
        totalMembers.toString(),
        Icons.groups,
        Colors.blue,
      ),
      _buildMetricItem(
        "Activos (30 días)",
        activeMembers.toString(),
        Icons.person,
        Colors.green,
      ),
      _buildMetricItem(
        "Inactivos",
        inactiveMembers.toString(),
        Icons.person_off,
        Colors.orange,
      ),
    ];

    // Ordenar miembros por fecha de registro (Manejo de nulos corregido)
    final sortedMembers = List<Member>.from(allMembers)
      ..sort(
        (a, b) => (a.createdDate ?? DateTime.now()).compareTo(
          b.createdDate ?? DateTime.now(),
        ),
      );

    final List<FlSpot> growthSpots = sortedMembers.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.key + 1).toDouble());
    }).toList();

    // --- LÓGICA DE SERVICIOS SEMANALES ---
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeekDate = startOfWeekDate.add(
      const Duration(days: 7, hours: 23),
    );

    final servicesThisWeek = serviceProvider.services.where((s) {
      return s.date.isAfter(startOfWeekDate) && s.date.isBefore(endOfWeekDate);
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    // --- CONTENIDO PRINCIPAL ---
    final Widget mainContent = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCardContainer(
                  child: isMobile
                      ? Column(
                          children: metricItems
                              .expand(
                                (widget) => [
                                  widget,
                                  if (widget != metricItems.last)
                                    const Divider(
                                      height: 40,
                                      indent: 30,
                                      endIndent: 30,
                                    ),
                                ],
                              )
                              .toList(),
                        )
                      : Row(
                          children: metricItems
                              .expand(
                                (widget) => [
                                  Expanded(child: widget),
                                  if (widget != metricItems.last)
                                    _buildVerticalDivider(),
                                ],
                              )
                              .toList(),
                        ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 15,
                  ),
                ),

                const SizedBox(height: 20),

                // 2. OTRAS MÉTRICAS (Redes y Ministerios)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSmallInfoCard(
                        'Redes',
                        networkProvider.networks.length.toString(),
                        Icons.group,
                        Colors.redAccent,
                        isMobile,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _buildSmallInfoCard(
                        'Ministerios',
                        ministryProvider.ministries.length.toString(),
                        Icons.description_outlined,
                        Colors.indigo,
                        isMobile,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 3. GRÁFICO DE CRECIMIENTO HISTÓRICO
                _buildSection(
                  "Comportamiento de la Membresía",
                  _buildGrowthChart(growthSpots, sortedMembers, isMobile),
                ),

                const SizedBox(height: 25),

                // 4. ACTIVIDAD Y SERVICIOS (Fila o Columna según dispositivo)
                if (!isMobile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildSection(
                          "Actividad (30 días)",
                          _buildPieChart(activeMembers, inactiveMembers),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: _buildSection(
                          "Servicios de la Semana",
                          _buildServicesList(servicesThisWeek),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSection(
                    "Actividad (30 días)",
                    _buildPieChart(activeMembers, inactiveMembers),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    "Servicios de la Semana",
                    _buildServicesList(servicesThisWeek),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(
          title: 'Inicio',
          isDrawerEnabled: isMobile,
          showBackButton: false,
        ),
        drawer: isMobile ? const Drawer(child: Menu()) : null,
        body: isMobile
            ? mainContent
            : Row(
                children: [
                  const Menu(),
                  Expanded(child: mainContent),
                ],
              ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 60, width: 1, color: Colors.grey.withOpacity(0.7));
  }

  Widget _buildSmallInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return CustomCardContainer(
      width: isMobile
          ? (MediaQuery.of(context).size.width / 2) - 30
          : MediaQuery.of(context).size.width * 0.35,
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 25),
          content,
        ],
      ),
    );
  }

  Widget _buildGrowthChart(
    List<FlSpot> spots,
    List<Member> sortedMembers,
    bool isMobile,
  ) {
    if (spots.length < 2) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text("No hay suficientes datos de registro.")),
      );
    }

    return AspectRatio(
      aspectRatio: isMobile ? 1.5 : 4.0,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index == 0 ||
                      index == spots.length - 1 ||
                      index == (spots.length ~/ 2)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MMM yy', 'es').format(
                          sortedMembers[index].createdDate ?? DateTime.now(),
                        ),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withOpacity(0.1),
              ),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(int active, int inactive) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 35,
          sections: [
            PieChartSectionData(
              value: active.toDouble(),
              color: Colors.green,
              title: 'Activos',
              radius: 70,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            PieChartSectionData(
              value: inactive.toDouble(),
              color: Colors.orange,
              title: 'Inactivos',
              radius: 70,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(List services) {
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No hay servicios programados para esta semana."),
      );
    }
    return Column(
      children: services.map<Widget>((s) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.event, color: Colors.white, size: 20),
          ),
          title: Text(
            s.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            DateFormat("EEEE dd 'de' MMMM", 'es').format(s.date),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
