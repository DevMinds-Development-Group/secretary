import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/member_filters.dart';
import '../../models/member_model.dart';
import '../../models/network_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_members_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../theme/design_constants.dart';
import '../../utils/window_size.dart';
import '../../widgets/add_button.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/body_width.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/member_table.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/no_connection_widget.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_text_field.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/states/app_skeleton.dart';
import '../create/create_member.dart';
import '../member_profile.dart';

class NetworkMembers extends StatefulWidget {
  final NetworkModel network;

  const NetworkMembers({Key? key, required this.network}) : super(key: key);

  @override
  State<NetworkMembers> createState() => _NetworkMembersState();
}

class _NetworkMembersState extends State<NetworkMembers> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  bool? _enabled;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    final f = context.read<NetworkMembersProvider>().filters;
    _nameCtrl = TextEditingController(text: f.name);
    _lastNameCtrl = TextEditingController(text: f.lastName);
    _phoneCtrl = TextEditingController(text: f.phone);
    _enabled = f.enabled;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkMembersProvider>().loadFirstPage(widget.network.id);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  MemberFilters _currentFilters() => MemberFilters(
        name: _nameCtrl.text,
        lastName: _lastNameCtrl.text,
        phone: _phoneCtrl.text,
        enabled: _enabled,
      );

  void _applyFilters() {
    context.read<NetworkMembersProvider>().applyFilters(_currentFilters());
  }

  void _setEnabled(bool? value) {
    setState(() => _enabled = value);
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _nameCtrl.clear();
      _lastNameCtrl.clear();
      _phoneCtrl.clear();
      _enabled = null;
    });
    context.read<NetworkMembersProvider>().clearFilters();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_nameCtrl.text.trim().isNotEmpty) count++;
    if (_lastNameCtrl.text.trim().isNotEmpty) count++;
    if (_phoneCtrl.text.trim().isNotEmpty) count++;
    if (_enabled != null) count++;
    return count;
  }

  Future<void> _openCreate({Member? member}) async {
    await Navigator.push(
      context,
      createFadeRoute(CreateMember(memberToEdit: member)),
    );
    if (mounted) {
      context.read<NetworkMembersProvider>().loadFirstPage(widget.network.id);
    }
  }

  void _openProfile(Member member) {
    Navigator.push(
      context,
      createFadeRoute(MemberProfileScreen(member: member)),
    );
  }

  void _confirmDelete(Member member) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: member.fullName,
      onConfirm: () async {
        final success =
            await context.read<MemberProvider>().deleteMember(member.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Miembro "${member.fullName}" eliminado.'
                  : 'Error al eliminar el miembro',
            ),
            backgroundColor: success ? accentColor : negativeColor,
          ),
        );
        if (success) {
          context
              .read<NetworkMembersProvider>()
              .loadFirstPage(widget.network.id);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkMembersProvider>();

    if (provider.error == 'SIN_CONEXION') {
      return NavShell(
        isSecondary: true,
        title: widget.network.name,
        body: NoConnectionWidget(
          onRefresh: () {
            provider.clearError();
            provider.loadFirstPage(widget.network.id);
          },
        ),
      );
    }

    return NavShell(
      isSecondary: true,
      title: widget.network.name,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xl),
          BodyWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNetworkHeader(widget.network),
                const SizedBox(height: Spacing.lg),
                _buildToolbar(context, isCompact: context.isCompact),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          Expanded(
            child: BodyWidth(child: _buildTable(provider)),
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
      ),
    );
  }

  Widget _buildTable(NetworkMembersProvider provider) {
    if (provider.isLoading) {
      return const AppSkeleton.list();
    }
    if (provider.members.isEmpty) {
      return _EmptyMembers(
        hasFilters: provider.hasActiveFilters,
        onCreate: () => _openCreate(),
      );
    }
    return MemberTable(
      members: provider.members,
      showNetworkColumn: false,
      onView: _openProfile,
      onEdit: (m) => _openCreate(member: m),
      onDelete: _confirmDelete,
      onRefresh: () => provider.refresh(),
    );
  }

  // ---------------------------------------------------------------------------
  // Barra de herramientas: filtros (web visibles / móvil desplegables) + crear.
  // ---------------------------------------------------------------------------
  Widget _buildToolbar(BuildContext context, {required bool isCompact}) {
    final add = AddButton(
      size: isCompact ? const Size(double.infinity, 48) : null,
      onPressed: () => _openCreate(),
      title: 'Crear Miembro',
    );

    if (!isCompact) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildFilterFields(isCompact: false)),
          const SizedBox(width: Spacing.lg),
          add,
        ],
      );
    }

    final count = _activeFilterCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        add,
        const SizedBox(height: Spacing.md),
        OutlinedButton(
          onPressed: () =>
              setState(() => _filtersExpanded = !_filtersExpanded),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryText,
            side: const BorderSide(color: alternateColor),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.md,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.tune, size: 18, color: primaryColor),
              const SizedBox(width: Spacing.sm),
              Text(count > 0 ? 'Filtros ($count)' : 'Filtros'),
              const Spacer(),
              Icon(
                _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                color: secondaryText,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _filtersExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: Spacing.md),
            child: _buildFilterFields(isCompact: true),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterFields({required bool isCompact}) {
    final nameField = _filterField(
      controller: _nameCtrl,
      hint: 'Nombre…',
      width: isCompact ? double.infinity : 220,
    );
    final lastNameField = _filterField(
      controller: _lastNameCtrl,
      hint: 'Apellido…',
      width: isCompact ? double.infinity : 200,
    );
    final phoneField = _filterField(
      controller: _phoneCtrl,
      hint: 'Teléfono…',
      width: isCompact ? double.infinity : 180,
    );
    final estado = _buildEstadoChips();
    final clear = TextButton.icon(
      onPressed: _clearFilters,
      icon: const Icon(Icons.close, size: 18),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(foregroundColor: secondaryText),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nameField,
          const SizedBox(height: Spacing.md),
          lastNameField,
          const SizedBox(height: Spacing.md),
          phoneField,
          const SizedBox(height: Spacing.md),
          estado,
          if (_activeFilterCount > 0)
            Align(alignment: Alignment.centerLeft, child: clear),
        ],
      );
    }

    return Wrap(
      spacing: Spacing.md,
      runSpacing: Spacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        nameField,
        lastNameField,
        phoneField,
        estado,
        if (_activeFilterCount > 0) clear,
      ],
    );
  }

  Widget _filterField({
    required TextEditingController controller,
    required String hint,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: SearchTextField(
        controller: controller,
        hintText: hint,
        onChanged: (_) => _applyFilters(),
      ),
    );
  }

  Widget _buildEstadoChips() {
    Widget chip(String label, bool? value) => AppFilterChip(
          label: label,
          selected: _enabled == value,
          onSelected: (_) => _setEnabled(value),
        );

    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        chip('Todos', null),
        chip('Activos', true),
        chip('Inactivos', false),
      ],
    );
  }

  Widget _buildNetworkHeader(NetworkModel network) {
    final isMobile = context.isCompact;
    final leaders = _buildLeadersSection(network, isMobile);
    return CustomCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: leaders)
              : Row(children: leaders),
          const Divider(height: 30),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Misión de la Red:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 10),
              Text(
                network.mission ?? 'Sin misión definida',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLeadersSection(NetworkModel network, bool isMobile) {
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
                leader.name.isNotEmpty ? leader.name[0].toUpperCase() : '?',
                style: const TextStyle(color: infoColor, fontSize: 15),
              ),
            ),
            label: '${leader.name} ${leader.lastName}',
          );
        }).toList(),
      ),
    ];
  }
}

class _EmptyMembers extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onCreate;
  const _EmptyMembers({required this.hasFilters, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off, size: 72, color: secondaryText),
          const SizedBox(height: Spacing.md),
          Text(
            hasFilters
                ? 'No hay miembros que coincidan'
                : 'No hay miembros en esta red',
            style: const TextStyle(fontSize: 16, color: secondaryText),
          ),
          if (!hasFilters) ...[
            const SizedBox(height: Spacing.lg),
            AddButton(onPressed: onCreate, title: 'Crear Miembro'),
          ],
        ],
      ),
    );
  }
}
