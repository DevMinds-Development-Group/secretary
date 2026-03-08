import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? color;
  final Color? iconColor;
  final Color? borderColor;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.color,
    this.iconColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: borderColor != null
              ? BorderSide(
                  color: borderColor!,
                  width: 1.5,
                ) // Si hay color, pone borde
              : BorderSide.none, // Si es null, no pone nada
        ),
        fixedSize: Size(400, 50),

        backgroundColor: backgroundColor ?? (Colors.white),
        elevation: 3,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 20,
          vertical: isMobile ? 10 : 20,
        ),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.black,
              fontSize: isMobile ? 18 : 20,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: iconColor ?? Colors.black),
        ],
      ),
    );
  }
}
