import 'package:Koinos/widgets/member_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';
import '../routes/page_route_builder.dart';
import '../widgets/action_buttons.dart';
import '../widgets/add_button.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_card_container.dart';
import '../widgets/menu.dart';
import '../widgets/no_connection_widget.dart';
import '../widgets/pagination.dart';
import '../widgets/search_text_field.dart';
import '../widgets/showDeleteConfirmationDialog.dart';
import 'create/create_member.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  void _handleDelete(BuildContext context, Member member) async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final success = await memberProvider.deleteMember(member.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Miembro "${member.name} ${member.lastName}" eliminado.'
                : 'Error al eliminar el miembro',
          ),
          backgroundColor: success ? accentColor : negativeColor,
        ),
      );
    }
  }

  // 2. Función que abre tu diálogo de confirmación
  void _showDelete(BuildContext context, Member member) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: '${member.name} ${member.lastName}',
      onConfirm: () => _handleDelete(context, member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final memberProvider = Provider.of<MemberProvider>(context);
    final List<Member> filteredMembers = memberProvider.filteredMembers;

    if (memberProvider.error == 'SIN_CONEXION') {
      return Scaffold(
        appBar: CustomAppBar(title: 'Miembros'), // O tu AppBar actual
        body: NoConnectionWidget(
          // O el widget que uses para reintentar
          onRefresh: () => memberProvider.fetchMembers(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Miembros',
        isDrawerEnabled: isMobile,
        showBackButton: true,
      ),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) Menu(),
            Expanded(
              child: _buildMembersContent(
                context,
                isMobile,
                memberProvider,
                filteredMembers,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Este widget ahora recibe el provider y la lista de miembros como parámetros
  Widget _buildMembersContent(
    BuildContext context,
    bool isMobile,
    MemberProvider provider,
    List<Member> members,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Barra de búsqueda
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 18.0 : 24.0),
          child: isMobile
              ? _buildMobileLayout(context, provider)
              : _buildWebLayout(provider, context),
        ),
        SizedBox(height: isMobile ? 15 : 30),
        // Lista de miembros
        Expanded(
          child: _buildMemberList(context, isMobile, members),
        ), // Pasa la lista filtrada
        if (provider.totalPages > 0 && !provider.isLoading)
          Pagination(
            currentPage: provider.currentPage,
            totalPages: provider.totalPages,
            itemsPerPage: provider.pageSize,
            onPageChanged: (page) => provider.onPageChanged(page),
            onItemsPerPageChanged: (size) =>
                provider.onItemsPerPageChanged(size),
          ),
      ],
    );
  }

  Row _buildWebLayout(MemberProvider provider, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: SearchTextField(
            onChanged: (query) {
              provider.search(query);
            },
            controller: null,
          ),
        ),
        const SizedBox(width: 20),
        AddButton(
          onPressed: () {
            Navigator.push(context, createFadeRoute(const CreateMember()));
          },
        ),
      ],
    );
  }

  Column _buildMobileLayout(BuildContext context, MemberProvider provider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SearchTextField(
            onChanged: (query) {
              provider.search(query);
            },
            controller: null,
          ),
        ),

        const SizedBox(height: 15),
        AddButton(
          size: Size(MediaQuery.of(context).size.width * 0.9, 50),

          onPressed: () {
            Navigator.push(context, createFadeRoute(const CreateMember()));
          },
        ),
      ],
    );
  }

  Widget _buildMemberList(
    BuildContext context,
    bool isMobile,
    List<Member> members,
  ) {
    final provider = Provider.of<MemberProvider>(context, listen: false);

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (members.isEmpty) {
      return const Center(child: Text('No se encontraron miembros.'));
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 15 : 20),
      child: CustomCardContainer(
        padding: EdgeInsets.all(isMobile ? 5 : 20),
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
              child: Column(
                children: [
                  Row(
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
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member.networkName ?? 'Sin Red',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ActionButtons(
                      onEdit: () {
                        Navigator.push(
                          context,
                          createFadeRoute(CreateMember(memberToEdit: member)),
                        );
                      },
                      onDelete: () => _showDelete(context, member),
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
}
