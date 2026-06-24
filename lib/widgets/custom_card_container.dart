import 'package:flutter/material.dart';

import '../theme/design_constants.dart';

class CustomCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  /// `false` (por defecto) → nivel 0: borde hairline, sin sombra (contenedores
  /// de contenido). `true` → nivel 1: borde + sombra suave (tarjetas realzadas
  /// / interactivas, p. ej. métricas del dashboard).
  final bool raised;

  const CustomCardContainer({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.gradient,
    this.margin,
    this.borderRadius,
    this.raised = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? scheme.surface : null,
        borderRadius: borderRadius ??
            BorderRadius.circular(DesignConstants.borderRadiusCard),
        border: Border.all(
          color: scheme.outline,
          width: DesignConstants.borderWidthCard,
        ),
        boxShadow: raised ? elevationLow : null,
      ),
      child: child,
    );
  }
}
