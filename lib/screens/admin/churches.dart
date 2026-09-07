import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/tenant_model.dart';
import '../../providers/tenant_provider.dart';
import '../../theme/design_constants.dart';
import '../../utils/window_size.dart';
import '../../widgets/body_width.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_card_container.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/search_text_field.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../../widgets/status_pill.dart';
import 'church_provision_dialog.dart';

/// Administración de iglesias. Es una pantalla del Ministerio: una iglesia no administra a las
/// demás, y el servidor lo rechaza con 403 aunque se llegue hasta aquí.
class ChurchesScreen extends StatefulWidget {
  const ChurchesScreen({super.key});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenantProvider>().fetchChurches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final tenants = context.watch<TenantProvider>();

    return NavShell(
      current: NavSection.admin,
      title: 'Iglesias',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xl),
          BodyWidth(child: _buildHeader(isCompact, tenants)),
          const SizedBox(height: Spacing.lg),
          Expanded(child: BodyWidth(child: _buildList(tenants))),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isCompact, TenantProvider tenants) {
    final textTheme = Theme.of(context).textTheme;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Iglesias', style: textTheme.headlineMedium),
        const SizedBox(height: Spacing.xxs),
        Text(
          'Congregaciones del ministerio y sus administradores.',
          style: textTheme.bodyMedium?.copyWith(color: secondaryText),
        ),
      ],
    );

    // El alta de iglesias es administración de plataforma, no dato de congregación, así que el
    // Ministerio sí puede: por eso va con Button y no con AddButton, que se oculta en modo consulta.
    final provisionButton = Button(
      text: 'Dar de alta',
      icon: Icons.add_business_rounded,
      size: isCompact ? const Size(double.infinity, 48) : const Size(220, 48),
      onPressed: () => _openProvisionDialog(tenants),
    );

    final search = SearchTextField(
      hintText: 'Buscar por nombre o identificador',
      onChanged: (value) => setState(() => _query = value),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading,
        const SizedBox(height: Spacing.lg),
        if (isCompact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              provisionButton,
              const SizedBox(height: Spacing.md),
              search,
            ],
          )
        else
          Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: Spacing.md),
              provisionButton,
            ],
          ),
      ],
    );
  }

  Widget _buildList(TenantProvider tenants) {
    if (tenants.isLoading && tenants.churches.isEmpty) {
      return const AppSkeleton.list();
    }
    if (tenants.error != null && tenants.churches.isEmpty) {
      return ErrorState(
        error: tenants.error,
        onRetry: () => tenants.fetchChurches(),
      );
    }

    final visible = _visibleChurches(tenants.churches);
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.church_outlined,
        title: _query.isEmpty ? 'Todavía no hay iglesias' : 'Ninguna coincide',
        message: _query.isEmpty
            ? 'Da de alta la primera congregación del ministerio.'
            : 'Prueba con otro nombre o identificador.',
        action: _query.isEmpty
            ? Button(
                text: 'Dar de alta',
                icon: Icons.add_business_rounded,
                size: const Size(220, 48),
                onPressed: () => _openProvisionDialog(tenants),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => tenants.fetchChurches(),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
        itemBuilder: (_, index) => _ChurchCard(
          church: visible[index],
          onStatusChanged: (enabled) => _confirmStatusChange(tenants, visible[index], enabled),
        ),
      ),
    );
  }

  List<TenantModel> _visibleChurches(List<TenantModel> churches) {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return churches;
    return churches
        .where((church) =>
            church.name.toLowerCase().contains(needle) ||
            church.slug.toLowerCase().contains(needle))
        .toList();
  }

  Future<void> _confirmStatusChange(
    TenantProvider tenants,
    TenantModel church,
    bool enabled,
  ) async {
    if (!enabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Deshabilitar ${church.displayName}'),
          content: const Text(
            'Sus usuarios dejarán de poder entrar. Su histórico se conserva y sigue contando '
            'en los informes del Ministerio.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('Deshabilitar', style: TextStyle(color: negativeColor)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await tenants.updateStatus(church.id, enabled);
  }

  Future<void> _openProvisionDialog(TenantProvider tenants) async {
    final result = await showDialog<ChurchProvisionResult>(
      context: context,
      builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
        value: tenants,
        child: const ChurchProvisionDialog(),
      ),
    );
    if (result != null && mounted) {
      await showChurchCredentialDialog(context, result);
    }
  }
}

/// Ficha de una iglesia, con el mismo lenguaje visual que las tarjetas de asistencia.
class _ChurchCard extends StatelessWidget {
  final TenantModel church;
  final ValueChanged<bool> onStatusChanged;

  const _ChurchCard({required this.church, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomCardContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: church.enabled
                ? primaryColor.withValues(alpha: 0.12)
                : secondaryText.withValues(alpha: 0.12),
            child: Icon(
              Icons.church_rounded,
              color: church.enabled ? primaryColor : secondaryText,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(church.name, style: textTheme.titleMedium),
                const SizedBox(height: Spacing.xxs),
                Text(
                  [
                    church.slug,
                    if (church.phone != null && church.phone!.isNotEmpty) church.phone!,
                  ].join(' · '),
                  style: textTheme.bodySmall?.copyWith(color: secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          church.enabled ? StatusPill.active() : StatusPill.inactive('Deshabilitada'),
          Switch(
            value: church.enabled,
            onChanged: onStatusChanged,
          ),
        ],
      ),
    );
  }
}
