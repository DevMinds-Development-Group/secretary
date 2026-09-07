import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tenant_model.dart';
import '../../providers/tenant_provider.dart';
import '../../widgets/add_button.dart';

/// Administración de iglesias. Es una pantalla del Ministerio: una iglesia no
/// administra a las demás, y el servidor lo rechaza con 403 aunque se llegue aquí.
class ChurchesScreen extends StatefulWidget {
  const ChurchesScreen({super.key});

  @override
  State<ChurchesScreen> createState() => _ChurchesScreenState();
}

class _ChurchesScreenState extends State<ChurchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TenantProvider>().fetchChurches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();

    if (!tenants.isMinistry) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Sólo el Ministerio administra las iglesias.'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Iglesias', style: Theme.of(context).textTheme.titleLarge),
              // El alta de iglesias es administración de plataforma, no dato de
              // congregación, así que el Ministerio sí puede.
              ElevatedButton.icon(
                onPressed: () => _openProvisionDialog(context, tenants),
                icon: const Icon(Icons.add),
                label: const Text('Dar de alta'),
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tenants.isLoading) const LinearProgressIndicator(),
          if (tenants.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(tenants.error!, style: TextStyle(color: negativeColor)),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: tenants.churches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) => _churchTile(context, tenants, tenants.churches[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _churchTile(BuildContext context, TenantProvider tenants, TenantModel church) {
    return ListTile(
      leading: Icon(
        Icons.church_outlined,
        color: church.enabled ? primaryColor : Colors.grey,
      ),
      title: Text(church.name),
      subtitle: Text([
        church.slug,
        if (church.phone != null && church.phone!.isNotEmpty) church.phone!,
        if (!church.enabled) 'deshabilitada',
      ].join(' · ')),
      trailing: Switch(
        value: church.enabled,
        onChanged: (enabled) => _confirmStatusChange(context, tenants, church, enabled),
      ),
    );
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
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
            'Sus usuarios dejarán de poder entrar. Su histórico se conserva y '
            'sigue contando en los informes del Ministerio.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Deshabilitar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await tenants.updateStatus(church.id, enabled);
  }

  Future<void> _openProvisionDialog(BuildContext context, TenantProvider tenants) async {
    final result = await showDialog<ChurchProvisionResult>(
      context: context,
      builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
        value: tenants,
        child: const _ProvisionChurchDialog(),
      ),
    );
    if (result != null && context.mounted) {
      await _showCredentialDialog(context, result);
    }
  }

  /// La contraseña sólo se muestra aquí: no se guarda en claro en ningún sitio y
  /// el servidor no la puede volver a enseñar.
  Future<void> _showCredentialDialog(BuildContext context, ChurchProvisionResult result) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('${result.church.name} dada de alta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copia estas credenciales ahora: la contraseña no se puede volver a ver.'),
            const SizedBox(height: 16),
            SelectableText('Usuario: ${result.adminUsername}'),
            SelectableText('Contraseña: ${result.oneTimePassword}'),
            const SizedBox(height: 12),
            const Text(
              'Quien la reciba debe cambiarla al entrar.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ya la he copiado'),
          ),
        ],
      ),
    );
  }
}

class _ProvisionChurchDialog extends StatefulWidget {
  const _ProvisionChurchDialog();

  @override
  State<_ProvisionChurchDialog> createState() => _ProvisionChurchDialogState();
}

class _ProvisionChurchDialogState extends State<_ProvisionChurchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _shortName = TextEditingController();
  final _slug = TextEditingController();
  final _adminUsername = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _shortName.dispose();
    _slug.dispose();
    _adminUsername.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// El slug viaja en cabeceras y URLs y no se puede cambiar después, así que se
  /// propone a partir del nombre y se deja editar antes de crear.
  void _suggestSlug(String name) {
    if (_slug.text.isNotEmpty) return;
    final suggestion = name
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    _slug.text = suggestion;
  }

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    return AlertDialog(
      title: const Text('Dar de alta una iglesia'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre de la iglesia'),
                  onChanged: _suggestSlug,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                TextFormField(
                  controller: _shortName,
                  decoration: const InputDecoration(
                    labelText: 'Nombre corto',
                    helperText: 'El que se ve en la barra superior y en el selector',
                  ),
                ),
                TextFormField(
                  controller: _slug,
                  decoration: const InputDecoration(
                    labelText: 'Identificador corto',
                    helperText: 'Minúsculas, números y guiones. No se puede cambiar después',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Obligatorio';
                    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(value.trim())) {
                      return 'Sólo minúsculas, números y guiones';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _adminUsername,
                  decoration: const InputDecoration(
                    labelText: 'Usuario administrador inicial',
                    helperText: 'Único entre todas las iglesias. A partir de él, la iglesia gestiona los suyos',
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                if (tenants.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(tenants.error!, style: TextStyle(color: negativeColor)),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : () => _submit(context, tenants),
          child: Text(_submitting ? 'Creando…' : 'Dar de alta'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, TenantProvider tenants) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final result = await tenants.provisionChurch(
      name: _name.text.trim(),
      shortName: _shortName.text.trim(),
      slug: _slug.text.trim(),
      adminUsername: _adminUsername.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );
    if (!context.mounted) return;
    setState(() => _submitting = false);
    if (result != null) Navigator.of(context).pop(result);
  }
}
