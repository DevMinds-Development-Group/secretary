import 'package:flutter/material.dart';

import '../colors.dart';

/// Fondo azul de marca con "blobs"/burbujas translúcidas (motivo de la
/// referencia, con nuestro color primario). Sin dependencia de assets.
class BlobBackground extends StatelessWidget {
  final Widget? child;
  const BlobBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _BlobPainter())),
        // Marca de agua del logo, apenas perceptible.
        Positioned.fill(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: Opacity(
                opacity: 0.06,
                child: Image.asset('assets/logo1.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Fondo: degradado azul más suave (más claro / con aire) hacia el primario.
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5AA0FF), primaryColor],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final w = size.width;
    final h = size.height;

    // Blob grande superior (más blanco).
    final lighter = Paint()..color = Colors.white.withOpacity(0.16);
    canvas.drawCircle(Offset(w * 0.78, h * 0.16), w * 0.42, lighter);

    // Blob inferior izquierdo.
    final darker = Paint()..color = Colors.white.withOpacity(0.10);
    canvas.drawCircle(Offset(w * 0.10, h * 0.72), w * 0.40, darker);

    // Burbujas pequeñas.
    final bubble = Paint()..color = Colors.white.withOpacity(0.16);
    canvas.drawCircle(Offset(w * 0.30, h * 0.20), w * 0.07, bubble);
    canvas.drawCircle(Offset(w * 0.62, h * 0.40), w * 0.05, bubble);
    canvas.drawCircle(Offset(w * 0.85, h * 0.62), w * 0.09, bubble);
    canvas.drawCircle(Offset(w * 0.20, h * 0.50), w * 0.035, bubble);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Recorta el borde inferior con una onda suave (divisor azul→blanco en móvil).
class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 24,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height - 52,
      size.width,
      size.height - 16,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Marca: badge blanco con el logo + nombre + tagline (texto blanco sobre azul).
class BrandLockup extends StatelessWidget {
  final bool compact;
  const BrandLockup({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badge = compact ? 100.0 : 150.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: badge,
          height: badge,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/logo_koinos_full.png', fit: BoxFit.contain),
        ),
        SizedBox(height: compact ? 16 : 24),
        Text(
          'Koinos',
          textAlign: TextAlign.center,
          style: (compact ? textTheme.headlineSmall : textTheme.displaySmall)
              ?.copyWith(color: infoColor, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Administración eclesiástica integral',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: infoColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Pie de página con el crédito de desarrollo. [color] se ajusta según el
/// fondo (claro sobre azul, atenuado sobre blanco).
class AuthFooter extends StatelessWidget {
  final Color color;
  const AuthFooter({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        'Desarrollado para el Ministerio Apostólico y Profético '
        'Viento Recio Internacional. Por Duox Software.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, height: 1.4),
      ),
    );
  }
}
