// import 'package:app/widgets/custom_appbar.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../colors.dart';
// import '../models/attendance_record_model.dart';
// import '../models/member_model.dart';
// import '../providers/attendance_provider.dart';
// import '../providers/member_provider.dart';
// import '../widgets/menu.dart'; // Tu widget de menú lateral
//
// // 1. Widget principal de la pantalla de Reportes
// class Reports extends StatefulWidget {
//   const Reports({super.key});
//
//   @override
//   State<Reports> createState() => _ReportsState();
// }
//
// class _ReportsState extends State<Reports> with TickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 700;
//     final attendanceProvider = Provider.of<AttendanceProvider>(context);
//     final memberProvider = Provider.of<MemberProvider>(context);
//
//     // Obtenemos todos los registros de asistencia
//     final allRecordsOriginal = attendanceProvider.records.values.toList();
//     // Obtenemos todos los miembros para poder saber sus grupos
//     final allMembers = memberProvider.allMembers;
//     allRecordsOriginal.sort((a, b) => a.date.compareTo(b.date));
//
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: CustomAppBar(
//         title: 'Reportes',
//         isDrawerEnabled: isMobile,
//         bottom: TabBar(
//           unselectedLabelColor: Colors.white.withOpacity(0.7),
//           labelColor: Colors.white,
//           labelStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           indicatorSize: TabBarIndicatorSize.tab,
//
//           indicator: BoxDecoration(
//             // El color del recuadro. Un gris oscuro semitransparente funciona bien.
//             color: Colors.black.withOpacity(0.1),
//             // Opcional: si quieres que el recuadro tenga bordes redondeados.
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'Asistencia'),
//             Tab(text: 'Miembros'),
//           ],
//         ),
//       ),
//       drawer: isMobile ? Drawer(child: Menu()) : null,
//       body: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!isMobile) const SizedBox(child: Menu()),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 // Pestaña 1
//                 ReportContent(
//                   allRecords: allRecordsOriginal,
//                   allMembers: allMembers,
//                 ),
//                 // Pestaña 2
//                 MembershipAnalyticsTab(
//                   allMembers: allMembers,
//                   allRecords: allRecordsOriginal,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // 2. Widget para el contenido de los reportes
// class ReportContent extends StatefulWidget {
//   final List<AttendanceRecord> allRecords;
//   final List<Member> allMembers;
//
//   const ReportContent({
//     super.key,
//     required this.allRecords,
//     required this.allMembers,
//   });
//
//   @override
//   State<ReportContent> createState() => _ReportContentState();
// }
//
// class _ReportContentState extends State<ReportContent> {
//   String? _selectedGroup; // null significa "Todos"
//   DateTimeRange? _selectedDateRange;
//
//   @override
//   void initState() {
//     super.initState();
//     // Inicialmente, no hay filtros aplicados.
//     _selectedGroup = null;
//     _selectedDateRange = null;
//   }
//
//   // Muestra un menú para seleccionar un grupo
//   void _showGroupFilter(BuildContext context, bool isMobile) {
//     // Obtenemos la lista única de grupos de los miembros
//     final Set<String?> networkName = widget.allMembers
//         .map((m) => m.networkName)
//         .toSet();
//     final List<String?> groupList = networkName.toList()..sort();
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           title: const Text(
//             'Seleccionar Grupo',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           children: [
//             SizedBox(height: 10),
//             // Opción para quitar el filtro
//             SimpleDialogOption(
//               onPressed: () {
//                 setState(() {
//                   _selectedGroup = null;
//                 });
//                 Navigator.pop(context);
//               },
//               child: Text('Todos los Grupos', style: TextStyle(fontSize: 18)),
//             ),
//             // Opciones para cada grupo
//             ...groupList.map(
//               (group) => SimpleDialogOption(
//                 onPressed: () {
//                   setState(() {
//                     _selectedGroup = group;
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: Text(
//                   networkName as String,
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Muestra el selector de rango de fechas
//   Future<void> _showDateRangeFilter(BuildContext context, bool isMobile) async {
//     final now = DateTime.now();
//     final initialRange =
//         _selectedDateRange ??
//         DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 5),
//
//       lastDate: DateTime.now(),
//       initialDateRange: initialRange,
//     );
//     if (picked != null && picked != _selectedDateRange) {
//       setState(() {
//         _selectedDateRange = picked;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 700;
//     List<AttendanceRecord> filteredRecords = List.from(widget.allRecords);
//
//     // 1. Filtrar por Rango de Fechas
//     if (_selectedDateRange != null) {
//       filteredRecords = filteredRecords.where((record) {
//         final recordDate = record.date;
//         // Normalizamos las fechas para ignorar la hora del día
//         final startDate = DateTime(
//           _selectedDateRange!.start.year,
//           _selectedDateRange!.start.month,
//           _selectedDateRange!.start.day,
//         );
//         final endDate = DateTime(
//           _selectedDateRange!.end.year,
//           _selectedDateRange!.end.month,
//           _selectedDateRange!.end.day,
//         );
//         return (recordDate.isAtSameMomentAs(startDate) ||
//                 recordDate.isAfter(startDate)) &&
//             (recordDate.isAtSameMomentAs(endDate) ||
//                 recordDate.isBefore(endDate));
//       }).toList();
//     }
//
//     // Si se selecciona un grupo, primero encontramos qué miembros pertenecen a él.
//     // Luego, filtramos los registros de asistencia para que solo incluyan a esos miembros.
//     Set<String> membersInGroup = {};
//     if (_selectedGroup != null) {
//       membersInGroup = widget.allMembers
//           .where((member) => member.networkName == _selectedGroup)
//           .map((member) => member.id)
//           .toSet();
//     }
//
//     // --- CÁLCULO DE MÉTRICAS SOBRE DATOS FILTRADOS ---
//     final int totalAttendance = filteredRecords.fold(0, (sum, record) {
//       if (_selectedGroup == null) {
//         return sum + record.presentMemberIds.length;
//       }
//       // Si hay un grupo, solo contamos los miembros de ese grupo
//       return sum +
//           record.presentMemberIds
//               .where((id) => membersInGroup.contains(id))
//               .length;
//     });
//     final int totalGuests = (_selectedGroup == null)
//         ? filteredRecords.fold(0, (sum, record) => sum + record.guestCount)
//         : 0;
//     final int grandTotal = totalAttendance + totalGuests;
//
//     // Preparación de datos para el gráfico (ahora con datos filtrados)
//     filteredRecords.sort((a, b) => a.date.compareTo(b.date));
//     final List<FlSpot> spots = filteredRecords.asMap().entries.map((entry) {
//       final index = entry.key;
//       final record = entry.value;
//       final totalAttendees = (_selectedGroup == null)
//           ? record.presentMemberIds.length + record.guestCount
//           : record.presentMemberIds
//                 .where((id) => membersInGroup.contains(id))
//                 .length;
//       return FlSpot(index.toDouble(), totalAttendees.toDouble());
//     }).toList();
//
//     // --- 3. CALCULAMOS LA ASISTENCIA POR GRUPO ---
//     final Map<String, int> attendanceByGroup = {};
//     // Creamos un mapa de ID de miembro a su grupo para una búsqueda rápida
//     final memberGroupMap = {
//       for (var member in widget.allMembers) member.id: member.networkName,
//     };
//
//     for (var record in widget.allRecords) {
//       for (var memberId in record.presentMemberIds) {
//         final group = memberGroupMap[memberId];
//         if (group != null) {
//           // Si el grupo ya está en el mapa, suma 1. Si no, inicialízalo en 1.
//           attendanceByGroup.update(
//             group,
//             (value) => value + 1,
//             ifAbsent: () => 1,
//           );
//         }
//       }
//     }
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(32.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           // Título de la sección
//           const Text(
//             'Asistencia Total',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _selectedGroup ??
//                 'Todos los Grupos', // <-- CAMBIO: Muestra el filtro activo
//             style: const TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 16),
//           // Métrica principal
//           Text(
//             grandTotal.toString(),
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${totalAttendance.toString()} Miembros + ${totalGuests.toString()} Visitas',
//             style: TextStyle(fontSize: 16, color: Colors.green),
//           ),
//           if (_selectedGroup == null)
//             //Solo muestra visitas si no hay filtro de grupo
//             const SizedBox(height: 32),
//           // Gráfico de tendencia (puedes usar un paquete como fl_chart)
//           const Text(
//             'Tendencia de Asistencia',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 24),
//           if (spots.isEmpty)
//             Container(
//               color: Colors.white,
//               height: 150,
//               child: Center(
//                 child: Text(
//                   'No hay suficientes datos para mostrar una tendencia.',
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             )
//           else
//             buildAspectRatioLines(spots, filteredRecords, isMobile),
//
//           const SizedBox(height: 32),
//           // Sección de Asistencia por Grupo
//           if (_selectedGroup == null) ...[
//             // <-- CAMBIO: Lógica para ocultar la sección
//             const Text(
//               'Asistencia por Grupo',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             if (attendanceByGroup.isEmpty)
//               const Text('No hay datos de asistencia por grupo.')
//             else
//               ...attendanceByGroup.entries.map((entry) {
//                 return _buildGroupBar(entry.key, entry.value, totalAttendance);
//               }).toList(),
//             const SizedBox(height: 32),
//           ],
//           isMobile
//               ? Column(
//                   //mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.8,
//                           child: _buildRowWithIcon(context, isMobile),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.35,
//                           child: _buildFilterButton(
//                             _selectedGroup ?? 'Grupo',
//                             () => _showGroupFilter(context, isMobile),
//                             isMobile,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     _buildRowWithIcon(context, isMobile),
//                     const SizedBox(width: 12),
//                     _buildFilterButton(
//                       _selectedGroup ?? 'Grupo',
//                       () => _showGroupFilter(context, isMobile),
//                       isMobile,
//                     ),
//                   ],
//                 ),
//         ],
//       ),
//     );
//   }
//
//   Row _buildRowWithIcon(BuildContext context, bool isMobile) {
//     return Row(
//       children: [
//         _buildFilterButton(
//           _selectedDateRange == null
//               ? 'Rango de Fecha'
//               : '${DateFormat('d/M/y', 'es_ES').format(_selectedDateRange!.start)} - ${DateFormat('d/M/y', 'es_ES').format(_selectedDateRange!.end)}',
//           () => _showDateRangeFilter(context, isMobile),
//           isMobile,
//         ),
//         if (_selectedDateRange != null)
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: InkWell(
//               onTap: () {
//                 // Al tocarlo, limpia el estado y reconstruye la UI
//                 setState(() {
//                   _selectedDateRange = null;
//                 });
//               },
//               borderRadius: BorderRadius.circular(20),
//               child: const Icon(Icons.clear, color: Colors.red, size: 20),
//             ),
//           ),
//       ],
//     );
//   }
//
//   AspectRatio buildAspectRatioLines(
//     List<FlSpot> spots,
//     List<AttendanceRecord> records,
//     isMobile,
//   ) {
//     return AspectRatio(
//       aspectRatio: isMobile
//           ? 2.0
//           : 5.0, // Proporción del gráfico (ancho vs alto)
//       child: LineChart(
//         LineChartData(
//           // --- ESTILOS Y CONFIGURACIÓN DEL GRÁFICO ---
//           gridData: FlGridData(show: false), // Oculta la cuadrícula de fondo
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//             ),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 30,
//                 interval: 1,
//                 // Formateador para mostrar la fecha en el eje X
//                 getTitlesWidget: (value, meta) {
//                   // Solo muestra algunas etiquetas para no saturar
//                   if (value.toInt() % (spots.length ~/ 4 + 1) == 0) {
//                     final record = widget.allRecords[value.toInt()];
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Text(
//                         DateFormat('d MMM', 'es_ES').format(record.date),
//                       ),
//                     );
//                   }
//                   return const Text('');
//                 },
//               ),
//             ),
//           ),
//           borderData: FlBorderData(
//             show: true,
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           lineBarsData: [
//             LineChartBarData(
//               spots: spots,
//               isCurved: true, // Líneas curvas para un look más suave
//               color: accentColor, // Usa tu color de acento
//               barWidth: 4,
//               isStrokeCapRound: true,
//               dotData: FlDotData(show: false), // Oculta los puntos en la línea
//               belowBarData: BarAreaData(
//                 // Sombreado debajo de la línea
//                 show: true,
//                 color: accentColor.withOpacity(0.2),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGroupBar(String title, int attendance, int total) {
//     // Evitamos división por cero si el total es 0
//     final double percentage = (total > 0) ? attendance / total : 0.0;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: LinearProgressIndicator(
//                 value: percentage,
//                 minHeight: 20,
//                 backgroundColor: Colors.grey[300],
//                 color: accentColor,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Text(
//             '$attendance',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterButton(String text, VoidCallback onPressed, isMobile) {
//     return InkWell(
//       onTap: onPressed,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Row(
//           children: [
//             Text(text),
//             const SizedBox(width: 8),
//             const Icon(Icons.keyboard_arrow_down, size: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MembershipAnalyticsTab extends StatelessWidget {
//   final List<Member> allMembers;
//   final List<AttendanceRecord> allRecords;
//
//   const MembershipAnalyticsTab({
//     super.key,
//     required this.allMembers,
//     required this.allRecords,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool isMobile = MediaQuery.of(context).size.width < 700;
//     // 1. Calcular Miembros Activos vs. Inactivos
//     final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
//     // Creamos un conjunto con los IDs de todos los que han asistido en los últimos 30 días.
//     final Set<String> recentAttendees = {};
//     for (var record in allRecords) {
//       if (record.date.isAfter(thirtyDaysAgo)) {
//         recentAttendees.addAll(record.presentMemberIds);
//       }
//     }
//     final int activeMembers = allMembers
//         .where((m) => recentAttendees.contains(m.id))
//         .length;
//     final int inactiveMembers = allMembers.length - activeMembers;
//
//     // 2. Calcular Distribución por Grupo
//     final Map<String, int> membersByGroup = {};
//     for (var member in allMembers) {
//       membersByGroup.update(
//         member.networkName ?? 'Sin Grupo',
//         (value) => value + 1,
//         ifAbsent: () => 1,
//       );
//     }
//
//     // 3. Calcular Crecimiento de la Membresía (para el gráfico de líneas)
//     // Ordenamos los miembros por su fecha de registro
//     // final sortedMembers = List<Member>.from(allMembers)
//     //   ..sort((a, b) => a.registrationDate.compareTo(b.registrationDate));
//     // final List<FlSpot> growthSpots = [];
//     // for (int i = 0; i < sortedMembers.length; i++) {
//     //   // El eje X es el índice (tiempo) y el eje Y es el número total de miembros hasta ese punto.
//     //   growthSpots.add(FlSpot(i.toDouble(), (i + 1).toDouble()));
//     // }
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // --- SECCIÓN DE ACTIVIDAD DE MIEMBROS ---
//           Text(
//             'Actividad de la Membresía',
//             style: TextStyle(
//               fontSize: isMobile ? 22 : 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Text(
//             'Últimos 30 días',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           SizedBox(height: isMobile ? 24 : 16),
//           _buildActivityChart(
//             context,
//             activeMembers,
//             inactiveMembers,
//             isMobile,
//           ),
//
//           const SizedBox(height: 30),
//
//           // --- SECCIÓN DE CRECIMIENTO HISTÓRICO ---
//           Text(
//             'Crecimiento de la Membresía',
//             style: TextStyle(
//               fontSize: isMobile ? 22 : 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           // if (growthSpots.length < 2)
//           //   const Center(
//           //     child: Text(
//           //       'No hay suficientes datos para mostrar el crecimiento.',
//           //     ),
//           //   )
//           // else
//           //   AspectRatio(
//           //     aspectRatio: isMobile ? 2 : 5,
//           //     child: LineChart(
//           //       _buildGrowthChartData(growthSpots, sortedMembers),
//           //     ),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   // Widget para el gráfico de dona (Activos vs. Inactivos)
//   Widget _buildActivityChart(
//     BuildContext context,
//     int active,
//     int inactive,
//     isMobile,
//   ) {
//     return SizedBox(
//       height: 200,
//       child: Row(
//         mainAxisAlignment: isMobile
//             ? MainAxisAlignment.center
//             : MainAxisAlignment.start,
//         children: [
//           Expanded(
//             //flex: 2,
//             child: PieChart(
//               PieChartData(
//                 sectionsSpace: 4,
//                 centerSpaceRadius: 40,
//                 sections: [
//                   PieChartSectionData(
//                     value: active.toDouble(),
//                     title:
//                         '${((active / (active + inactive)) * 100).toStringAsFixed(0)}%',
//                     color: Colors.green,
//                     radius: 50,
//                     titleStyle: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   PieChartSectionData(
//                     value: inactive.toDouble(),
//                     title:
//                         '${((inactive / (active + inactive)) * 100).toStringAsFixed(0)}%',
//                     color: Colors.orange,
//                     radius: 50,
//                     titleStyle: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(width: 20),
//           Expanded(
//             //flex: 2,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildLegend(color: accentColor, text: 'Activos ($active)'),
//                 const SizedBox(height: 8),
//                 _buildLegend(
//                   color: Colors.orange,
//                   text: 'Inactivos ($inactive)',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget para la leyenda del gráfico
//   Widget _buildLegend({required Color color, required String text}) {
//     return Row(
//       children: [
//         Container(width: 16, height: 16, color: color),
//         const SizedBox(width: 8),
//         Text(text, style: const TextStyle(fontSize: 16)),
//       ],
//     );
//   }
//
//   // Configuración para el gráfico de crecimiento
//   // LineChartData _buildGrowthChartData(
//   //   List<FlSpot> spots,
//   //   List<Member> sortedMembers,
//   // ) {
//   // return LineChartData(
//   //   gridData: FlGridData(show: false),
//   //   titlesData: FlTitlesData(
//   //     leftTitles: AxisTitles(
//   //       sideTitles: SideTitles(showTitles: true, reservedSize: 40),
//   //     ),
//   //     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//   //     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//   //     bottomTitles: AxisTitles(
//   //       sideTitles: SideTitles(
//   //         showTitles: true,
//   //         reservedSize: 30,
//   //         interval: 1,
//   //         getTitlesWidget: (value, meta) {
//   //           final int index = value.toInt();
//   //           if (index == 0 || index == spots.length - 1) {
//   //             final member = sortedMembers[index];
//   //             return Padding(
//   //               padding: const EdgeInsets.only(top: 8.0),
//   //               child: Text(
//   //                 DateFormat(
//   //                   'MMM yyyy',
//   //                   'es_ES',
//   //                 ).format(member.registrationDate),
//   //               ),
//   //             );
//   //           }
//   //           return const Text('');
//   //         },
//   //       ),
//   //     ),
//   //   ),
//   //   borderData: FlBorderData(
//   //     show: true,
//   //     border: Border.all(color: Colors.grey[300]!),
//   //   ),
//   //   lineBarsData: [
//   //     LineChartBarData(
//   //       spots: spots,
//   //       isCurved: true,
//   //       color: accentColor,
//   //       barWidth: 4,
//   //       dotData: FlDotData(show: false),
//   //       belowBarData: BarAreaData(
//   //         show: true,
//   //         color: accentColor.withOpacity(0.2),
//   //       ),
//   //     ),
//   //   ],
//   // );
// }
//
// //}
