// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  String? _userName;
  String? _userRoleDescription;
  String? _rawRole;

  String? get userName => _userName;
  String? get userRole => _userRoleDescription;
  String? get rawRole => _rawRole;

  Future<void> fetchUserProfile(String username) async {
    try {
      final token = await getToken();
      print("TOKEN ACTUAL: $token");

      final response = await _dio.get(
        '/users/$username',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print("RESPUESTA PERFIL: ${response.data}");

      if (response.statusCode == 200) {
        final userData = response.data;

        _userName = userData['username'];

        final roles = userData['roles'] as List?;
        if (roles != null && roles.isNotEmpty) {
          _userRoleDescription = roles[0]['description'] ?? 'Usuario';
          _rawRole = roles[0]['name'];
          print(
            "DATOS ASIGNADOS: $_userName, $_userRoleDescription, $_rawRole",
          );
        }

        await _secureStorage.write(key: 'user_name', value: _userName ?? "");
        await _secureStorage.write(
          key: 'user_role_desc',
          value: _userRoleDescription ?? "",
        );
        await _secureStorage.write(key: 'raw_role', value: _rawRole ?? "");

        notifyListeners();
      }
    } catch (e) {
      print("Error obteniendo perfil: $e");
    }
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vri-secretary-backend-production.up.railway.app/api/v1',
    ),
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  Future<String?> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 && response.data['jwtToken'] != null) {
        final token = response.data['jwtToken'];

        await _saveToken(token);

        await fetchUserProfile(username);

        return null;
      }
      return 'Error de credenciales';
    } catch (e) {
      return 'Error de conexión';
    }
  }

  Future<void> loadUserData() async {
    try {
      final savedName = await _secureStorage.read(key: 'user_name');
      final savedRoleDesc = await _secureStorage.read(key: 'user_role_desc');
      final savedRawRole = await _secureStorage.read(key: 'raw_role');

      print("CARGANDO DE DISCO: $savedName, $savedRoleDesc");

      if (savedName != null) {
        _userName = savedName;
        _userRoleDescription = savedRoleDesc;
        _rawRole = savedRawRole;
        print("DATOS CARGADOS DEL DISCO: $_userName");
        notifyListeners();
      } else {
        print("NO HAY DATOS GUARDADOS EN DISCO");
      }
    } catch (e) {
      print("Error leyendo SecureStorage: $e");
    }
  }

  Future<void> signOut() async {
    try {
      // 1. Destruir token y datos del disco (Funciona en Móvil y Web)
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_name');
      await _secureStorage.delete(key: 'user_role_desc');
      await _secureStorage.delete(key: 'raw_role');

      // 2. Limpiar variables en memoria
      _userName = null;
      _userRoleDescription = null;
      _rawRole = null;

      // 3. NOTIFICAR: Esto hace que el AuthWrapper detecte que el token es null
      // y cambie la pantalla de Dashboard a Home automáticamente.
      notifyListeners();

      print("Sesión destruida correctamente.");
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}
