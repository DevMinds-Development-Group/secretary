import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tenant_provider.dart';
import '../utils/window_size.dart';
import 'package:Koinos/colors.dart';

/// Selector de iglesia de la barra superior. Sólo aparece para el Ministerio:
/// una iglesia se ve siempre a sí misma y no tiene nada que elegir.
///
/// «Consolidado» es una opción explícita y no la ausencia de selección, para que
/// se vea en todo momento qué se está mirando.
class ChurchSelector extends StatefulWidget {
  /// Lo que ocupa todo lo demás de la barra en móvil: el logotipo (116), el menú de usuario (80),
  /// el icono y los márgenes de este botón (42) y un respiro (12).
  static const double _chromeWidth = 250;

  const ChurchSelector({super.key});

  @override
  State<ChurchSelector> createState() => _ChurchSelectorState();
}

class _ChurchSelectorState extends State<ChurchSelector> {
  @override
  void initState() {
    super.initState();
    // Al recargar, el alcance se restaura del almacenamiento pero los nombres no vienen con él: sin
    // esto la barra decía «Consolidado» mientras la aplicación miraba de verdad una iglesia.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tenants = context.read<TenantProvider>();
      if (tenants.isMinistry && tenants.churches.isEmpty) tenants.fetchChurches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    if (!tenants.isMinistry) return const SizedBox.shrink();

    // La barra la comparten el logotipo, este selector y el menú de usuario. En móvil no caben los
    // tres a su gusto, así que el nombre se queda con lo que sobra y se recorta: con un ancho fijo
    // el botón crecía hasta montarse encima del logotipo.
    final compact = context.isCompact;
    final maxLabel = compact
        ? (MediaQuery.sizeOf(context).width - ChurchSelector._chromeWidth).clamp(48.0, 180.0)
        : 180.0;

    return Padding(
      padding: EdgeInsets.only(right: compact ? 0 : 8),
      child: TextButton.icon(
        onPressed: () => _openPicker(context, tenants),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
          minimumSize: const Size(0, 40),
        ),
        icon: Icon(
          tenants.isConsolidatedView ? Icons.account_balance_outlined : Icons.church_outlined,
          size: 18,
          color: primaryColor,
        ),
        label: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxLabel),
          child: Text(
            tenants.scopeLabel,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// El diálogo sólo devuelve la elección; el alcance se cambia cuando ya no está en pantalla.
  ///
  /// Cambiarlo es destruir la pantalla entera —`TenantScopedPage` cambia su clave y el subárbol se
  /// deshace—, y hacerlo con el diálogo todavía montado dejaba nodos de foco apuntando a elementos
  /// muertos: el diálogo cuelga del ámbito de foco de la página que se está destruyendo. El
  /// framework lo caza con la pantalla roja de «_dependents.isEmpty».
  Future<void> _openPicker(BuildContext context, TenantProvider tenants) async {
    if (tenants.churches.isEmpty) {
      await tenants.fetchChurches();
    }
    if (!context.mounted) return;
    final choice = await showDialog<_ScopeChoice>(
      context: context,
      builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
        value: tenants,
        child: const _ChurchPickerDialog(),
      ),
    );
    if (choice != null) await tenants.selectChurch(choice.churchId);
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
                    onTap: () => _select(context, null),
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
                      onTap: () => _select(context, church.id),
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

  /// Primero se cierra el diálogo y sólo después se cambia el alcance.
  ///
  /// Cambiarlo es destruir la pantalla entera: `TenantScopedPage` cambia su clave y el subárbol se
  /// deshace. Hacerlo con el diálogo todavía en pantalla dejaba nodos de foco apuntando a elementos
  /// ya muertos —el diálogo cuelga del ámbito de foco de la página que se está destruyendo— y el
  /// framework lo caza con la pantalla roja de «_dependents.isEmpty».
  ///
  /// Se suelta el foco antes por lo mismo: un campo enfocado en la pantalla que va a desaparecer.
  void _select(BuildContext context, String? churchId) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(_ScopeChoice(churchId));
  }
}

/// Lo que el diálogo devuelve. Es una clase y no un `String?` porque nulo ya significa
/// «consolidado», y hay que poder distinguirlo de cerrar sin elegir.
class _ScopeChoice {
  final String? churchId;

  const _ScopeChoice(this.churchId);
}
