import 'package:flutter/material.dart';

import '../models/member_model.dart';
import '../models/ministry_model.dart';
import '../services/api_client.dart';

class MinistryProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<MinistryModel> _ministries = [];
  bool _isLoading = false;

  List<MinistryModel> get ministries => _ministries;
  bool get isLoading => _isLoading;

  Future<void> fetchMinistries() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/ministries');
      print("Respuesta API Ministerios: ${response.data}");

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['content'] ?? []);

      _ministries = data.map((m) => MinistryModel.fromJson(m)).toList();
      print("Ministerios cargados: ${_ministries.length}");
    } catch (e) {
      print("Error cargando ministerios: $e");
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchMinistries();
      }
    } catch (e) {
      print("Error al crear ministerio: $e");
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

      if (response.statusCode == 200) {
        await fetchMinistries();
      }
    } catch (e) {
      print("Error al actualizar ministerio: $e");
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

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Error al eliminar");
      }
    } catch (e) {
      if (deletedMinistry != null) {
        _ministries.insert(index, deletedMinistry);
        notifyListeners();
      }
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
    final index = _ministries.indexWhere((m) => m.id == ministryId);
    if (index != -1) {
      final alreadyExists = _ministries[index].members.any(
        (m) => m.id == member.id,
      );
      if (alreadyExists) return;

      final currentMembers = List<Member>.from(_ministries[index].members);
      currentMembers.add(member);

      _ministries[index] = _ministries[index].copyWith(
        members: currentMembers,
        membersCount: _ministries[index].membersCount + 1,
      );
      notifyListeners();
    }
    try {
      await _apiClient.dio.post('/ministries/$ministryId/members/${member.id}');
      await fetchMinistryDetails(ministryId, silent: true);
    } catch (e) {
      await fetchMinistryDetails(ministryId, silent: true);
      rethrow;
    }
  }

  Future<void> removeMemberFromMinistry(
    String ministryId,
    Member member,
  ) async {
    final index = _ministries.indexWhere((m) => m.id == ministryId);
    if (index != -1) {
      final currentMembers = List<Member>.from(_ministries[index].members);
      currentMembers.removeWhere((m) => m.id == member.id);

      _ministries[index] = _ministries[index].copyWith(
        members: currentMembers,
        membersCount: _ministries[index].membersCount - 1,
      );
      notifyListeners();
    }
    try {
      // 2. Petición real al servidor
      await _apiClient.dio.delete(
        '/ministries/$ministryId/members/${member.id}',
      );
      // Sincronización silenciosa
      await fetchMinistryDetails(ministryId, silent: true);
    } catch (e) {
      // Si falla, recargamos para restaurar al miembro
      await fetchMinistryDetails(ministryId, silent: true);
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
      print("Error cargando detalle del ministerio: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
