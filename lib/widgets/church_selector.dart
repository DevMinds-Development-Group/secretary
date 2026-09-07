import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tenant_provider.dart';
import 'package:Koinos/colors.dart';

/// Selector de iglesia de la barra superior. Sólo aparece para el Ministerio:
/// una iglesia se ve siempre a sí misma y no tiene nada que elegir.
///
/// «Consolidado» es una opción explícita y no la ausencia de selección, para que
/// se vea en todo momento qué se está mirando.
class ChurchSelector extends StatelessWidget {
  const ChurchSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    if (!tenants.isMinistry) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton.icon(
        onPressed: () => _openPicker(context, tenants),
        icon: Icon(
          tenants.isConsolidatedView ? Icons.account_balance_outlined : Icons.church_outlined,
          size: 18,
          color: primaryColor,
        ),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            tenants.scopeLabel,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, TenantProvider tenants) async {
    if (tenants.churches.isEmpty) {
      await tenants.fetchChurches();
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
        value: tenants,
        child: const _ChurchPickerDialog(),
      ),
    );
  }
}

class _ChurchPickerDialog extends StatefulWidget {
  const _ChurchPickerDialog();

  @override
  State<_ChurchPickerDialog> createState() => _ChurchPickerDialogState();
}

class _ChurchPickerDialogState extends State<_ChurchPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    final needle = _query.trim().toLowerCase();
    final visible = tenants.churches
        .where((church) =>
            needle.isEmpty ||
            church.name.toLowerCase().contains(needle) ||
            church.slug.toLowerCase().contains(needle))
        .toList();

    return AlertDialog(
      title: const Text('Ver como'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Con más de diez iglesias un desplegable largo deja de servir.
            if (tenants.churches.length > 8)
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar iglesia',
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: const Text('Consolidado'),
                    subtitle: const Text('Todas las iglesias juntas'),
                    selected: tenants.isConsolidatedView,
                    onTap: () => _select(context, tenants, null),
                  ),
                  const Divider(height: 1),
                  if (tenants.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ...visible.map(
                    (church) => ListTile(
                      leading: const Icon(Icons.church_outlined),
                      title: Text(church.displayName),
                      subtitle: Text(church.enabled ? church.slug : '${church.slug} · deshabilitada'),
                      selected: tenants.selectedChurchId == church.id,
                      onTap: () => _select(context, tenants, church.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _select(BuildContext context, TenantProvider tenants, String? churchId) async {
    await tenants.selectChurch(churchId);
    if (context.mounted) Navigator.of(context).pop();
  }
}
