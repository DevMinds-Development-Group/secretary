import 'package:flutter/material.dart';

class AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Size? size; // Tamaño opcional
  final Icon? icon;

  const AddButton({Key? key, required this.onPressed, this.icon, this.size})
    : super(key: key);

  @override
  State<AddButton> createState() => _ButtonState();
}

class _ButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    Size defaultSize = Size(isMobile ? 120 : 140, isMobile ? 50 : 45);
    Size buttonSize = widget.size ?? defaultSize;

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
        fixedSize: buttonSize,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(size: isMobile ? 18 : 20, Icons.add, color: Colors.white),
          SizedBox(width: 2),
          Text(
            'Añadir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
