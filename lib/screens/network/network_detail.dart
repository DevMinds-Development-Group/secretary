import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../models/member_model.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/custom_appbar.dart';
import '../../models/network_model.dart';

class NetworkDetail extends StatelessWidget {
  final NetworkModel network;

  const NetworkDetail({Key? key, required this.network}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    final memberProvider = Provider.of<MemberProvider>(context);

    final List<Member> membersInGroup = memberProvider.allMembers
        .where((member) => member.networkName == network.name)
        .toList();

    membersInGroup.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: network.name),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1500),
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildNetworkHeader(network, isMobile),
              Expanded(
                child: membersInGroup.isEmpty
                    ? _buildEmptyState()
                    : _buildMemberList(membersInGroup, isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkHeader(NetworkModel network, bool isMobile) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Líderes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  //color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 10),
              Wrap(
                spacing: 8,
                children: network.leaders.map((leader) {
                  return Chip(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    avatar: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Text(
                        leader.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    label: Text('${leader.name} ${leader.lastName}'),
                  );
                }).toList(),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              const Text(
                'Misión de la Red:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // color: Colors.blueGrey,
                ),
              ),
              SizedBox(width: 10),
              Text(
                network.mission ?? 'Sin misión definida',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mostramos los nombres de los líderes mapeados
        ],
      ),
    );
  }

  // Widget para la lista de miembros (Estilo Members.dart)
  Widget _buildMemberList(List<Member> members, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          itemCount: members.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 0.1),
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[200],
                child: Text(
                  member.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${member.name} ${member.lastName}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(member.phone),
            );
          },
        ),
      ),
    );
  }

  // Widget para cuando no hay miembros en la red
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay miembros en esta red',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
