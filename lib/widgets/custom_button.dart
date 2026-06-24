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
    final scheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null
              ? BorderSide(
                  color: borderColor!,
                  width: 2,
                ) // Si hay color, pone borde
              : BorderSide(color: scheme.outline, width: 2),
        ),
        // Ancho completo en móvil; en escritorio un mínimo cómodo (sin el
        // antiguo lock de 400px que rompía en pantallas pequeñas).
        minimumSize: Size(isMobile ? double.infinity : 280, 48),

        backgroundColor: backgroundColor ?? scheme.surface,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 20,
          vertical: isMobile ? 10 : 20,
        ),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color ?? scheme.onSurface,
              fontSize: isMobile ? 18 : 20,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: iconColor ?? scheme.onSurface),
        ],
      ),
    );
  }
}
