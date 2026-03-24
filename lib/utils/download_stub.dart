// lib/utils/download_stub.dart
class WebDownloadHelper {
  static void downloadWebFile(List<int> bytes, String fileName) {
    throw UnsupportedError(
      "No se puede descargar en web desde esta plataforma",
    );
  }
}
