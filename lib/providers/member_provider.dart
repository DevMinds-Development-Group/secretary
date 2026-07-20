// lib/providers/member_provider.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/member_filters.dart';
import '../models/member_model.dart';
import '../services/api_client.dart';
import '../utils/app_image_cache.dart';
import '../utils/app_log.dart';

class MemberProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  static const int defaultPageSize = 10;

  // --- Estado de la LISTA PAGINADA (pantalla Miembros) ---
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;
  MemberFilters _filters = const MemberFilters();

  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = defaultPageSize;

  // --- Estado de TODOS LOS MIEMBROS (selectores/conteos/detalles) ---
  List<Member> _allMembers = [];
  bool _allLoading = false;
  String? _allError;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  List<Member> get allMembers => _allMembers;
  bool get allLoading => _allLoading;
  String? get allError => _allError;

  MemberFilters get filters => _filters;
  bool get hasActiveFilters => _filters.isNotEmpty;

  /// Busca en la lista completa y, como respaldo, en la página actual.
  List<Member> getMembersByIds(List<String> ids) {
    final pool = _allMembers.isNotEmpty ? _allMembers : _members;
    return pool.where((member) => ids.contains(member.id)).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners(); // Esto le avisa a la UI que ya puede intentar mostrar el formulario otra vez
  }

  Future<String?> addMemberAndGetId({
    required String name,
    required String lastName,
    required String address,
    required String phone,
    DateTime? birthdate,
    required String networkId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        "name": name,
        "lastName": lastName,
        "address": address,
        "phone": phone,
        "birthdate": birthdate != null
            ? birthdate.toIso8601String().split('T')[0]
            : null,
        "enabled": true,
        "networkId": networkId,
      };

      // Realizamos la petición POST
      final response = await _apiClient.dio.post('/members', data: data);

      // Si el backend devuelve el objeto creado con su ID
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['id'].toString();
      }
      return null;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Error al crear miembro';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/member_provider.dart

  Future<bool> uploadMemberPhoto(String memberId, File imageFile) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. El campo debe llamarse 'file' según tu curl
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_$memberId.jpg',
        ),
      });

      // URL anterior (misma URL se sobrescribe en el backend) para invalidarla.
      final oldUrl = findById(memberId)?.photoUrl;

      final response = await _apiClient.dio.post(
        '/members/$memberId/profile-picture',
        data: formData,
      );

      final ok = response.statusCode == 200 || response.statusCode == 201;
      if (ok) {
        // Invalida la foto cacheada en toda la app para que se recarguen los
        // bytes nuevos (la URL se reutiliza).
        await AppImageCache.evict(oldUrl);
        await fetchMembers();
        await fetchAllMembers();
      }

      return ok;
    } on DioException catch (e) {
      appLog("Error detalle: ${e.response?.data}");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMembers({bool force = false, int? page, int? size}) async {
    _currentPage = page ?? _currentPage;
    _pageSize = size ?? _pageSize;
    _isLoading = true;
    _error = null;
    _members = [];
    notifyListeners();

    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiClient.dio.get(
        '/members',
        queryParameters: {
          'pageNo': _currentPage,
          'pageSize': _pageSize,
          'sortType': 'asc',
          ..._filters.toQuery(),
        },
      );

      final List<dynamic> data = response.data['content'] ?? [];
      _members = data.map((m) => Member.fromJson(m)).toList();

      _currentPage = response.data['number'];
      _totalPages = response.data['totalPages'];
      if (response.data['size'] != null) {
        _pageSize = response.data['size'];
      }
    } on DioException catch (e) {
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _error = 'SIN_CONEXION';
      } else {
        _error = 'Error al cargar miembros';
      }
    } catch (e) {
      _error = 'Ocurrió un error inesperado';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga la primera página conservando los filtros vigentes (persisten al
  /// salir/entrar de la pantalla). La paginación vuelve a la página 0.
  Future<void> loadFirstPage({int size = defaultPageSize}) async {
    await fetchMembers(page: 0, size: size);
  }

  /// Aplica un nuevo conjunto de filtros y recarga desde la página 0.
  Future<void> applyFilters(MemberFilters filters) async {
    _filters = filters;
    await fetchMembers(page: 0);
  }

  /// Limpia todos los filtros y recarga desde la página 0.
  Future<void> clearFilters() async {
    _filters = const MemberFilters();
    await fetchMembers(page: 0);
  }

  void clearAllError() {
    _allError = null;
    notifyListeners();
  }

  /// Carga TODOS los miembros para selectores/conteos/detalles, en un estado
  /// separado que NO toca la paginación de la pantalla Miembros.
  Future<void> fetchAllMembers() async {
    _allLoading = true;
    _allError = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(
        '/members',
        queryParameters: {
          'pageNo': 0,
          'pageSize': 1000,
          'sortType': 'asc',
          'searchTerm': '',
        },
      );
      final List<dynamic> data = response.data['content'] ?? [];
      _allMembers = data.map((m) => Member.fromJson(m)).toList();
    } on DioException catch (e) {
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _allError = 'SIN_CONEXION';
      } else {
        _allError = 'Error al cargar miembros';
      }
    } catch (e) {
      _allError = 'Ocurrió un error inesperado';
    } finally {
      _allLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllMembersForGroups() async {
    await fetchAllMembers();
  }

  Future<void> onPageChanged(int newPage) async {
    await fetchMembers(page: newPage);
  }

  Future<void> onItemsPerPageChanged(int newSize) async {
    await fetchMembers(page: 0, size: newSize);
  }

  Future<void> nextPage() async {
    if (_currentPage < _totalPages - 1) {
      await fetchMembers(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (_currentPage > 0) {
      await fetchMembers(page: _currentPage - 1);
    }
  }

  Future<bool> addMember({
    required String name,
    required String lastName,
    required String address,
    required String phone,
    DateTime? birthdate,
    required String networkId,
    File? imageFile,
  }) async {
    try {
      final data = {
        "name": name,
        "lastName": lastName,
        "address": address,
        "phone": phone,
        "birthdate": birthdate != null
            ? birthdate.toIso8601String().split('T')[0]
            : null,
        "enabled": true,
        "networkId": networkId,
      };
      FormData formData = FormData.fromMap(data);

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'profilePictureUrl', // Asegúrate de que este nombre coincida con lo que espera tu Backend
            await MultipartFile.fromFile(imageFile.path, filename: 'photo.jpg'),
          ),
        );
      }

      await _apiClient.dio.post('/members', data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMember({
    required String id,
    required String name,
    required String lastName,
    required String address,
    required String phone,
    DateTime? birthdate,
    required bool enabled,
    required String networkId,
    File? imageFile,
  }) async {
    try {
      final data = {
        "id": id,
        "name": name,
        "lastName": lastName,
        "address": address,
        "phone": phone,
        "birthdate": birthdate != null
            ? birthdate.toIso8601String().split('T')[0]
            : null,
        "enabled": enabled,
        "networkId": networkId,
      };

      if (imageFile != null) {
        bool photoOk = await uploadMemberPhoto(id, imageFile);
        if (!photoOk) return false; // Si la foto falla, fallamos el proceso
      }

      await _apiClient.dio.put('/members', data: data);

      return true;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMember(String id) async {
    try {
      appLog('DEBUG: Enviando DELETE a /members/$id');

      final response = await _apiClient.dio.delete('/members/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchMembers();
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      appLog("Error al eliminar miembro: ${e.response?.data ?? e.message}");
      _error = e.response?.data['message'] ?? "Error al actualizar el miembro";
      return false;
    } catch (e) {
      appLog("Error inesperado: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/member_provider.dart
  Member? findById(String? id) {
    if (id == null) return null;
    for (final m in _allMembers) {
      if (m.id == id) return m;
    }
    for (final m in _members) {
      if (m.id == id) return m;
    }
    return null;
  }
}
