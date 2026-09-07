/// Configuración de la API.
///
/// Existe porque la URL base estaba escrita a mano en tres sitios y habían
/// divergido: `auth_service` apuntaba a producción mientras `api_client`
/// apuntaba a develop, así que el login se validaba contra una base de datos y
/// los datos venían de otra.
class ApiConfig {
  const ApiConfig._();

  /// Se puede sobrescribir en compilación:
  /// `flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-vientorecio.teamdevminds.xyz/api/v1',
  );

  /// Cabecera con la que el Ministerio consulta una iglesia concreta.
  static const String tenantHeader = 'X-Tenant-Id';

  /// Parámetro con el que un llamador anónimo indica de qué iglesia habla.
  static const String publicChurchParam = 'church';
}
