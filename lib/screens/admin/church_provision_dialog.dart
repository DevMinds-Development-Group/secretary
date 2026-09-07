import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/tenant_model.dart';
import '../../providers/tenant_provider.dart';
import '../../theme/design_constants.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';

/// Alta de una iglesia con su administrador inicial, en una sola operación.
class ChurchProvisionDialog extends StatefulWidget {
  const ChurchProvisionDialog({super.key});

  @override
  State<ChurchProvisionDialog> createState() => _ChurchProvisionDialogState();
}

class _ChurchProvisionDialogState extends State<ChurchProvisionDialog> {
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

  /// El identificador viaja en cabeceras y URLs y no se puede cambiar después, así que se propone
  /// a partir del nombre y se deja editar antes de crear.
  void _suggestSlug(String name) {
    if (_slug.text.isNotEmpty) return;
    _slug.text = name
        .toLowerCase()
        .replaceAll(RegExp(r'[áàä]'), 'a')
        .replaceAll(RegExp(r'[éèë]'), 'e')
        .replaceAll(RegExp(r'[íìï]'), 'i')
        .replaceAll(RegExp(r'[óòö]'), 'o')
        .replaceAll(RegExp(r'[úùü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final tenants = context.watch<TenantProvider>();
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Dar de alta una iglesia'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  controller: _name,
                  labelText: 'Nombre de la iglesia',
                  onChanged: _suggestSlug,
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _shortName,
                  labelText: 'Nombre corto',
                  hintText: 'El que se ve en la barra superior y en el selector',
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _slug,
                  labelText: 'Identificador corto',
                  hintText: 'Minúsculas, números y guiones. No se puede cambiar después',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Obligatorio';
                    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(value.trim())) {
                      return 'Sólo minúsculas, números y guiones';
                    }
                    return null;
                  },
                ),
                // El aviso va debajo y siempre visible: el identificador no se puede cambiar
                // después, así que no basta con un texto que desaparece al escribir.
                const SizedBox(height: Spacing.xxs),
                Text(
                  'Viaja en enlaces y no se puede cambiar después.',
                  style: textTheme.bodySmall?.copyWith(color: secondaryText),
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _phone,
                  labelText: 'Teléfono (opcional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: Spacing.lg),
                Text('Administrador inicial', style: textTheme.titleSmall),
                const SizedBox(height: Spacing.xxs),
                Text(
                  'A partir de él, la iglesia gestiona sus propios usuarios.',
                  style: textTheme.bodySmall?.copyWith(color: secondaryText),
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _adminUsername,
                  labelText: 'Usuario administrador',
                  hintText: 'Único entre todas las iglesias',
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null,
                ),
                if (tenants.error != null) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    tenants.error!,
                    style: textTheme.bodySmall?.copyWith(color: negativeColor),
                  ),
                ],
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
        Button(
          text: 'Dar de alta',
          isLoading: _submitting,
          size: const Size(160, 44),
          onPressed: _submitting ? () {} : () => _submit(tenants),
        ),
      ],
    );
  }

  Future<void> _submit(TenantProvider tenants) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final result = await tenants.provisionChurch(
      name: _name.text.trim(),
      shortName: _shortName.text.trim(),
      slug: _slug.text.trim(),
      adminUsername: _adminUsername.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result != null) Navigator.of(context).pop(result);
  }
}

/// La contraseña sólo se muestra aquí: no se guarda en claro en ningún sitio y el servidor no la
/// puede volver a enseñar.
Future<void> showChurchCredentialDialog(
  BuildContext context,
  ChurchProvisionResult result,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final textTheme = Theme.of(dialogContext).textTheme;
      return AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: accentColor, size: 40),
        title: Text('${result.church.name} dada de alta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copia estas credenciales ahora: la contraseña no se puede volver a ver.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: Spacing.lg),
            _CredentialRow(label: 'Usuario', value: result.adminUsername),
            const SizedBox(height: Spacing.sm),
            _CredentialRow(label: 'Contraseña', value: result.oneTimePassword),
            const SizedBox(height: Spacing.md),
            Text(
              'Quien la reciba debe cambiarla al entrar.',
              style: textTheme.bodySmall?.copyWith(
                color: secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          Button(
            text: 'Ya la he copiado',
            size: const Size(200, 44),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      );
    },
  );
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: secondaryText),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
