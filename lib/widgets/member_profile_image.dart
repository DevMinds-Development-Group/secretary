// lib/widgets/member_profile_image.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../colors.dart';

class MemberProfileImage extends StatelessWidget {
  final String? imageUrl;
  final File? localFile;
  final String? name;
  final double radius;
  final String defaultAsset;

  /// Si es `true`, se dibuja como cuadrado redondeado (con borde opcional) en
  /// lugar de círculo — usado en las listas de miembros.
  final bool squared;
  final Color? borderColor;
  final double borderWidth;

  const MemberProfileImage({
    Key? key,
    this.imageUrl,
    this.localFile,
    this.name,
    this.radius = 50.0,
    this.defaultAsset = 'assets/02.png',
    this.squared = false,
    this.borderColor,
    this.borderWidth = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasLocal = localFile != null;
    final hasRemote = imageUrl != null && imageUrl!.isNotEmpty;
    final provider = _getImageProvider(hasLocal, hasRemote);

    final semanticsLabel = (name != null && name!.trim().isNotEmpty)
        ? 'Foto de perfil de $name'
        : 'Foto de perfil';

    if (!squared) {
      return Semantics(
        image: true,
        label: semanticsLabel,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: primaryColor.withOpacity(0.1),
          onBackgroundImageError: hasRemote ? _onImageError : null,
          backgroundImage: provider,
          child: (!hasLocal && !hasRemote)
              ? Icon(
                  Icons.person,
                  size: radius,
                  color: primaryColor.withOpacity(0.5),
                )
              : null,
        ),
      );
    }

    // Variante cuadrada redondeada con borde.
    final side = radius * 2;
    final radiusGeom = BorderRadius.circular(radius * 0.5);
    return Semantics(
      image: true,
      label: semanticsLabel,
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: radiusGeom,
          border: borderWidth > 0
              ? Border.all(
                  color: borderColor ?? primaryColor,
                  width: borderWidth,
                )
              : null,
          image: provider != null
              ? DecorationImage(
                  image: provider,
                  fit: BoxFit.cover,
                  onError: hasRemote ? _onImageError : null,
                )
              : null,
        ),
        child: provider == null
            ? Icon(
                Icons.person,
                size: radius,
                color: primaryColor.withOpacity(0.5),
              )
            : null,
      ),
    );
  }

  void _onImageError(Object exception, StackTrace? stackTrace) {
    debugPrint("Error cargando imagen: $exception");
  }

  ImageProvider? _getImageProvider(bool hasLocal, bool hasRemote) {
    if (hasLocal) {
      return FileImage(localFile!);
    }
    if (hasRemote) {
      return NetworkImage(
        '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    return null;
  }
}
