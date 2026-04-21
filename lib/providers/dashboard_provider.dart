import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_model.dart';
import '../services/api_client.dart';

class DashboardProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  DashboardModel? _summary;
  bool _isLoading = false;
  String? _error;

  DashboardModel? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/dashboard/summary');

      if (response.statusCode == 200) {
        _summary = DashboardModel.fromJson(response.data);
        _error = null;
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode != 401) {
        _error = "Error al cargar dashboard";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
