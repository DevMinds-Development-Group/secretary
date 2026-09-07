import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/tenant_model.dart';
import '../../providers/tenant_provider.dart';
import '../../theme/design_constants.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';

/// Alta y edición de una iglesia.
///
/// Comparten formulario porque comparten campos; lo que sólo existe al dar de alta es el
/// identificador corto —inmutable después— y el usuario administrador inicial.
class ChurchFormDialog extends StatefulWidget {
  /// Nulo para dar de alta; con valor, para editar.
  final TenantModel? church;

  const ChurchFormDialog({super.key, this.church});

  bool get isEditing => church != null;

  @override
  State<ChurchFormDialog> createState() => _ChurchFormDialogState();
}

class _ChurchFormDialogState extends State<ChurchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _shortName;
  late final TextEditingController _slug;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _email;
  final _adminUsername = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final church = widget.church;
    _name = TextEditingController(text: church?.name ?? '');
    _shortName = TextEditingController(text: church?.shortName ?? '');
    _slug = TextEditingController(text: church?.slug ?? '');
    _phone = TextEditingController(text: church?.phone ?? '');
    _address = TextEditingController(text: church?.address ?? '');
    _email = TextEditingController(text: church?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _shortName.dispose();
    _slug.dispose();
    _phone.dispose();
    _address.dispose();
    _email.dispose();
    _adminUsername.dispose();
    super.dispose();
  }

  /// El identificador se propone a partir del nombre y se deja editar antes de crear. Al editar no
  /// se toca: cambiarlo rompería los enlaces existentes.
  void _suggestSlug(String name) {
    if (widget.isEditing || _slug.text.isNotEmpty) return;
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
      title: Text(widget.isEditing ? 'Editar iglesia' : 'Dar de alta una iglesia'),
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
                  // Al editar se muestra pero no se toca: cambiarlo rompería enlaces y la
                  // cabecera con la que el Ministerio consulta esta iglesia.
                  readOnly: widget.isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Obligatorio';
                    if (!RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(value.trim())) {
                      return 'Sólo minúsculas, números y guiones';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  widget.isEditing
                      ? 'No se puede cambiar: viaja en enlaces ya repartidos.'
                      : 'Viaja en enlaces y no se puede cambiar después.',
                  style: textTheme.bodySmall?.copyWith(color: secondaryText),
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _phone,
                  labelText: 'Teléfono (opcional)',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _address,
                  labelText: 'Dirección (opcional)',
                ),
                const SizedBox(height: Spacing.sm),
                CustomTextFormField(
                  controller: _email,
                  labelText: 'Correo (opcional)',
                  keyboardType: TextInputType.emailAddress,
                ),
                if (!widget.isEditing) ...[
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
                ],
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
          text: widget.isEditing ? 'Guardar' : 'Dar de alta',
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

    final Object? outcome = widget.isEditing
        ? await _saveEdit(tenants)
        : await tenants.provisionChurch(
            name: _name.text.trim(),
            shortName: _shortName.text.trim(),
            slug: _slug.text.trim(),
            adminUsername: _adminUsername.text.trim(),
            phone: _emptyToNull(_phone),
            address: _emptyToNull(_address),
            email: _emptyToNull(_email),
          );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (outcome != null && outcome != false) Navigator.of(context).pop(outcome);
  }

  Future<bool> _saveEdit(TenantProvider tenants) {
    return tenants.updateChurch(
      churchId: widget.church!.id,
      name: _name.text.trim(),
      shortName: _shortName.text.trim(),
      phone: _emptyToNull(_phone),
      address: _emptyToNull(_address),
      email: _emptyToNull(_email),
    );
  }

  String? _emptyToNull(TextEditingController controller) =>
      controller.text.trim().isEmpty ? null : controller.text.trim();
}

/// Abre el alta y devuelve las credenciales del administrador inicial, o nulo si se canceló.
Future<ChurchProvisionResult?> showChurchProvisionDialog(
  BuildContext context,
  TenantProvider tenants,
) {
  return showDialog<ChurchProvisionResult>(
    context: context,
    builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
      value: tenants,
      child: const ChurchFormDialog(),
    ),
  );
}

/// Abre la edición y devuelve si se guardó.
Future<bool> showChurchEditDialog(
  BuildContext context,
  TenantProvider tenants,
  TenantModel church,
) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider<TenantProvider>.value(
      value: tenants,
      child: ChurchFormDialog(church: church),
    ),
  );
  return saved ?? false;
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
