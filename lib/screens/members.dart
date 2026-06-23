import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';
import '../routes/page_route_builder.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import '../widgets/action_buttons.dart';
import '../widgets/add_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/body_width.dart';
import '../widgets/member_list_tile.dart';
import '../widgets/nav_destinations.dart';
import '../widgets/nav_shell.dart';
import '../widgets/pagination.dart';
import '../widgets/search_text_field.dart';
import '../widgets/showDeleteConfirmationDialog.dart';
import '../widgets/states/app_skeleton.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/error_state.dart';
import '../widgets/status_pill.dart';
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
            child: _buildTable(context, provider, members, isCompact),
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
    bool isCompact,
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusCard),
        border: Border.all(color: alternateColor, width: 1),
      ),
      child: Column(
        children: [
          _buildHeaderRow(context, isCompact),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchMembers(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: members.length,
                itemBuilder: (_, i) =>
                    _buildMemberRow(context, members[i], isCompact),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isCompact) {
    final labelStyle = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: secondaryText, fontWeight: FontWeight.w600);

    return Container(
      color: surfaceSubtle,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('Nombre', style: labelStyle)),
          if (!isCompact)
            Expanded(flex: 2, child: Text('Red', style: labelStyle)),
          SizedBox(
            width: _statusColWidth,
            child: Text('Estado', style: labelStyle),
          ),
          if (!isCompact) const SizedBox(width: _actionsColWidth),
          if (isCompact) const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, Member member, bool isCompact) {
    final statusPill =
        member.enabled ? StatusPill.active() : StatusPill.inactive();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: MemberListTile(
              member: member,
              subtitle: memberPhoneSubtitle(member),
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            ),
          ),
          if (!isCompact)
            Expanded(
              flex: 2,
              child: Text(
                member.networkName ?? 'Sin red',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: secondaryText),
              ),
            ),
          SizedBox(
            width: _statusColWidth,
            child: Align(alignment: Alignment.centerLeft, child: statusPill),
          ),
          if (!isCompact)
            SizedBox(
              width: _actionsColWidth,
              child: ActionButtons(
                onEdit: () => _openCreate(member: member),
                onDelete: () => _showDelete(context, member),
              ),
            )
          else
            _buildRowMenu(context, member),
        ],
      ),
    );
  }

  Widget _buildRowMenu(BuildContext context, Member member) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: secondaryText),
      onSelected: (value) {
        if (value == 'edit') {
          _openCreate(member: member);
        } else if (value == 'delete') {
          _showDelete(context, member);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Editar')),
        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }

  static const double _statusColWidth = 100;
  static const double _actionsColWidth = 96;
}
