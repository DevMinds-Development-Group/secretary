import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/member_model.dart';
import '../models/ministry_model.dart';
import '../services/api_client.dart';
import '../utils/app_log.dart';

class MinistryProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<MinistryModel> _ministries = [];
  bool _isLoading = false;
  String? _error;

  List<MinistryModel> get ministries => _ministries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchMinistries() async {
    _isLoading = true;
    _ministries = [];
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/ministries');
      if (response.statusCode == 200) {
        _error = null;
        final List<dynamic> data = response.data['content'] ?? [];
        _ministries = data.map((m) => MinistryModel.fromJson(m)).toList();
        appLog("Ministerios cargados: ${_ministries.length}");
      }
    } on DioException catch (e) {
      if (e.error == 'SIN_CONEXION' ||
          e.type == DioExceptionType.connectionError) {
        _error = "SIN_CONEXION";
      } else {
        _error = "Error al cargar ministerios";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMinistry(
    String name,
    String description,
    List<String> leaderIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        '/ministries',
        data: {
          "name": name,
          "description": description,
          "leaderIds": leaderIds,
        },
      );

      await fetchMinistries();
    } catch (e) {
      appLog("Error al crear ministerio: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMinistry(
    String id,
    String name,
    String description,
    List<String> leaderIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.put(
        '/ministries',
        data: {
          "id": id,
          "name": name,
          "description": description,
          "leaderIds": leaderIds,
        },
      );

      await fetchMinistries();
    } catch (e) {
      appLog("Error al actualizar ministerio: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMinistry(String id) async {
    final index = _ministries.indexWhere((m) => m.id == id);
    MinistryModel? deletedMinistry;

    if (index != -1) {
      deletedMinistry = _ministries[index];
      _ministries.removeAt(index);
      notifyListeners();
    }
    try {
      final response = await _apiClient.dio.delete('/ministries/$id');
      await fetchMinistries();
    } catch (e) {
      _error = "No se pudo eliminar el ministerio";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Member> getMembersForMinistry(String ministryId) {
    final ministry = _ministries.firstWhere(
      (m) => m.id == ministryId,
      orElse: () => MinistryModel(id: '', name: '', description: ''),
    );
    return ministry.members;
  }

  int getMemberCountForMinistry(String ministryId) {
    final ministry = _ministries.firstWhere(
      (m) => m.id == ministryId,
      orElse: () =>
          MinistryModel(id: '', name: '', description: '', membersCount: 0),
    );
    return ministry.membersCount;
  }

  Future<void> addMemberToMinistry(String ministryId, Member member) async {
    try {
      await _apiClient.dio.post('/ministries/$ministryId/members/${member.id}');
      await fetchMinistries();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMemberFromMinistry(
    String ministryId,
    Member member,
  ) async {
    try {
      await _apiClient.dio.delete(
        '/ministries/$ministryId/members/${member.id}',
      );
      await fetchMinistries();
    } catch (e) {
      rethrow;
    }
  }

  List<String> getMemberIdsForMinistry(String ministryId) {
    final ministry = _ministries.firstWhere(
      (m) => m.id == ministryId,
      orElse: () => MinistryModel(id: '', name: '', description: ''),
    );
    return [];
  }

  Future<void> fetchMinistryDetails(String id, {bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final response = await _apiClient.dio.get('/ministries/$id');
      final updatedMinistry = MinistryModel.fromJson(response.data);
      final index = _ministries.indexWhere((m) => m.id == id);

      if (index != -1) {
        _ministries[index] = updatedMinistry;
      }
    } catch (e) {
      appLog("Error cargando detalle del ministerio: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
