// lib/providers/network_provider.dart
import 'package:flutter/material.dart';

import '../models/network_model.dart';
import '../services/api_client.dart';

class NetworkProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<NetworkModel> _networks = [];
  bool _isLoading = false;

  List<NetworkModel> get networks => _networks;
  bool get isLoading => _isLoading;

  Future<void> fetchNetworks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/networks');
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['content'] ?? []);

      _networks = data.map((n) => NetworkModel.fromJson(n)).toList();
    } catch (e) {
      print("Error cargando redes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/network_provider.dart

  Future<void> addNetwork(String name, String mission) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.post(
        '/networks',
        data: {"name": name, "mission": mission},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Recargamos la lista para ver la nueva red
        await fetchNetworks();
      }
    } catch (e) {
      print("Error al crear red: $e");
      rethrow; // Para manejar el error en la UI si quieres
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNetwork(
    NetworkModel network,
    List<String> leaderIds,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiClient.dio.put(
        '/networks',
        data: {
          "id": network.id,
          "name": network.name,
          "mission": network.mission,
          "leaderIds": leaderIds,
        },
      );

      // Actualizamos la lista local y notificamos
      await fetchNetworks();
    } catch (e) {
      print("Error al actualizar red: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/network_provider.dart

  Future<void> deleteNetwork(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.delete('/networks/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _networks.removeWhere((n) => n.id == id);

        // 3. Opcional: Volver a pedir la lista al servidor para estar 100% sincronizados
        // await fetchNetworks();

        notifyListeners();
      }
    } catch (e) {
      print("Error al eliminar red: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
