// lib/widgets/custom_text_form_field.dart

import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final Size? size;

  /// Muestra un indicador `*` junto a la etiqueta (campo obligatorio).
  /// Es solo visual: la regla real la define `validator`.
  final bool isRequired;

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.initialValue,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.prefixText,
    this.size,
    this.isRequired = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isCurrentlyObscured;

  @override
  void initState() {
    super.initState();
    _isCurrentlyObscured = widget.obscureText;
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    Widget? effectiveSuffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final defaultBorderColor = scheme.outline; // Alternate
    final iconColor = secondaryText;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      label: widget.isRequired
          ? Text.rich(
              TextSpan(
                text: widget.labelText,
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: errorColor),
                  ),
                ],
              ),
              style: TextStyle(color: iconColor),
            )
          : null,
      labelText: widget.isRequired ? null : widget.labelText,
      hintText: widget.hintText,
      filled: true,
      fillColor: scheme.surface,
      prefixText: widget.prefixText,
      labelStyle: TextStyle(color: iconColor),
      hintStyle: TextStyle(color: iconColor),
      border: border(defaultBorderColor, 2.0),
      enabledBorder: border(defaultBorderColor, 1.0),
      focusedBorder: border(primaryColor, 2.0),
      errorBorder: border(errorColor, 2.0),
      focusedErrorBorder: border(errorColor, 2.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 16.0,
      ),
      // Controla altura implícita
      prefixIcon: widget.prefixIcon,
      prefixIconColor: iconColor,
      suffixIcon: effectiveSuffixIcon,
      suffixIconColor: iconColor,
      alignLabelWithHint: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? finalSuffixIcon = widget.suffixIcon;
    if (widget.obscureText) {
      finalSuffixIcon = IconButton(
        icon: Icon(
          _isCurrentlyObscured ? Icons.visibility_off : Icons.visibility,
        ),
        tooltip: _isCurrentlyObscured
            ? 'Mostrar ${widget.labelText}'
            : 'Ocultar ${widget.labelText}',
        onPressed: () {
          setState(() {
            _isCurrentlyObscured = !_isCurrentlyObscured;
          });
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      decoration: _buildInputDecoration(
        context,
        effectiveSuffixIcon: finalSuffixIcon,
      ),
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _isCurrentlyObscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      inputFormatters: widget.inputFormatters,
    );
  }
}
