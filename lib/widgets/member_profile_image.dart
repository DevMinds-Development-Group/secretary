// lib/widgets/member_profile_image.dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../colors.dart';

class MemberProfileImage extends StatelessWidget {
  final String? imageUrl; // URL del servidor
  final File? localFile; // Archivo recién tomado por la cámara/galería
  final double radius; // Tamaño del círculo
  final String defaultAsset; // Imagen por defecto

  const MemberProfileImage({
    Key? key,
    this.imageUrl,
    this.localFile,
    this.radius = 50.0,
    this.defaultAsset = 'assets/02.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasLocal = localFile != null;
    bool hasRemote = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: primaryColor.withOpacity(0.1),
      onBackgroundImageError: hasRemote
          ? (exception, stackTrace) {
              debugPrint("Error cargando imagen: $exception");
            }
          : null,
      backgroundImage: _getImageProvider(hasLocal, hasRemote),
      child: (!hasLocal && !hasRemote)
          ? Icon(
              Icons.person,
              size: radius, // El ícono se ajusta al tamaño del círculo
              color: primaryColor.withOpacity(0.5),
            )
          : null,
    );
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
