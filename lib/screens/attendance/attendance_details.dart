import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/attendance_model.dart';
import '../../providers/member_provider.dart';
import '../../utils/app_log.dart';
import '../../widgets/body_width.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/member_list_tile.dart';
import '../../widgets/nav_shell.dart';

class AttendanceDetail extends StatelessWidget {
  final AttendanceModel record;

  const AttendanceDetail({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);

    appLog("DEBUG: IDs en el registro: ${record.presentMemberIds}");
    appLog(
      "DEBUG: Total miembros en provider: ${memberProvider.members.length}",
    );

    final presentMembers = memberProvider.members
        .where((m) => record.presentMemberIds.contains(m.id))
        .toList();

    appLog("DEBUG: Miembros encontrados tras filtrar: ${presentMembers.length}");

    return NavShell(
      isSecondary: true,
      title: 'Detalles de Asistencia',
      body: BodyWidth(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  CustomCardContainer(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: presentMembers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final member = presentMembers[index];
                        return MemberListTile(member: member);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildInfoCard() {
    final int total = record.presentMemberIds.length + record.visitorsCount;

    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.definitionName ?? 'Evento'} | ${record.networkName}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'es').format(record.date),
            style: TextStyle(
              fontSize: 16,
              color: primaryColor2,
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
              _infoItem("Nuevos convertidos: ", record.newConvert.toString()),
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
