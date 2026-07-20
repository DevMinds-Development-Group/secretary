import 'dart:ui';

import 'package:flutter/material.dart';

/// Decoración "glass" fluida reutilizable (blanco semiopaco + borde claro +
/// sombra suave grande). Compartida por las pantallas de estética fluida.
BoxDecoration glassDecoration(BorderRadius radius) {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: radius,
    border: Border.all(color: Colors.white.withOpacity(0.6)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 40,
        spreadRadius: -10,
        offset: const Offset(0, 20),
      ),
    ],
  );
}

/// Fondo fluido a pantalla completa: gradiente base suave + patrón de puntos
/// opcional + dos blobs difuminados estáticos, con [child] encima.
class FluidBackground extends StatelessWidget {
  final Widget child;
  final bool showDots;

  const FluidBackground({
    super.key,
    required this.child,
    this.showDots = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF4FB), Color(0xFFF3F4F6)],
              ),
            ),
          ),
        ),
        if (showDots)
          Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _DotsPainter())),
          ),
        _blob(const Alignment(-1.1, -1.2), 460, const Color(0xFFC2DCFC)),
        _blob(const Alignment(1.3, 1.2), 560, const Color(0xFFE0E7FF)),
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _blob(Alignment alignment, double size, Color color) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  static const double _gap = 24;
  static const double _radius = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE5E7EB);
    for (double y = 0; y < size.height; y += _gap) {
      for (double x = 0; x < size.width; x += _gap) {
        canvas.drawCircle(Offset(x, y), _radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
