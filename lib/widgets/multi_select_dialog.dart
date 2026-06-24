// lib/widgets/multi_select_dialog.dart

import 'package:flutter/material.dart';

import 'button.dart';

class MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final Set<T> initialSelectedItems;
  final String Function(T) displayItem;
  final String title;

  const MultiSelectDialog({
    Key? key,
    required this.items,
    required this.initialSelectedItems,
    required this.displayItem,
    this.title = 'Seleccionar Opciones',
  }) : super(key: key);

  @override
  _MultiSelectDialogState<T> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  late Set<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialSelectedItems;
  }

  void _onItemCheckedChange(T item, bool checked) {
    setState(() {
      if (checked) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: _selectedItems.contains(item),
              title: Text(widget.displayItem(item)),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (checked) => _onItemCheckedChange(item, checked!),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: _onCancelTap, child: const Text('Cancelar')),
        Button(text: 'Aceptar', onPressed: _onSubmitTap, size: Size(120, 40)),
      ],
    );
  }
}
