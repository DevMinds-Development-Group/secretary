// lib/providers/member_provider.dart
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

  // Getters
  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> fetchMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/members');
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['content'] ?? []);
      _members = data.map((m) => Member.fromJson(m)).toList();
    } catch (e) {
      _error = 'Error al cargar miembros: ${e}';
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> addMember({
    required String name,
    String? secondName,
    required String lastName,
    required String address,
    required String phone,
    required DateTime birthdate,
    required String networkId,
  }) async {
    try {
      final data = {
        "name": name,
        "secondName": secondName,
        "lastName": lastName,
        "address": address,
        "phone": phone,
        "birthdate": birthdate.toIso8601String().split(
          'T',
        )[0], // Formato yyyy-MM-dd
        "enabled": true,
        "networkId": networkId,
      };

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
    required DateTime birthdate,
    required bool enabled,
    required String networkId,
  }) async {
    try {
      final data = {
        "id": id,
        "name": name,
        "lastName": lastName,
        "address": address,
        "phone": phone,
        "birthdate": birthdate.toIso8601String().split(
          'T',
        )[0], // Formato yyyy-MM-dd
        "enabled": enabled,
        "networkId": networkId,
      };

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
        _members.removeWhere((m) => m.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Error al eliminar miembro: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("Error inesperado: $e");
      return false;
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
