import 'dart:convert';

import 'package:Koinos/services/tenant_scope.dart';
import 'package:flutter_test/flutter_test.dart';

/// Construye un token de mentira con los claims que emite el servidor. Sólo se lee el payload,
/// así que la firma no importa: la autoridad sigue siendo el servidor en cada petición.
String tokenWith({String? tenantType, String? tenantSlug}) {
  final claims = <String, dynamic>{
    'sub': 'alguien',
    if (tenantType != null) 'tenant_type': tenantType,
    if (tenantSlug != null) 'tenant_slug': tenantSlug,
    if (tenantType != null) 'tenant_id': '00000000-0000-0000-0000-0000000000aa',
  };
  final payload = base64Url.encode(utf8.encode(json.encode(claims)));
  return 'cabecera.$payload.firma';
}

void main() {
  setUp(TenantScope.clear);

  group('alcance de inquilino', () {
    test('un usuario del Ministerio puede consultar y no escribir datos de congregación', () {
      TenantScope.adoptFromToken(tokenWith(tenantType: 'MINISTERIO', tenantSlug: 'vri'));

      expect(TenantScope.isMinistry, isTrue);
      expect(TenantScope.canWriteChurchData, isFalse,
          reason: 'el servidor rechaza sus escrituras, así que la interfaz no debe ofrecerlas');
      expect(TenantScope.isConsolidatedView, isTrue,
          reason: 'sin iglesia elegida, el Ministerio mira el consolidado');
    });

    test('un usuario de iglesia escribe y no tiene nada que elegir', () {
      TenantScope.adoptFromToken(
          tokenWith(tenantType: 'IGLESIA', tenantSlug: 'casa-de-restauracion'));

      expect(TenantScope.isMinistry, isFalse);
      expect(TenantScope.canWriteChurchData, isTrue);
      expect(TenantScope.homeTenantSlug, 'casa-de-restauracion');
    });

    test('un token sin claims de inquilino no concede alcance de Ministerio', () {
      TenantScope.adoptFromToken(tokenWith());

      expect(TenantScope.isMinistry, isFalse,
          reason: 'un token viejo, anterior a multiinquilino, no debe abrir nada');
      expect(TenantScope.canWriteChurchData, isTrue);
    });

    test('un token ilegible no rompe la sesión', () {
      TenantScope.adoptFromToken('esto-no-es-un-jwt');

      expect(TenantScope.isMinistry, isFalse);
    });
  });
}
