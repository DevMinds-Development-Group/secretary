// lib/providers/member_provider.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/member_model.dart';
import '../services/api_client.dart';

class MemberProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = 10;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;

  List<Member> getMembersByIds(List<String> ids) {
    return _members.where((member) => ids.contains(member.id)).toList();
  }

  List<Member> get allMembers => _members;

  List<Member> get filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    return _members.where((member) {
      final query = _searchQuery.toLowerCase();
      return member.fullName.toLowerCase().contains(query) ||
          (member.networkName?.toLowerCase().contains(query) ?? false);
    }).toList();
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

      final response = await _apiClient.dio.post(
        '/members/$memberId/profile-picture',
        data: formData,
      );

      await fetchMembers();

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Error detalle: ${e.response?.data}");
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
    // _error = null;
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
          'searchTerm': _searchQuery,
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

  Future<void> fetchAllMembersForGroups() async {
    await fetchMembers(page: 0, size: 1000);
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

  void search(String query) {
    _searchQuery = query;
    _currentPage = 0;
    notifyListeners();
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
      print('DEBUG: Enviando DELETE a /members/$id');

      final response = await _apiClient.dio.delete('/members/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchMembers();
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Error al eliminar miembro: ${e.response?.data ?? e.message}");
      _error = e.response?.data['message'] ?? "Error al actualizar el miembro";
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/member_provider.dart
  Member? findById(String? id) {
    if (id == null) return null;
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
