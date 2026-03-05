import 'package:flutter/material.dart';

import '../models/member_model.dart'; // Usaremos Member para los líderes
import '../services/api_client.dart';

class LeaderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Member> _leaders = []; // Cambiado a List<Member>
  bool _isLoading = false;

  List<Member> get leaders => _leaders;
  bool get isLoading => _isLoading;

  Member findById(String id) {
    return _leaders.firstWhere(
      (p) => p.id == id,
      orElse: () => Member(
        id: '',
        name: 'No encontrado',
        lastName: '',
        address: '',
        phone: '',
        networkName: '',
        birthdate: DateTime.now(),
        enabled: true,
      ),
    );
  }

  Future<void> fetchLeaders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/members/leaders');
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['content'] ?? []);

      // Mapeamos a Member directamente
      _leaders = data.map((l) => Member.fromJson(l)).toList();
    } catch (e) {
      print("Error cargando líderes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
