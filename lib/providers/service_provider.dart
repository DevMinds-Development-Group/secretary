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
    _isLoading = true;
    _services = [];
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/event-definitions/weekly',
        queryParameters: {'t': DateTime.now().millisecondsSinceEpoch},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<ServiceModel> loadedServices = data
            .map((s) => ServiceModel.fromJson(s))
            .toList();

        loadedServices.sort((a, b) {
          int dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          return a.time.hour.compareTo(b.time.hour);
        });

        _services = loadedServices;

        print(
          "DEBUG: Lista sincronizada con el servidor. Total: ${_services.length}",
        );
      }
    } catch (e) {
      _error = "Error al cargar servicios: $e";
      print("DEBUG ERROR FETCH: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addService(ServiceModel service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        '/event-definitions',
        data: service.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      _error = "Error al guardar";
      print("DEBUG ERROR: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateService(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.put(
        '/event-definitions',
        data: service.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchServices();
        return true;
      }
      return false;
    } catch (e) {
      _error = "Error al actualizar";
      return false;
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

  List<ServiceModel> getEventsForDay(DateTime day) {
    return _services.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }
}
