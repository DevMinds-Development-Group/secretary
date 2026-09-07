import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/tenant_model.dart';
import '../services/api_client.dart';
import '../services/tenant_scope.dart';

/// Iglesias del Ministerio y cuál se está consultando.
///
/// Sólo tiene sentido para un usuario del Ministerio: una iglesia se ve siempre
/// a sí misma y no necesita elegir.
class TenantProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<TenantModel> _churches = [];
  bool _isLoading = false;
  String? _error;

  List<TenantModel> get churches => _churches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isMinistry => TenantScope.isMinistry;
  bool get canWriteChurchData => TenantScope.canWriteChurchData;
  String? get selectedChurchId => TenantScope.selectedChurchId;
  bool get isConsolidatedView => TenantScope.isConsolidatedView;

  TenantModel? get selectedChurch {
    final id = TenantScope.selectedChurchId;
    if (id == null) return null;
    for (final church in _churches) {
      if (church.id == id) return church;
    }
    return null;
  }

  /// Etiqueta de la barra superior: el consolidado o la iglesia elegida.
  String get scopeLabel {
    if (!isMinistry) return '';
    return selectedChurch?.displayName ?? 'Consolidado';
  }

  Future<void> fetchChurches() async {
    if (!isMinistry) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/tenants',
        queryParameters: {'pageSize': 200, 'sortBy': 'name'},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final content = (response.data['content'] as List?) ?? const [];
        _churches = content
            .map((item) => TenantModel.fromJson(Map<String, dynamic>.from(item)))
            .where((tenant) => !tenant.isMinistry)
            .toList();
        _error = null;
      } else {
        _error = 'No se pudieron cargar las iglesias';
      }
    } on DioException catch (e) {
      _error = e.error == 'SIN_CONEXION' ? 'SIN_CONEXION' : 'No se pudieron cargar las iglesias';
    } catch (_) {
      _error = 'Ocurrió un error inesperado';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Nulo vuelve al consolidado.
  Future<void> selectChurch(String? churchId) async {
    await TenantScope.selectChurch(churchId);
    notifyListeners();
  }

  Future<ChurchProvisionResult?> provisionChurch({
    required String name,
    required String shortName,
    required String slug,
    required String adminUsername,
    String? address,
    String? phone,
    String? email,
  }) async {
    _error = null;
    try {
      final response = await _apiClient.dio.post(
        '/tenants',
        data: {
          'church': {
            'name': name,
            'shortName': shortName.isEmpty ? name : shortName,
            'slug': slug,
            'address': address,
            'phone': phone,
            'email': email,
          },
          'adminUsername': adminUsername,
        },
      );
      if (response.statusCode == 200 && response.data is Map) {
        final result = ChurchProvisionResult.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        await fetchChurches();
        return result;
      }
      _error = 'No se pudo dar de alta la iglesia';
      return null;
    } on DioException catch (e) {
      _error = (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'No se pudo dar de alta la iglesia';
      notifyListeners();
      return null;
    }
  }

  /// Datos de contacto y nombres. El identificador corto no se puede cambiar: viaja en enlaces y
  /// en la cabecera con la que el Ministerio consulta una iglesia.
  Future<bool> updateChurch({
    required String churchId,
    required String name,
    required String shortName,
    String? address,
    String? phone,
    String? email,
  }) async {
    _error = null;
    try {
      await _apiClient.dio.put(
        '/tenants/$churchId',
        data: {
          'name': name,
          'shortName': shortName.isEmpty ? name : shortName,
          // El servidor exige el slug en la petición aunque no lo cambie, así que se manda el
          // que ya tiene.
          'slug': _slugOf(churchId),
          // Cadena vacía y no nulo: el servidor ignora los campos nulos al actualizar, así que
          // mandar nulo haría imposible borrar un teléfono o una dirección.
          'address': address ?? '',
          'phone': phone ?? '',
          'email': email ?? '',
        },
      );
      await fetchChurches();
      return true;
    } on DioException catch (e) {
      _error = (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'No se pudo guardar la iglesia';
      notifyListeners();
      return false;
    }
  }

  String _slugOf(String churchId) {
    for (final church in _churches) {
      if (church.id == churchId) return church.slug;
    }
    return '';
  }

  Future<bool> updateStatus(String churchId, bool enabled) async {
    try {
      await _apiClient.dio.patch(
        '/tenants/$churchId/status',
        queryParameters: {'enabled': enabled},
      );
      await fetchChurches();
      return true;
    } on DioException catch (e) {
      _error = (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'No se pudo cambiar el estado de la iglesia';
      notifyListeners();
      return false;
    }
  }
}
