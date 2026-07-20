import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../models/member_filters.dart';
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
import 'member_profile.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;

  /// null = todos, true = activos, false = inactivos.
  bool? _enabled;

  /// Panel de filtros desplegable (solo móvil).
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    // Sembramos los campos desde los filtros persistidos en el provider.
    final f = context.read<MemberProvider>().filters;
    _nameCtrl = TextEditingController(text: f.name);
    _lastNameCtrl = TextEditingController(text: f.lastName);
    _phoneCtrl = TextEditingController(text: f.phone);
    _enabled = f.enabled;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Recarga fresca desde página 0 conservando los filtros vigentes.
      context.read<MemberProvider>().loadFirstPage();
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
    context.read<MemberProvider>().applyFilters(_currentFilters());
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
    context.read<MemberProvider>().clearFilters();
  }

  int get _activeFilterCount {
    var count = 0;
    if (_nameCtrl.text.trim().isNotEmpty) count++;
    if (_lastNameCtrl.text.trim().isNotEmpty) count++;
    if (_phoneCtrl.text.trim().isNotEmpty) count++;
    if (_enabled != null) count++;
    return count;
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

  void _openProfile(Member member) {
    Navigator.push(
      context,
      createFadeRoute(MemberProfileScreen(member: member)),
    );
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
          onRetry: () => memberProvider.loadFirstPage(),
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
                _buildToolbar(context, provider, isCompact),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.md),
        Expanded(
          child: BodyWidth(
            child: _buildTable(context, provider, provider.members),
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

  // ---------------------------------------------------------------------------
  // Barra de herramientas: filtros (visibles en web / desplegables en móvil) +
  // botón de crear.
  // ---------------------------------------------------------------------------
  Widget _buildToolbar(
    BuildContext context,
    MemberProvider provider,
    bool isCompact,
  ) {
    final add = AddButton(
      size: isCompact ? const Size(double.infinity, 48) : null,
      onPressed: () => _openCreate(),
    );

    if (!isCompact) {
      // Web: todos los filtros visibles + botón crear a la derecha.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildFilterFields(isCompact: false)),
          const SizedBox(width: Spacing.lg),
          add,
        ],
      );
    }

    // Móvil: botón crear + toggle "Filtros" que despliega el panel.
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
    final clear = _buildClearButton();

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

  Widget _buildClearButton() {
    return TextButton.icon(
      onPressed: _clearFilters,
      icon: const Icon(Icons.close, size: 18),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(foregroundColor: secondaryText),
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
        message: provider.hasActiveFilters
            ? 'Ajusta o limpia los filtros.'
            : 'Agrega un miembro para empezar.',
        action: provider.hasActiveFilters
            ? null
            : AddButton(onPressed: () => _openCreate()),
      );
    }

    return MemberTable(
      members: members,
      showNetworkColumn: true,
      onView: _openProfile,
      onEdit: (m) => _openCreate(member: m),
      onDelete: (m) => _showDelete(context, m),
      onRefresh: () => provider.fetchMembers(),
    );
  }
}
