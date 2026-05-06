import 'package:Koinos/screens/create/create_member.dart';
import 'package:Koinos/widgets/add_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../colors.dart';
import '../../../models/member_model.dart';
import '../../../providers/member_provider.dart';
import '../../../widgets/custom_appbar.dart';
import '../../models/network_model.dart';
import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/member_profile_image.dart';
import '../../widgets/no_connection_widget.dart';

class NetworkMembers extends StatefulWidget {
  final NetworkModel network;

  const NetworkMembers({Key? key, required this.network}) : super(key: key);

  @override
  State<NetworkMembers> createState() => _NetworkMembersState();
}

class _NetworkMembersState extends State<NetworkMembers> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).fetchMembers(page: 0, size: 1000);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final networkProvider = context.watch<NetworkProvider>();
    final memberProvider = Provider.of<MemberProvider>(context);

    if (memberProvider.error == "SIN_CONEXION" ||
        networkProvider.error == "SIN_CONEXION") {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: widget.network.name),
        body: NoConnectionWidget(
          onRefresh: () {
            memberProvider.clearError();
            networkProvider.clearError();
            memberProvider.fetchMembers(page: 0, size: 1000);
          },
        ),
      );
    }

    final List<Member> membersInGroup = memberProvider.members
        .where((member) => member.networkId == widget.network.id)
        .toList();

    membersInGroup.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: widget.network.name),
      body: SafeArea(
        child: networkProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 5),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1500),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        _buildNetworkHeader(widget.network, isMobile),
                        SizedBox(height: 20),
                        Expanded(
                          child: memberProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                              : membersInGroup.isEmpty
                              ? _buildEmptyState(
                                  isMobile,
                                ) // Solo se muestra si terminó de cargar y está vacío
                              : _buildMemberList(membersInGroup, isMobile),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNetworkHeader(NetworkModel network, bool isMobile) {
    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AddButton(
              size: Size(
                isMobile ? MediaQuery.of(context).size.width * 0.85 : 200,
                isMobile ? 50 : 45,
              ),
              onPressed: () => Navigator.push(
                context,
                createFadeRoute(const CreateMember()),
              ),
              title: 'Crear Miembro',
            ),
          ),
          SizedBox(height: isMobile ? 15 : 0),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLeadersSection(network, isMobile),
                )
              : Row(children: _buildLeadersSection(network, isMobile)),
          const Divider(height: 30),
          Wrap(
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
          SizedBox(height: isMobile ? 0 : 8),
        ],
      ),
    );
  }

  // Widget para la lista de miembros (Estilo Members.dart)
  Widget _buildMemberList(List<Member> members, bool isMobile) {
    return Padding(
      padding: EdgeInsets.zero,
      child: CustomCardContainer(
        padding: EdgeInsets.all(10),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: members.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MemberProfileImage(
                    imageUrl: member.photoUrl,
                    name: member.name,
                    radius: 25,
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${member.name} ${member.lastName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          member.phone,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          member.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget para cuando no hay miembros en la red
  Widget _buildEmptyState(isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: isMobile ? 60 : 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay miembros en esta red',
            style: TextStyle(fontSize: isMobile ? 15 : 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeadersSection(NetworkModel network, isMobile) {
    return [
      const Text(
        'Líderes:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(width: 10, height: 5),
      Wrap(
        spacing: 5,
        runSpacing: isMobile ? 0 : 5,
        children: network.leaders.map((leader) {
          return Chip(
            backgroundColor: primaryColor.withOpacity(0.1),
            avatar: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                leader.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            label: Text('${leader.name} ${leader.lastName}'),
          );
        }).toList(),
      ),
    ];
  }
}
