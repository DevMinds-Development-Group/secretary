import 'package:flutter/material.dart';

import 'custom_card_container.dart';

class SearchTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  SearchTextField({super.key, this.onChanged, this.controller, this.validator});

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();

    _internalController.addListener(() {
      widget.onChanged?.call(_internalController.text);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return SizedBox(
      height: isMobile ? 50 : 45,
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width * 0.2,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: CustomCardContainer(
          child: TextField(
            controller: _internalController,
            decoration: InputDecoration(
              hintText: 'Buscar',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
