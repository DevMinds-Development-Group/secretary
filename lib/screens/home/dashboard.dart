import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../models/service_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/menu.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // 1. LA VARIABLE DE CARGA DEBE ESTAR AQUÍ (FUERA DEL BUILD)
  bool _isLoading = true;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // 2. EL INITSTATE DEBE ESTAR AQUÍ
    _loadDashboardData();
  }

  // 3. EL MÉTODO DE CARGA DEBE ESTAR AQUÍ
  Future<void> _loadDashboardData() async {
    if (!mounted || !_isFirstLoad) return;

    setState(() {
      _isLoading = true;
      _isFirstLoad = false;
    });

    try {
      // Usamos microtask para separar la carga del ciclo de renderizado inicial
      Future.microtask(() async {
        await Future.wait([
          context.read<MemberProvider>().fetchMembers(),
          context.read<ServiceProvider>().fetchServices(),
          context.read<AttendanceProvider>().fetchAttendanceHistory(),
          context.read<NetworkProvider>().fetchNetworks(),
          context.read<MinistryProvider>().fetchMinistries(),
        ]);

        if (mounted) setState(() => _isLoading = false);
      });
    } catch (e) {
      debugPrint("Error cargando datos del dashboard: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Providers
    final memberProvider = context.watch<MemberProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final networkProvider = context.watch<NetworkProvider>();
    final ministryProvider = context.watch<MinistryProvider>();

    // --- LÓGICA DE MIEMBROS ---
    final allMembers = memberProvider.allMembers;
    final totalMembers = allMembers.length;

    // --- LÓGICA DE ACTIVOS (30 días) ---
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final Set<String> recentAttendees = {};

    // IMPORTANTE: Usamos recordsList que es lo que carga tu fetchAttendanceHistory
    for (var record in attendanceProvider.recordsList) {
      if (record.date.isAfter(thirtyDaysAgo)) {
        recentAttendees.addAll(record.presentMemberIds);
      }
    }

    final int activeMembers = allMembers
        .where((m) => recentAttendees.contains(m.id))
        .length;
    final int inactiveMembers = totalMembers - activeMembers;

    // --- LISTA DE WIDGETS DE MÉTRICAS ---
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

    // --- LÓGICA DE CRECIMIENTO ---
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

    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    final servicesThisWeek = serviceProvider.services.where((s) {
      if (s.recurring) {
        // Si es recurrente, sucede todas las semanas, por lo tanto está en "esta semana"
        return true;
      } else {
        // Si no es recurrente, verificamos si su fecha cae entre lunes y domingo
        return s.date.isAfter(
              startOfWeek.subtract(const Duration(seconds: 1)),
            ) &&
            s.date.isBefore(endOfWeek);
      }
    }).toList();

    servicesThisWeek.sort((a, b) {
      // Obtenemos el día (1-7)
      int dayA = a.recurring ? int.parse(a.weekDay.toString()) : a.date.weekday;
      int dayB = b.recurring ? int.parse(b.weekDay.toString()) : b.date.weekday;

      if (dayA != dayB) return dayA.compareTo(dayB);

      // Si es el mismo día, ordenamos por hora
      return a.time.hour.compareTo(b.time.hour);
    });

    final Widget mainContent = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCardContainer(
                  padding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 15,
                  ),
                  child: isMobile
                      ? Column(
                          children: metricItems
                              .expand(
                                (w) => [
                                  w,
                                  if (w != metricItems.last)
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
                                (w) => [
                                  Expanded(child: w),
                                  if (w != metricItems.last)
                                    _buildVerticalDivider(),
                                ],
                              )
                              .toList(),
                        ),
                ),

                const SizedBox(height: 20),
                isMobile
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNetwork(networkProvider, isMobile),

                          const SizedBox(height: 20),
                          _buildMinistry(ministryProvider, isMobile),
                          const SizedBox(height: 20),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildNetwork(networkProvider, isMobile),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildMinistry(ministryProvider, isMobile),
                          ),
                        ],
                      ),

                const SizedBox(height: 20),
                _buildSection(
                  "Comportamiento de la Membresía",
                  _buildGrowthChart(growthSpots, sortedMembers, isMobile),
                ),
                const SizedBox(height: 25),

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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : isMobile
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

  _buildMinistry(MinistryProvider ministryProvider, bool isMobile) {
    return _buildSmallInfoCard(
      'Ministerios',
      ministryProvider.ministries.length.toString(),
      Icons.description_outlined,
      Colors.indigo,
      isMobile,
    );
  }

  _buildNetwork(NetworkProvider networkProvider, bool isMobile) {
    return _buildSmallInfoCard(
      'Redes',
      networkProvider.networks.length.toString(),
      Icons.group,
      negativeColor,
      isMobile,
    );
  }

  Widget _buildMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 20,
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

  Widget _buildVerticalDivider() =>
      Container(height: 60, width: 1, color: Colors.grey.withOpacity(0.3));

  Widget _buildSmallInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isMobile,
  ) {
    return CustomCardContainer(
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 17 : 20,
              fontWeight: FontWeight.bold,
            ),
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35, // Espacio para que no se amontonen
                // ESTO ES LA CLAVE: Solo muestra una etiqueta cada X cantidad de puntos
                interval: (spots.length / (isMobile ? 3 : 6)).clamp(
                  1,
                  double.infinity,
                ),
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();

                  // Verificamos que el índice sea válido
                  if (index < 0 || index >= sortedMembers.length) {
                    return const SizedBox();
                  }

                  final date =
                      sortedMembers[index].createdDate ?? DateTime.now();

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 10,
                    child: Text(
                      DateFormat(
                        'dd/MM/yy',
                        'es',
                      ).format(date), // Formato más corto
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
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
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length < 10,
              ), // Solo muestra puntos si hay pocos datos
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(int active, int inactive) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 35,
          sections: [
            PieChartSectionData(
              value: active.toDouble(),
              color: Colors.green,
              title: 'Activos',
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            PieChartSectionData(
              value: inactive.toDouble(),
              color: Colors.orange,
              title: 'Inactivos',
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildServicesList(List<ServiceModel> services) {
    if (services.isEmpty)
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No hay servicios esta semana."),
      );
    return Column(
      children: services.map<Widget>((s) {
        final bool isPast =
            !s.recurring &&
            s.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.event, color: Colors.white, size: 20),
          ),
          title: Text(
            s.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          subtitle: Text(
            "${DateFormat("EEEE dd", 'es').format(s.date)} • ${_formatTime12h(s.time)}",
            style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
          ),
        );
      }).toList(),
    );
  }
}
