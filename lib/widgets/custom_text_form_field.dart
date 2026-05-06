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
    final defaultBorderColor = Colors.grey[600] ?? secondaryColor;
    final iconColor = secondaryColor.withOpacity(0.7);

    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      filled: true,
      fillColor: Colors.white,
      prefixText: widget.prefixText,
      labelStyle: TextStyle(color: secondaryColor.withOpacity(0.9)),
      hintStyle: TextStyle(color: secondaryColor.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: defaultBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: primaryColor2, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: BorderSide(color: primaryColor2, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 12.0,
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
