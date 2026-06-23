import 'dart:async';

import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';

class SearchTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String hintText;

  /// Retardo antes de propagar `onChanged` (evita filtrar/consultar en cada
  /// pulsación). Se aplica solo al teclear; el botón "limpiar" es inmediato.
  final Duration debounce;

  const SearchTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.validator,
    this.hintText = 'Buscar...',
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _internalController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onChangedDebounced(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final scheme = Theme.of(context).colorScheme;
    final hintIconColor = secondaryText;

    return Container(
      height: isMobile ? 50 : 45,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusInput),
        border: Border.all(
          color: scheme.outline,
          width: DesignConstants.borderWidthCard,
        ),
      ),
      child: TextFormField(
        controller: _internalController,
        validator: widget.validator,
        onChanged: _onChangedDebounced,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: hintIconColor, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: hintIconColor, size: 25),
          suffixIcon: _internalController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: hintIconColor),
                  onPressed: () {
                    _debounceTimer?.cancel();
                    _internalController.clear();
                    widget.onChanged?.call("");
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        style: TextStyle(color: scheme.onSurface, fontSize: 16),
      ),
    );
  }
}
