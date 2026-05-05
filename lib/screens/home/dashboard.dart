import 'package:Koinos/widgets/retry_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/dashboard_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../services/update_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/menu.dart';
import '../../widgets/no_connection_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().fetchSummary();
      UpdateService().checkForUpdates(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final dashboardProvider = context.watch<DashboardProvider>();
    final summary = dashboardProvider.summary;

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
        body: Row(
          children: [
            if (!isMobile) const Menu(),
            Expanded(
              child: _buildBodyContent(dashboardProvider, summary, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    DashboardProvider provider,
    DashboardModel? summary,
    bool isMobile,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (provider.error == "SIN_CONEXION") {
      return NoConnectionWidget(onRefresh: () => provider.fetchSummary());
    }

    if (provider.error != null && summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            RetryButton(onRefresh: () => provider.fetchSummary()),
          ],
        ),
      );
    }

    // 4. Si el resumen es nulo por alguna otra razón
    if (summary == null) {
      return const Center(child: Text("No hay datos disponibles"));
    }

    // 5. Contenido principal (Si todo está bien)
    return _buildMainContent(summary, isMobile);
  }

  Widget _buildMainContent(DashboardModel summary, bool isMobile) {
    final List<Widget> metricItems = [
      _buildMetricItem(
        "Total Miembros",
        summary.totalMembers.toString(),
        Icons.groups,
        Colors.blue,
        () => Navigator.pushNamed(context, 'members'),
      ),
      _buildMetricItem(
        "Activos",
        summary.activeMembers.toString(),
        Icons.person,
        Colors.green,
        () => Navigator.pushNamed(context, 'members'),
      ),
      _buildMetricItem(
        "Inactivos",
        summary.inactiveMembers.toString(),
        Icons.person_off,
        Colors.orange,
        () => Navigator.pushNamed(context, 'members'),
      ),
    ];

    return CustomScrollView(
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
                        children: [
                          _buildSmallInfoCard(
                            'Redes',
                            summary.totalNetworks.toString(),
                            Icons.group,
                            negativeColor,
                            () => Navigator.pushNamed(context, 'networks'),
                          ),
                          const SizedBox(height: 20),
                          _buildSmallInfoCard(
                            'Ministerios',
                            summary.totalMinistries.toString(),
                            Icons.description_outlined,
                            Colors.indigo,
                            () => Navigator.pushNamed(context, 'ministries'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildSmallInfoCard(
                              'Redes',
                              summary.totalNetworks.toString(),
                              Icons.group,
                              negativeColor,
                              () => Navigator.pushNamed(context, 'networks'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildSmallInfoCard(
                              'Ministerios',
                              summary.totalMinistries.toString(),
                              Icons.description_outlined,
                              Colors.indigo,
                              () => Navigator.pushNamed(context, 'ministries'),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                if (!isMobile)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildSection(
                          "Actividad",
                          _buildPieChart(
                            summary.activeMembers,
                            summary.inactiveMembers,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 5,
                        child: _buildSection(
                          "Servicios de la Semana",
                          _buildServicesList(summary.weeklyEvents),
                        ),
                      ),
                    ],
                  )
                else ...[
                  _buildSection(
                    "Actividad",
                    _buildPieChart(
                      summary.activeMembers,
                      summary.inactiveMembers,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    "Servicios de la Semana",
                    _buildServicesList(summary.weeklyEvents),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  Widget _buildSmallInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: CustomCardContainer(
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
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            PieChartSectionData(
              value: inactive.toDouble(),
              color: Colors.orange,
              title: 'Inactivos',
              radius: 50,
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

  Widget _buildServicesList(List<WeeklyEvent> events) {
    if (events.isEmpty)
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("No hay eventos programados."),
      );
    return Column(
      children: events
          .map(
            (e) => ListTile(
              onTap: () => Navigator.pushNamed(context, 'services'),
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              title: Text(
                e.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${e.startTime} • ${e.type}",
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildVerticalDivider() =>
      Container(height: 60, width: 1, color: Colors.grey.withOpacity(0.3));
}
