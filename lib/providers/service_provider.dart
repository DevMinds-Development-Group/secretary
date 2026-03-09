import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../services/api_client.dart';

class ServiceProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchServices() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/event-definitions/weekly');

      // El backend devuelve una lista directa de objetos
      final List<dynamic> serviceData = response.data;

      _services = serviceData
          .map((data) => ServiceModel.fromJson(data))
          .toList();

      // Ordenar por fecha y hora
      _services.sort((a, b) {
        int dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.time.hour.compareTo(b.time.hour);
      });
    } on DioException catch (e) {
      _error =
          'Error al cargar servicios: ${e.response?.data['message'] ?? e.message}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteService(String serviceId) async {
    _error = null;
    try {
      await _apiClient.dio.delete('/event-definitions/$serviceId');

      _services.removeWhere((service) => service.id == serviceId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error =
          'Error al eliminar servicio: ${e.response?.data['message'] ?? e.message}';
      print(_error);
      notifyListeners();
      return false;
    }
  }

  void updateService(ServiceModel updatedService) {
    final serviceIndex = _services.indexWhere((s) => s.id == updatedService.id);
    if (serviceIndex >= 0) {
      _services[serviceIndex] = updatedService;
      notifyListeners();
    }
  }

  List<ServiceModel> getEventsForDay(DateTime day) {
    return _services.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }
}
