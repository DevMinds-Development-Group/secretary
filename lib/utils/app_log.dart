import 'package:flutter/foundation.dart';

/// Logging ligero solo en modo debug. En release es un no-op, evitando
/// ruido en consola y el warning `avoid_print` del linter.
///
/// Reemplaza los `print(...)` dispersos por `appLog(...)`.
void appLog(Object? message) {
  if (kDebugMode) {
    debugPrint(message?.toString());
  }
}
