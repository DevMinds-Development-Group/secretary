import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/member_provider.dart';
import '../../widgets/custom_appbar.dart';

class AttendanceDetail extends StatelessWidget {
  final AttendanceModel record;

  const AttendanceDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);

    print("DEBUG: IDs en el registro: ${record.presentMemberIds}");
    print(
      "DEBUG: Total miembros en provider: ${memberProvider.members.length}",
    );

    final presentMembers = memberProvider.members
        .where((m) => record.presentMemberIds.contains(m.id))
        .toList();

    print("DEBUG: Miembros encontrados tras filtrar: ${presentMembers.length}");

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Detalles de Asistencia'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                if (presentMembers.isEmpty)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Text("No se registraron miembros presentes"),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: presentMembers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final member = presentMembers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.2),
                            child: Text(
                              member.name[0],
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text("${member.name} ${member.lastName}"),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final int total = record.presentMemberIds.length + record.visitorsCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.definitionName ?? 'Evento'} | ${record.networkName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date),
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _infoItem(
                "Miembros: ",
                record.presentMemberIds.length.toString(),
              ),
              _infoItem("Visitas: ", record.visitorsCount.toString()),
              _infoItem("TOTAL: ", total.toString()),
              Divider(),
              _infoItem(
                "Visitas Pastorales: ",
                record.pastoralVisitsCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
