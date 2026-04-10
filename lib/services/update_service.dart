import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/api_client.dart';
import '../widgets/button.dart';

class UpdateService {
  final ApiClient _apiClient = ApiClient();

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
        _showUpdateDialog(context, downloadUrl, latestVersion, releaseNotes);
      }
    } catch (e) {
      debugPrint("Error al verificar actualización: $e");
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    String url,
    String version,
    String notes,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Nueva versión disponible",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              ('($version)'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                "Notas: $notes",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                ),
              ),
            ],
            const SizedBox(height: 10),
          ],
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Button(
              text: "Actualizar ahora",
              onPressed: () {
                Navigator.pop(context);
                _startDownload(context, url);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startDownload(BuildContext context, String url) {
    try {
      // Mostramos un SnackBar para que el usuario sepa que la descarga inició
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Descargando actualización en segundo plano..."),
          duration: Duration(seconds: 5),
        ),
      );

      OtaUpdate().execute(url, destinationFilename: 'koinos_update.apk').listen(
        (OtaEvent event) {
          // Puedes monitorear los estados: DOWNLOADING, INSTALLING, etc.
          debugPrint('OTA Status: ${event.status} : ${event.value}%');

          if (event.status == OtaStatus.INTERNAL_ERROR) {
            debugPrint('Error interno en la actualización');
          }
        },
      );
    } catch (e) {
      debugPrint('Error en la actualización OTA: $e');
    }
  }
}
