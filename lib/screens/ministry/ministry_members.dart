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

      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final permissions = UserPermissions(context.read<AuthService>());
    final memberIds = ministryProvider.getMemberIdsForMinistry(
      widget.ministry.id,
    );
    final currentMinistry = ministryProvider.ministries.firstWhere(
      (m) => m.id == widget.ministry.id,
      orElse: () => widget.ministry,
    );
    //final members = currentMinistry.members;
    final allMembers = memberProvider.members;

    bool isMobile = MediaQuery.of(context).size.width < 700;

    final List<Member> membersInGroup = memberProvider.members.where((member) {
      return currentMinistry.members.any((m) => m.id == member.id);
    }).toList();

    membersInGroup.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: isMobile
            ? widget.ministry.name
            : 'Miembros de ${currentMinistry.name}',
      ),
      body: ministryProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar carga
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1500),
                  child: Column(
                    children: [
                      SizedBox(height: isMobile ? 5 : 20),
                      if (isMobile)
                        _buildMinistryHeader(currentMinistry, isMobile),
                      if (permissions.canSeeMembers)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16.0 : 0,
                          ),
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
                                allMembers,
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
                        child: membersInGroup.isEmpty
                            ? _buildEmptyState(isMobile)
                            : _buildMemberList(
                                membersInGroup,
                                isMobile,
                                currentMinistry,
                                permissions,
                              ),
                      ),
                    ],
                  ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
      child: CustomCardContainer(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: members.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: isMobile
                  ? null
                  : CircleAvatar(
                      backgroundColor: Colors.blue[400],
                      child: Text(
                        member.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              title: Text('${member.name} ${member.lastName}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(member.address), Text(member.phone)],
              ),
              trailing: permissions.canSeeMembers
                  ? IconButton(
                      icon: const Icon(Icons.delete, color: negativeColor),
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
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
