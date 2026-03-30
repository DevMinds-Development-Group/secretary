import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String hintText;

  const SearchTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.validator,
    this.hintText = 'Buscar...',
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
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
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: isMobile ? 50 : 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 1,
            //offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _internalController,
        validator: widget.validator,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 18),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 25),
          suffixIcon: _internalController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _internalController.clear();
                    if (widget.onChanged != null) widget.onChanged!("");
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }
}
