import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// Geocodifica direcciones de texto libre usando Nominatim (OpenStreetMap).
///
/// Usa una instancia propia de [Dio] (NO el `ApiClient` de la app, que inyecta
/// el token de auth y apunta al backend). En web el `Referer` del navegador
/// satisface la policy de uso de Nominatim (no se puede fijar `User-Agent`).
class GeocodingService {
  GeocodingService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'User-Agent': 'KoinosApp/1.0 (viento-recio-secretaria)'},
    ),
  );

  /// Devuelve las coordenadas de [address] o `null` si no se encuentra o falla.
  /// La consulta se sesga a Cuba (contexto de la iglesia).
  static Future<LatLng?> geocode(String address) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'format': 'jsonv2',
          'limit': 1,
          'q': '$query, Cuba',
        },
      );

      final data = response.data;
      if (data is List && data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        final lat = double.tryParse(first['lat']?.toString() ?? '');
        final lon = double.tryParse(first['lon']?.toString() ?? '');
        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
    } catch (_) {
      // Fallo de red / geocodificación → la UI hace fallback (sin mapa embebido).
    }
    return null;
  }
}
