// lib/providers/role_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/role_model.dart';
import '../services/api_client.dart';
import '../utils/app_log.dart';

class RoleProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Role> _roles = [];
  bool _isLoading = false;
  String? _error;

  List<Role> get roles => _roles;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> fetchRoles() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/roles');

      // La respuesta de tu API es paginada, así que los datos están en la clave "content".
      final List<dynamic> roleData = response.data['content'];

      _roles = roleData.map((data) => Role.fromJson(data)).toList();
    } on DioException catch (e) {
      _error = 'Error al cargar roles: ${e.message}';
      appLog(_error);
      _roles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRole({
    required String name,
    required String description,
    required List<String> permissions,
  }) async {
    _error = null;

    final Map<String, dynamic> roleData = {
      'name': name,
      'description': description,
      'permissions': permissions,
      'enabled': true,
    };
    try {
      await _apiClient.dio.post('/roles', data: roleData);

      return true;
    } on DioException catch (e) {
      _error =
          e.response?.data['message'] ?? 'Error al crear el rol: ${e.message}';
      appLog(_error);
      return false;
    }
  }

  Future<bool> updateRole({
    required String id,
    required String name,
    required String description,
    required List<String> permissions,
    required bool enabled,
  }) async {
    _error = null;
    notifyListeners();

    try {
      // Intentamos convertir el ID a número si es posible,
      // ya que el backend suele esperar Long.
      final dynamic idValue = int.tryParse(id) ?? id;

      final Map<String, dynamic> roleData = {
        'id': idValue,
        'name': name,
        'description': description,
        'permissions': permissions,
        'enabled': enabled,
      };

      final response = await _apiClient.dio.put('/roles', data: roleData);

      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        // Si el servidor respondió con error (400, 404, 500)
        _error =
            e.response?.data['message'] ??
            'Error del servidor (${e.response?.statusCode})';
      } else {
        // Error de red o timeout
        _error = 'Error de conexión: ${e.message}';
      }

      notifyListeners();
      return false;
    } catch (e) {
      // Cualquier otro error inesperado
      _error = 'Error inesperado: $e';

      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRole(String id) async {
    _error = null;
    notifyListeners();

    try {
      appLog('DEBUG: Enviando DELETE a /roles/$id');
      await _apiClient.dio.delete('/roles/$id');

      // Eliminamos el rol de la lista local para que la UI se actualice al instante
      _roles.removeWhere((role) => role.id == id);

      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al eliminar el rol';
      appLog('DEBUG ERROR: $_error');
      notifyListeners();
      return false;
    }
  }
}
