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

  const MemberProfileImage({
    Key? key,
    this.imageUrl,
    this.localFile,
    this.name,
    this.radius = 50.0,
    this.defaultAsset = 'assets/02.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasLocal = localFile != null;
    bool hasRemote = imageUrl != null && imageUrl!.isNotEmpty;

    String initial = "?";
    if (name != null && name!.trim().isNotEmpty) {
      initial = name!.trim()[0].toUpperCase();
    }

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
