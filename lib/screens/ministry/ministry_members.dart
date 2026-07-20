import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../models/ministry_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/member_list_tile.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/no_connection_widget.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/small_button.dart';
import '../member_profile.dart';

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
      ).fetchAllMembers();
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
        memberProvider.allError == "SIN_CONEXION") {
      return NavShell(
        isSecondary: true,
        title: widget.ministry.name,
        body: NoConnectionWidget(
          onRefresh: () {
            ministryProvider.clearError();
            memberProvider.clearAllError();
            ministryProvider.fetchMinistryDetails(widget.ministry.id);
            memberProvider.fetchAllMembers();
          },
        ),
      );
    }

    return NavShell(
      isSecondary: true,
      title: isMobile
          ? widget.ministry.name
          : 'Miembros de ${currentMinistry.name}',
      body: SafeArea(
        child: ministryProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: primaryColor),
              ) // Mostrar carga
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 5),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      if (permissions.canSeeMembers)
                        Align(
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
                              memberProvider.allMembers,
                              isMobile,
                              currentMinistry,
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      _buildMinistryHeader(currentMinistry, isMobile),
                      SizedBox(height: 20),
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
                style: TextStyle(color: secondaryText),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
          Icon(Icons.group_off, size: isMobile ? 60 : 80, color: secondaryText),
          SizedBox(height: 16),
          Text(
            'No hay miembros en esta red',
            style: TextStyle(fontSize: isMobile ? 15 : 18, color: secondaryText),
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
          return AppChip(
            avatar: CircleAvatar(
              backgroundColor: primaryColor,
              child: Text(
                leader.name[0].toUpperCase(),
                style: const TextStyle(color: infoColor, fontSize: 15),
              ),
            ),
            label: '${leader.name} ${leader.lastName}',
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
      padding: EdgeInsets.zero,
      child: CustomCardContainer(
        padding: EdgeInsets.all(10),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: members.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = members[index];
            return MemberListTile(
              member: member,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  memberPhoneSubtitle(member),
                  Text(
                    member.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: secondaryText),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: primaryColor,
                    ),
                    tooltip: 'Ver perfil',
                    onPressed: () => Navigator.push(
                      context,
                      createFadeRoute(MemberProfileScreen(member: member)),
                    ),
                  ),
                  if (permissions.canSeeMembers)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: negativeColor,
                      ),
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
        ),
      ),
    );
  }
}
