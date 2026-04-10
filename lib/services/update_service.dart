import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/api_client.dart';
import '../widgets/button.dart';

class UpdateService {
  final ApiClient _apiClient = ApiClient();

  // 1. Movemos las variables aquí para que sean accesibles en toda la clase
  double _progress = 0;
  bool _isDownloading = false;

  Future<void> checkForUpdates(BuildContext context) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String currentBuild = packageInfo.buildNumber;
      String fullCurrent = "$currentVersion+$currentBuild";

      final response = await _apiClient.dio.get('/app-versions/check');

      String latestVersionRaw = response.data['latestVersion'];
      String latestVersion = latestVersionRaw.startsWith('v')
          ? latestVersionRaw.substring(1)
          : latestVersionRaw;

      String downloadUrl = response.data['url'];
      String releaseNotes = response.data['releaseNotes'] ?? "";

      if (fullCurrent != latestVersion) {
        if (!context.mounted) return;
        _showUpdateDialog(
          context,
          downloadUrl,
          latestVersion,
          fullCurrent,
          releaseNotes,
        );
      }
    } catch (e) {
      debugPrint("Error al verificar actualización: $e");
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String url,
    String latestVersion,
    String currentVersion,
    String notes,
  ) {
    // Reiniciamos el progreso cada vez que se abre el diálogo
    _progress = 0;
    _isDownloading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Nueva versión disponible",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  "v$latestVersion",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Versión actual: v$currentVersion",
                  style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notes.isNotEmpty && !_isDownloading) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Notas: $notes",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                    ),
                  ),
                ],
                if (_isDownloading) ...[
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Descargando... ${_progress.toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
                //const SizedBox(height: 10),
              ],
            ),
            actions: [
              if (!_isDownloading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Ahora no",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 10),
                    Button(
                      text: "Actualizar",
                      onPressed: () {
                        setState(() {
                          _isDownloading = true;
                        });
                        _startDownload(context, url, setState);
                      },
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  void _startDownload(BuildContext context, String url, StateSetter setState) {
    try {
      OtaUpdate()
          .execute(url, destinationFilename: 'koinos_update.apk')
          .listen(
            (OtaEvent event) {
              setState(() {
                switch (event.status) {
                  case OtaStatus.DOWNLOADING:
                    _progress = double.tryParse(event.value ?? "0") ?? 0;
                    break;
                  case OtaStatus.INSTALLING:
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    break;
                  case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                    _handleError(context, "Permiso de instalación denegado");
                    break;
                  case OtaStatus.DOWNLOAD_ERROR:
                    _handleError(context, "Error al descargar el archivo");
                    break;
                  case OtaStatus.INTERNAL_ERROR:
                    _handleError(context, "Error interno del sistema");
                    break;
                  default:
                    break;
                }
              });
            },
            onError: (e) {
              _handleError(context, "Error inesperado: $e");
            },
          );
    } catch (e) {
      _handleError(context, "No se pudo iniciar la actualización: $e");
    }
  }

  void _handleError(BuildContext context, String message) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
