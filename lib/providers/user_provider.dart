// lib/providers/user_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';

class UserProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = 10;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  Future<void> fetchUsers({int? page, int? size}) async {
    _currentPage = page ?? _currentPage;
    _pageSize = size ?? _pageSize;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/users',
        queryParameters: {'pageNo': _currentPage, 'pageSize': _pageSize},
      );

      final List<dynamic> data = response.data['content'] ?? [];
      _users = data.map((u) => User.fromJson(u)).toList();
      _totalPages = response.data['totalPages'] ?? 0;
      _currentPage = response.data['number'] ?? 0;
    } on DioException catch (e) {
      _error = 'Error al cargar usuarios: ${e.message}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onPageChanged(int newPage) async {
    await fetchUsers(page: newPage);
  }

  Future<void> onItemsPerPageChanged(int newSize) async {
    _pageSize = newSize;
    _currentPage = 0; // Reiniciar a la primera página con el nuevo tamaño
    await fetchUsers(page: 0, size: newSize);
  }

  Future<bool> addUser({
    required String username,
    required String password,
    required List<String> roleIds,
    String? memberId,
  }) async {
    //_isLoading = true;
    //notifyListeners();
    _error = null;
    try {
      await _apiClient.dio.post(
        '/users',
        data: {
          'username': username,
          'password': password,
          'role': roleIds,
          'memberId': memberId,
        },
      );

      return true;
    } on DioException catch (e) {
      _error =
          'Error al crear usuario: ${e.response?.data['message'] ?? e.message}';
      print(_error);
      //_isLoading = false;
      //notifyListeners();
      return false;
    }
  }

  // --- MÉTODO updateUser (VERSIÓN CORRECTA Y ASÍNCRONA) ---
  Future<bool> updateUser({
    required String username,
    String? password,
    required List<String> roleIds,
    String? memberId,
  }) async {
    _error = null;
    //_isLoading = true;
    //notifyListeners();
    try {
      await _apiClient.dio.put(
        '/users',
        data: {
          'username': username,
          'password': password,
          'role': roleIds,
          'memberId': memberId,
        },
      );

      return true;
    } on DioException catch (e) {
      _error =
          'Error al actualizar usuario: ${e.response?.data['message'] ?? e.message}';
      print(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String username) async {
    _error = null;
    // No necesitamos un `isLoading` aquí, la UI lo manejará de forma local.

    try {
      // Hacemos la petición DELETE al endpoint específico del usuario.
      await _apiClient.dio.delete('/users/$username');

      // Si la petición es exitosa (no lanza excepción), eliminamos el usuario
      // de nuestra lista local para que la UI se actualice instantáneamente.
      _users.removeWhere((user) => user.username == username);
      notifyListeners(); // Notificamos a la UI para que se redibuje sin el usuario.
      return true;
    } on DioException catch (e) {
      _error =
          'Error al eliminar usuario: ${e.response?.data['message'] ?? e.message}';
      print(_error);
      notifyListeners(); // Notificamos por si queremos mostrar el error en algún sitio.
      return false;
    }
  }
}
