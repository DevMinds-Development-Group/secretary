import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor; // Opcional por si quieres forzar un color

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Detectamos si es móvil dentro del widget para que sea responsivo automáticamente
    bool isMobile = MediaQuery.of(context).size.width < 700;

    // Definimos el color primario (puedes importarlo de tu archivo de constantes si prefieres)
    Color primaryColor = Theme.of(context).primaryColor;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 200 : 210, isMobile ? 60 : 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // Si pasas un color por parámetro lo usa, si no, usa la lógica original
        backgroundColor:
            backgroundColor ?? (isMobile ? primaryColor : Colors.white),
        elevation: 5,
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
            style: TextStyle(color: isMobile ? Colors.white : Colors.black),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: isMobile ? Colors.white : Colors.black),
        ],
      ),
    );
  }
}
