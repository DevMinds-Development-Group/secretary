// lib/providers/user_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';
import '../utils/app_log.dart';

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
      appLog(_error);
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
      appLog(_error);
      //_isLoading = false;
      //notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser({
    required String username,
    String? password,
    required List<String> roleIds,
    String? memberId,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
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
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _error = "SIN_CONEXION";
      } else {
        _error = 'Error al actualizar usuario';
      }
      appLog("DEBUG ERROR: ${e.type} - ${e.error} - Message: ${e.message}");
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String username) async {
    _error = null;
    try {
      await _apiClient.dio.delete('/users/$username');

      _users.removeWhere((user) => user.username == username);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error =
          'Error al eliminar usuario: ${e.response?.data['message'] ?? e.message}';
      appLog(_error);
      notifyListeners();
      return false;
    }
  }
}
