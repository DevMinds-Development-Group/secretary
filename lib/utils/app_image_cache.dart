import 'package:cached_network_image/cached_network_image.dart';

/// Utilidades de caché de imágenes a nivel de toda la app.
///
/// Las imágenes remotas se sirven vía [CachedNetworkImageProvider] (caché en
/// memoria + disco). Cuando una imagen se reemplaza en el backend reutilizando
/// la misma URL (p. ej. la foto de perfil), hay que invalidar la entrada para
/// que todas las pantallas vuelvan a descargar los bytes nuevos.
class AppImageCache {
  const AppImageCache._();

  /// Invalida una imagen (memoria + disco) en TODA la app.
  static Future<void> evict(String? url) async {
    if (url == null || url.isEmpty) return;
    // Caché en memoria de Flutter (PaintingBinding.imageCache).
    await CachedNetworkImageProvider(url).evict();
    // Caché en disco / gestor de caché de cached_network_image.
    await CachedNetworkImage.evictFromCache(url);
  }
}
