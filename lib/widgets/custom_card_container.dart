import 'package:flutter/material.dart';

class CustomCardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const CustomCardContainer({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.gradient,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5),
        ],
      ),
      child: child,
    );
  }
}
