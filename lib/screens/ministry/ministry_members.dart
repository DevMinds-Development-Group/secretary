import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../models/ministry_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/member_profile_image.dart';
import '../../widgets/no_connection_widget.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/small_button.dart';

class MinistryMembers extends StatefulWidget {
  final MinistryModel ministry;

  const MinistryMembers({Key? key, required this.ministry}) : super(key: key);

  @override
  State<MinistryMembers> createState() => _MinistryMembersState();
}

class _MinistryMembersState extends State<MinistryMembers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MinistryProvider>(context, listen: false);
      provider.fetchMinistryDetails(widget.ministry.id);

      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).fetchMembers(page: 0, size: 1000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final permissions = UserPermissions(context.read<AuthService>());

    final currentMinistry = ministryProvider.ministries.firstWhere(
      (m) => m.id == widget.ministry.id,
      orElse: () => widget.ministry,
    );
    final List<Member> membersInGroup = currentMinistry.members ?? [];

    List<Member> sortedMembers = List.from(membersInGroup);
    sortedMembers.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    bool isMobile = MediaQuery.of(context).size.width < 700;

    if (ministryProvider.error == "SIN_CONEXION" ||
        memberProvider.error == "SIN_CONEXION") {
      return Scaffold(
        appBar: CustomAppBar(title: widget.ministry.name),
        body: NoConnectionWidget(
          onRefresh: () {
            ministryProvider.clearError();
            memberProvider.clearError();
            ministryProvider.fetchMinistryDetails(widget.ministry.id);
            memberProvider.fetchMembers(page: 0, size: 1000);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: isMobile
            ? widget.ministry.name
            : 'Miembros de ${currentMinistry.name}',
      ),
      body: ministryProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ) // Mostrar carga
          : SafeArea(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: isMobile ? 5 : 20),
                    if (isMobile)
                      _buildMinistryHeader(currentMinistry, isMobile),
                    if (permissions.canSeeMembers)
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Align(
                          alignment: isMobile
                              ? Alignment.center
                              : Alignment.centerRight,
                          child: AddButton(
                            size: isMobile
                                ? Size(
                                    MediaQuery.of(context).size.width * 0.9,
                                    50,
                                  )
                                : null,
                            onPressed: () => _showAddMemberDialog(
                              context,
                              memberProvider.members,
                              isMobile,
                              currentMinistry,
                            ),
                          ),
                        ),
                      ),
                    if (!isMobile)
                      _buildMinistryHeader(currentMinistry, isMobile),
                    if (isMobile) const SizedBox(height: 15),
                    Expanded(
                      child: ministryProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          : sortedMembers.isEmpty
                          ? _buildEmptyState(isMobile)
                          : _buildMemberList(
                              sortedMembers,
                              isMobile,
                              currentMinistry,
                              permissions,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    List<Member> allMembers,
    bool isMobile,
    MinistryModel currentMinistry,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) {
        Member? selectedMember;

        final existingMemberIds = currentMinistry.members
            .map((m) => m.id)
            .toSet();

        return AlertDialog(
          title: Text(
            textAlign: TextAlign.center,
            'Agregar Miembro a "${widget.ministry.name}"',
            style: TextStyle(fontSize: isMobile ? 20 : 24),
          ),
          content: Autocomplete<Member>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<Member>.empty();
              }
              return allMembers.where((member) {
                final fullName = '${member.name} ${member.lastName}'
                    .toLowerCase();
                final query = textEditingValue.text.toLowerCase();
                return fullName.contains(query) &&
                    !existingMemberIds.contains(member.id);
              });
            },

            displayStringForOption: (Member option) =>
                '${option.name} ${option.lastName}',

            onSelected: (Member selection) {
              selectedMember = selection;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Buscar miembro...',
                    ),
                  );
                },
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            SmallButton(
              text: 'Agregar',
              onPressed: () async {
                if (selectedMember != null) {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<MinistryProvider>(
                      context,
                      listen: false,
                    ).addMemberToMinistry(widget.ministry.id, selectedMember!);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al sincronizar con el servidor'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMinistryHeader(MinistryModel ministry, bool isMobile) {
    return CustomCardContainer(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildLeadersSection(ministry, isMobile),
                )
              : Row(children: _buildLeadersSection(ministry, isMobile)),
          const Divider(height: 30),
          Wrap(
            children: [
              const Text(
                'Descripción:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // color: Colors.blueGrey,
                ),
              ),
              SizedBox(width: 10),
              Text(
                ministry.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 0 : 8),
        ],
      ),
    );
  }

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

  List<Widget> _buildLeadersSection(MinistryModel network, isMobile) {
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

  Widget _buildMemberList(
    List<Member> members,
    bool isMobile,
    MinistryModel currentMinistry,
    permissions,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = members[index];
        return Container(
          padding: const EdgeInsets.all(12),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alineado a la izquierda
                  children: [
                    Text(
                      '${member.name} ${member.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      member.phone,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      member.address,
                      style: TextStyle(color: Colors.grey[900], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (permissions.canSeeMembers)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: negativeColor),
                  onPressed: () {
                    showDeleteConfirmationDialog(
                      context: context,
                      itemName: '${member.name} ${member.lastName}',
                      onConfirm: () async {
                        try {
                          await Provider.of<MinistryProvider>(
                            context,
                            listen: false,
                          ).removeMemberFromMinistry(
                            currentMinistry.id,
                            member,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al eliminar miembro'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
