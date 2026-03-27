import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../models/member_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/counter.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/menu.dart';
import '../../widgets/search_text_field.dart';

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
  String _observations = "";
  final Set<String> _presentMemberIds = {};
  Set<String> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
    });

    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _selectedEventId = record.definitionId;
      _selectedNetworkId = record.networkId;
      _selectedDate = record.date;
      _visitorsCount = record.visitorsCount;
      _pastoralVisitsCount = record.pastoralVisitsCount;
      _observations = record.observations;

      _presentMemberIds.clear();
      _presentMemberIds.addAll(record.presentMemberIds);

      print("DEBUG: Cargados ${_presentMemberIds.length} miembros para editar");
    }
  }

  Widget _buildNetworkDropdown() {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final networks = networkProvider.networks;

    if (_selectedNetworkId != null &&
        !networks.any((net) => net.id == _selectedNetworkId)) {
      _selectedNetworkId = null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        color: cardColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedNetworkId,
          //hint: const Text("Seleccionar Red"),
          isExpanded: false,
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        color: cardColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedEventId,
          hint: const Text("Seleccionar Evento"),
          isExpanded: false,
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

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   _loadRecordForDate(_selectedDate);
  // }

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
    );

    bool success = await attendanceProvider.saveRecord(newRecord);

    if (!mounted) return;

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asistencia guardada correctamente'),
          backgroundColor: Colors.green,
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
    final memberProvider = Provider.of<MemberProvider>(context);
    List<Member> members = memberProvider.filteredMembers;

    if (_selectedNetworkId != null) {
      members = members
          .where((m) => m.networkId == _selectedNetworkId)
          .toList();
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Asistencia', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) Menu(),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: isMobile
                        ? _buildMobileControls(memberProvider)
                        : _buildWebControls(memberProvider),
                  ),

                  const SizedBox(height: 10),

                  Expanded(child: _buildMemberList(members, isMobile)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileControls(memberProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            child: SearchTextField(
              onChanged: (query) => memberProvider.search(query),
            ),
          ),
        ),

        SizedBox(height: 15),
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
                _counterVisitors(),
                SizedBox(width: 20),
                _counterPastoral(),
              ],
            ),
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

  Counter _counterPastoral() {
    return Counter(
      label: 'Visitas Pastorales',
      initialValue: _pastoralVisitsCount,
      onCountChanged: (count) => _pastoralVisitsCount = count,
    );
  }

  Counter _counterVisitors() {
    return Counter(
      label: 'Visitas',
      initialValue: _visitorsCount,
      onCountChanged: (count) => _visitorsCount = count,
    );
  }

  Widget _buildWebControls(memberProvider) {
    return Wrap(
      spacing: 40,
      runSpacing: 20,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        _buildEventDropdown(),
        _buildNetworkDropdown(),
        _counterVisitors(),
        _counterPastoral(),
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

    if (memberProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (members.isEmpty) {
      return const Center(child: Text('No se encontraron miembros.'));
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomCardContainer(
        padding: EdgeInsets.all(10),
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 10),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final bool isPresent = _presentMemberIds.contains(member.id);

            return ListTile(
              leading: isMobile
                  ? null
                  : CircleAvatar(
                      backgroundColor: isPresent
                          ? accentColor.withOpacity(0.1)
                          : negativeColor.withOpacity(0.1),
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: isPresent ? accentColor : negativeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              title: Text('${member.name} ${member.lastName}'),
              trailing: Checkbox(
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
              onTap: () {
                setState(() {
                  if (isPresent) {
                    _presentMemberIds.remove(member.id);
                  } else {
                    _presentMemberIds.add(member.id);
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}
