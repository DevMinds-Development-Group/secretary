import 'dart:convert';

import 'package:Koinos/providers/tenant_provider.dart';
import 'package:Koinos/services/tenant_scope.dart';
import 'package:Koinos/widgets/church_selector.dart';
import 'package:Koinos/widgets/tenant_scoped_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

String ministryToken() {
  final claims = {
    'sub': 'ministerio',
    'tenant_type': 'MINISTERIO',
    'tenant_slug': 'vri',
    'tenant_id': '00000000-0000-0000-0000-0000000000aa',
  };
  return 'cabecera.${base64Url.encode(utf8.encode(json.encode(claims)))}.firma';
}

/// El almacenamiento seguro habla por un canal de plataforma que en un test no contesta nunca, y
/// sin esto la prueba se queda colgada esperándolo.
void silenciarAlmacenamientoSeguro() {
  const canal = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(canal, (_) async => null);
}

void main() {
  setUp(() {
    silenciarAlmacenamientoSeguro();
    TenantScope.clear();
  });

  testWidgets('cambiar de alcance desde el diálogo no rompe el árbol', (tester) async {
    TenantScope.adoptFromToken(ministryToken());
    await TenantScope.selectChurch('11111111-1111-1111-1111-111111111111');
    final tenants = TenantProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<TenantProvider>.value(
        value: tenants,
        child: MaterialApp(
          home: TenantScopedPage(
            child: Scaffold(
              appBar: AppBar(actions: const [ChurchSelector()]),
              body: const Center(child: TextField()),
              bottomNavigationBar: const SizedBox(height: 64),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Con el foco puesto en la pantalla que el cambio de alcance va a destruir: es la situación en
    // la que el framework se queja de nodos de foco apuntando a elementos muertos.
    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.tap(find.byType(ChurchSelector));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Consolidado'), findsWidgets, reason: 'el diálogo debe estar abierto');

    await tester.tap(find.text('Consolidado').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(TenantScope.selectedChurchId, isNull, reason: 'debe haber quedado en el consolidado');
  });
}
