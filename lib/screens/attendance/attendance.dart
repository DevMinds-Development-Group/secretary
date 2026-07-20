import 'package:Koinos/utils/app_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../models/member_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/service_provider.dart';
import '../../theme/design_constants.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/member_list_tile.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/no_connection_widget.dart';

class Attendance extends StatefulWidget {
  final AttendanceModel? existingRecord;

  const Attendance({super.key, this.existingRecord});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedEventId;
  String? _selectedNetworkId;
  int _visitorsCount = 0;
  int _pastoralVisitsCount = 0;
  int _newConvertCount = 0;
  String _observations = "";
  final Set<String> _presentMemberIds = {};
  Set<String> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).fetchAllMembers();
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
    });

    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _selectedEventId = record.definitionId;
      _selectedNetworkId = record.networkId;
      _selectedDate = record.date;
      _visitorsCount = record.visitorsCount;
      _pastoralVisitsCount = record.pastoralVisitsCount;
      _newConvertCount = record.newConvert;
      _observations = record.observations;

      _presentMemberIds.clear();
      _presentMemberIds.addAll(record.presentMemberIds);

      appLog("DEBUG: Cargados ${_presentMemberIds.length} miembros para editar");
    }
  }

  Widget _buildNetworkDropdown() {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final networks = networkProvider.networks;

    // if (_selectedNetworkId != null &&
    //     !networks.any((net) => net.id == _selectedNetworkId)) {
    //   _selectedNetworkId = null;
    // }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          DesignConstants.borderRadiusDropdown,
        ),
        border: Border.all(color: alternateColor, width: 1.5),
        color: secondaryBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedNetworkId,
          hint: const Text("Seleccionar Red"),
          isExpanded: false,
          borderRadius: BorderRadius.circular(
            DesignConstants.borderRadiusDropdown,
          ),
          dropdownColor: secondaryBackground,
          items: [
            const DropdownMenuItem(value: null, child: Text("Todas las Redes")),
            ...networks.map(
              (net) => DropdownMenuItem(value: net.id, child: Text(net.name)),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedNetworkId = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEventDropdown() {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final services = serviceProvider.services;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          DesignConstants.borderRadiusDropdown,
        ),
        border: Border.all(color: alternateColor, width: 1.5),
        color: secondaryBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventId,
          hint: const Text(
            "Seleccionar Evento",
            style: TextStyle(color: primaryText),
          ),
          isExpanded: false,
          borderRadius: BorderRadius.circular(
            DesignConstants.borderRadiusDropdown,
          ),
          dropdownColor: secondaryBackground,
          items: services.map((service) {
            return DropdownMenuItem<String>(
              value: service.id,
              child: Text(service.title),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedEventId = value);
          },
        ),
      ),
    );
  }

  void _loadRecordForDate(DateTime date) {
    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );
    final record = attendanceProvider.getRecordForDate(date);

    setState(() {
      if (record != null) {
        _visitorsCount = record.visitorsCount;
        _pastoralVisitsCount = record.pastoralVisitsCount;
        _presentMemberIds.clear();
        _presentMemberIds.addAll(record.presentMemberIds);
      } else {
        _visitorsCount = 0;
        _pastoralVisitsCount = 0;
        _presentMemberIds.clear();
      }
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadRecordForDate(date);
  }

  void _saveAttendance() async {
    if (_selectedEventId == null || _selectedNetworkId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona Evento y Red obligatoriamente'),
        ),
      );
      return;
    }

    final attendanceProvider = Provider.of<AttendanceProvider>(
      context,
      listen: false,
    );

    final newRecord = AttendanceModel(
      id: widget.existingRecord?.id ?? "",
      definitionId: _selectedEventId!,
      networkId: _selectedNetworkId!,
      date: _selectedDate,
      visitorsCount: _visitorsCount,
      pastoralVisitsCount: _pastoralVisitsCount,
      presentMemberIds: _presentMemberIds,
      newConvert: _newConvertCount,
    );

    bool success = await attendanceProvider.saveRecord(newRecord);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asistencia guardada correctamente'),
          backgroundColor: accentColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            attendanceProvider.error ?? 'Error al guardar asistencia',
          ),
          backgroundColor: negativeColor,
        ),
      );
    }

    attendanceProvider.saveRecord(newRecord);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    // Escuchamos todos los providers al inicio
    final memberProvider = context.watch<MemberProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final netProvider = context.watch<NetworkProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    // 1. PRIORIDAD: ERROR DE CONEXIÓN
    if (memberProvider.allError == "SIN_CONEXION" ||
        serviceProvider.error == "SIN_CONEXION" ||
        netProvider.error == "SIN_CONEXION" ||
        attendanceProvider.error == "SIN_CONEXION") {
      return NavShell(
        isSecondary: true,
        title: 'Asistencia',
        body: NoConnectionWidget(
          onRefresh: () async {
            memberProvider.clearAllError();
            serviceProvider.clearError();
            netProvider.clearError();
            attendanceProvider.clearError();

            await Future.wait([
              memberProvider.fetchAllMembers(),
              serviceProvider.fetchServices(),
              netProvider.fetchNetworks(),
            ]);
          },
        ),
      );
    }

    // 2. PRIORIDAD: CARGA INICIAL
    if (memberProvider.allLoading ||
        serviceProvider.isLoading ||
        netProvider.isLoading) {
      return NavShell(
        isSecondary: true,
        title: 'Asistencia',
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    List<Member> membersToShow = memberProvider.allMembers;

    if (_selectedNetworkId != null) {
      membersToShow = membersToShow
          .where((m) => m.networkId == _selectedNetworkId)
          .toList();
    }

    return NavShell(
      isSecondary: true,
      title: 'Asistencia',
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isMobile
                  ? _buildMobileControls(memberProvider, isMobile)
                  : _buildWebControls(memberProvider, isMobile),
            ),
            const SizedBox(height: 10),
            // Pasamos la lista filtrada correctamente
            Expanded(child: _buildMemberList(membersToShow, isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileControls(memberProvider, isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: _buildEventDropdown(),
            ),
            SizedBox(height: 15),
            SizedBox(
              child: _buildNetworkDropdown(),
              width: MediaQuery.of(context).size.width * 0.95,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVisitorsTextField(),
                SizedBox(width: 20),
                _buildPastoralTextField(),
              ],
            ),
            SizedBox(height: 15),
            _buildNewConvertTextField(isMobile),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          child: Button(
            text: 'Guardar',
            onPressed: _saveAttendance,
            size: Size(MediaQuery.of(context).size.width * 0.95, 50),
          ),
        ),
      ],
    );
  }

  // lib/screens/attendance/attendance.dart

  Widget _buildPastoralTextField() {
    return SizedBox(
      width: 150, // Ajusta el ancho según necesites
      child: CustomTextFormField(
        labelText: 'Visitas Pastorales',
        keyboardType: TextInputType.number,
        initialValue: _pastoralVisitsCount.toString(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Solo números
        onChanged: (value) {
          setState(() {
            _pastoralVisitsCount = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildNewConvertTextField(isMobile) {
    return SizedBox(
      width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 150,
      child: CustomTextFormField(
        labelText: 'Nuevos convertidos',
        keyboardType: TextInputType.number,
        initialValue: _newConvertCount.toString(),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ], // Solo números
        onChanged: (value) {
          setState(() {
            _newConvertCount = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildVisitorsTextField() {
    return SizedBox(
      width: 150,
      child: CustomTextFormField(
        labelText: 'Visitas',
        keyboardType: TextInputType.number,
        initialValue: _visitorsCount.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            _visitorsCount = int.tryParse(value) ?? 0;
          });
        },
      ),
    );
  }

  Widget _buildWebControls(memberProvider, isMobile) {
    return Wrap(
      spacing: 15,
      runSpacing: 20,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        _buildEventDropdown(),
        _buildNetworkDropdown(),
        _buildVisitorsTextField(),
        _buildPastoralTextField(),
        _buildNewConvertTextField(isMobile),
        Button(
          text: 'Guardar',
          onPressed: _saveAttendance,
          size: const Size(160, 45),
        ),
      ],
    );
  }

  Widget _buildMemberList(List<Member> members, isMobile) {
    final memberProvider = context.watch<MemberProvider>();

    if (memberProvider.allLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    if (members.isEmpty) {
      return const Center(child: Text('No se encontraron miembros.'));
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomCardContainer(
        padding: EdgeInsets.all(isMobile ? 5 : 20),
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 10),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final bool isPresent = _presentMemberIds.contains(member.id);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              decoration: BoxDecoration(
                // Opcional: cambiar el color si está seleccionado para dar feedback visual
                color: isPresent
                    ? primaryColor.withOpacity(0.05)
                    : secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPresent
                      ? primaryColor.withOpacity(0.3)
                      : Colors.transparent,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: MemberListTile(
                member: member,
                onTap: () {
                  setState(() {
                    if (isPresent) {
                      _presentMemberIds.remove(member.id);
                    } else {
                      _presentMemberIds.add(member.id);
                    }
                  });
                },
                trailing: Checkbox(
                  activeColor: primaryColor,
                  value: isPresent,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _presentMemberIds.add(member.id);
                      } else {
                        _presentMemberIds.remove(member.id);
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
