import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';
import '../routes/page_route_builder.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import '../widgets/add_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/body_width.dart';
import '../widgets/member_table.dart';
import '../widgets/nav_destinations.dart';
import '../widgets/nav_shell.dart';
import '../widgets/pagination.dart';
import '../widgets/search_text_field.dart';
import '../widgets/showDeleteConfirmationDialog.dart';
import '../widgets/states/app_skeleton.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/error_state.dart';
import 'create/create_member.dart';

enum _MemberStatusFilter { all, active, inactive }

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  _MemberStatusFilter _filter = _MemberStatusFilter.all;

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

  void _showDelete(BuildContext context, Member member) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: '${member.name} ${member.lastName}',
      onConfirm: () => _handleDelete(context, member),
    );
  }

  void _openCreate({Member? member}) {
    Navigator.push(
      context,
      createFadeRoute(CreateMember(memberToEdit: member)),
    );
  }

  List<Member> _applyFilter(List<Member> members) {
    switch (_filter) {
      case _MemberStatusFilter.all:
        return members;
      case _MemberStatusFilter.active:
        return members.where((m) => m.enabled).toList();
      case _MemberStatusFilter.inactive:
        return members.where((m) => !m.enabled).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);

    if (memberProvider.error != null) {
      return NavShell(
        current: NavSection.members,
        title: 'Miembros',
        body: ErrorState(
          error: memberProvider.error,
          onRetry: () => memberProvider.fetchMembers(),
        ),
      );
    }

    return NavShell(
      current: NavSection.members,
      title: 'Miembros',
      body: _buildContent(context, memberProvider),
    );
  }

  Widget _buildContent(BuildContext context, MemberProvider provider) {
    final isCompact = context.isCompact;
    final members = _applyFilter(provider.filteredMembers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.xl),
          child: BodyWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: Spacing.lg),
                _buildSearchRow(context, provider, isCompact),
                const SizedBox(height: Spacing.md),
                _buildFilterChips(),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Expanded(
          child: BodyWidth(
            child: _buildTable(context, provider, members),
          ),
        ),
        if (provider.totalPages > 0 && !provider.isLoading)
          BodyWidth(
            child: Pagination(
              currentPage: provider.currentPage,
              totalPages: provider.totalPages,
              itemsPerPage: provider.pageSize,
              onPageChanged: (page) => provider.onPageChanged(page),
              onItemsPerPageChanged: (size) =>
                  provider.onItemsPerPageChanged(size),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Miembros', style: textTheme.headlineMedium),
        const SizedBox(height: Spacing.xxs),
        Text(
          'Lista de los miembros de tu iglesia.',
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );
  }

  Widget _buildSearchRow(
    BuildContext context,
    MemberProvider provider,
    bool isCompact,
  ) {
    final search = SearchTextField(
      hintText: 'Buscar miembros…',
      onChanged: (query) => provider.search(query),
    );
    final add = AddButton(
      size: isCompact ? const Size(double.infinity, 48) : null,
      onPressed: () => _openCreate(),
    );

    if (isCompact) {
      return Column(
        children: [search, const SizedBox(height: Spacing.md), add],
      );
    }
    return Row(
      children: [
        Expanded(child: search),
        const SizedBox(width: Spacing.lg),
        add,
      ],
    );
  }

  Widget _buildFilterChips() {
    Widget chip(String label, _MemberStatusFilter value) => AppFilterChip(
          label: label,
          selected: _filter == value,
          onSelected: (_) => setState(() => _filter = value),
        );

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        chip('Todos', _MemberStatusFilter.all),
        chip('Activos', _MemberStatusFilter.active),
        chip('Inactivos', _MemberStatusFilter.inactive),
      ],
    );
  }

  Widget _buildTable(
    BuildContext context,
    MemberProvider provider,
    List<Member> members,
  ) {
    if (provider.isLoading) {
      return const AppSkeleton.list();
    }
    if (members.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No se encontraron miembros',
        message: 'Agrega un miembro o ajusta tu búsqueda.',
        action: AddButton(onPressed: () => _openCreate()),
      );
    }

    return MemberTable(
      members: members,
      showNetworkColumn: true,
      onEdit: (m) => _openCreate(member: m),
      onDelete: (m) => _showDelete(context, m),
      onRefresh: () => provider.fetchMembers(),
    );
  }
}
