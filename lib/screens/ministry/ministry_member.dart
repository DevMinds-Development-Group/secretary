// lib/screens/ministry_members_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_model.dart';
import '../../models/ministry_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../widgets/custom_appbar.dart';
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

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final memberProvider = context.watch<MemberProvider>();
    final memberIds = ministryProvider.getMemberIdsForMinistry(
      widget.ministry.id,
    );
    final currentMinistry = ministryProvider.ministries.firstWhere(
      (m) => m.id == widget.ministry.id,
      orElse: () => widget.ministry,
    );
    final members = currentMinistry.members;
    final allMembers = memberProvider.members;

    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: isMobile
            ? widget.ministry.name
            : 'Miembros de ${currentMinistry.name}',
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showAddMemberDialog(
          context,
          allMembers,
          isMobile,
          currentMinistry,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ministryProvider.isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostrar carga
          : members.isEmpty
          ? const Center(child: Text('No hay miembros en este ministerio.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(member.name[0])),
                    title: Text('${member.name} ${member.lastName}'),
                    subtitle: Text(member.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showDeleteConfirmationDialog(
                        context: context,
                        itemName: member.name,
                        onConfirm: () async {
                          try {
                            await Provider.of<MinistryProvider>(
                              context,
                              listen: false,
                            ).removeMemberFromMinistry(
                              widget.ministry.id,
                              member,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Error al eliminar miembro del servidor',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
