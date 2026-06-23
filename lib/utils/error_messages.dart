/// Mapea las cadenas de error de los providers a un mensaje amable para el
/// usuario. Garantiza que nunca se muestre texto crudo de la API/excepción.
///
/// Los providers siguen guardando sus cadenas internas; este mapeo ocurre en
/// la capa de vista (p. ej. dentro de `ErrorState`).
library;

/// Clave especial usada por los providers para indicar falta de conexión.
const String kNoConnectionError = 'SIN_CONEXION';

const String _genericMessage =
    'No pudimos cargar la información. Intenta de nuevo.';

const String _connectionMessage =
    'Sin conexión a Internet. Verifica tu red e intenta de nuevo.';

/// Indicios de que una cadena es técnica (fuga de detalles de la excepción).
const List<String> _technicalMarkers = [
  ':',
  'Exception',
  'DioException',
  'Error inesperado',
  'null',
  r'${',
  'StatusCode',
  'SocketException',
];

/// Devuelve un mensaje amable para el [error] dado, o `null` si no hay error.
String? friendlyError(String? error) {
  if (error == null || error.trim().isEmpty) return null;
  if (error == kNoConnectionError) return _connectionMessage;

  // Si la cadena parece técnica, no la mostramos: mensaje genérico.
  for (final marker in _technicalMarkers) {
    if (error.contains(marker)) return _genericMessage;
  }

  // Cadena ya curada en español: se muestra tal cual.
  return error;
}

/// `true` si el error corresponde a falta de conexión (la UI puede mostrar
/// `NoConnectionWidget` en ese caso).
bool isNoConnection(String? error) => error == kNoConnectionError;
