import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Alcance de inquilino de la sesión: a qué iglesia pertenece quien ha entrado y,
/// si es del Ministerio, cuál está consultando.
///
/// Es estático porque el interceptor de Dio se construye en cada `ApiClient` y no
/// tiene forma de alcanzar un provider. Lo que guarda sale del token, así que la
/// autoridad sigue siendo el servidor: aquí sólo se recuerda.
class TenantScope {
  const TenantScope._();

  static const _selectedChurchKey = 'selected_church_id';
  static const _ministryType = 'MINISTERIO';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String? _homeTenantSlug;
  static String? _homeTenantType;
  static String? _selectedChurchId;

  static String? get homeTenantSlug => _homeTenantSlug;

  static String? get selectedChurchId => _selectedChurchId;

  /// El Ministerio consulta todas las iglesias; una iglesia sólo se ve a sí misma.
  static bool get isMinistry => _homeTenantType == _ministryType;

  /// El Ministerio supervisa y no opera: el servidor rechaza sus escrituras de
  /// datos de congregación, así que la interfaz no debe ofrecerlas.
  static bool get canWriteChurchData => !isMinistry;

  /// Cierto cuando el Ministerio mira el consolidado y no una iglesia concreta.
  static bool get isConsolidatedView => isMinistry && _selectedChurchId == null;

  /// Lee los claims de inquilino del token. Son informativos: el servidor
  /// resuelve el inquilino en cada petición, así que esto sólo sirve para que la
  /// interfaz sepa qué enseñar sin una llamada extra.
  static void adoptFromToken(String jwtToken) {
    final claims = _decodeClaims(jwtToken);
    _homeTenantSlug = claims['tenant_slug'] as String?;
    _homeTenantType = claims['tenant_type'] as String?;
  }

  static Future<void> restore(String? jwtToken) async {
    if (jwtToken != null) {
      adoptFromToken(jwtToken);
    }
    if (isMinistry) {
      _selectedChurchId = await _readStored();
    }
  }

  static Future<void> selectChurch(String? churchId) async {
    _selectedChurchId = churchId;
    // El estado en memoria manda; el almacenamiento sólo sirve para recordar la elección entre
    // sesiones, así que un fallo suyo no debe tumbar la operación.
    try {
      if (churchId == null) {
        await _storage.delete(key: _selectedChurchKey);
      } else {
        await _storage.write(key: _selectedChurchKey, value: churchId);
      }
    } catch (_) {
      // La elección sigue viva en esta sesión aunque no se haya podido persistir.
    }
  }

  static Future<String?> _readStored() async {
    try {
      return await _storage.read(key: _selectedChurchKey);
    } catch (_) {
      return null;
    }
  }

  /// Se invoca al cerrar sesión: si el alcance sobreviviera, la sesión siguiente
  /// arrancaría mirando la iglesia de quien usó la aplicación antes.
  static Future<void> clear() async {
    _homeTenantSlug = null;
    _homeTenantType = null;
    _selectedChurchId = null;
    // Lo de memoria se limpia primero y pase lo que pase: cerrar sesión no puede fallar porque el
    // almacenamiento seguro no esté disponible.
    try {
      await _storage.delete(key: _selectedChurchKey);
    } catch (_) {
      // Sin persistencia que borrar, no hay nada que arrastrar a la sesión siguiente.
    }
  }

  static Map<String, dynamic> _decodeClaims(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length != 3) return const {};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = json.decode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }
}
