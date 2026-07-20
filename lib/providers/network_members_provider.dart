import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/member_filters.dart';
import '../models/member_model.dart';
import '../services/api_client.dart';

/// Estado propio para la lista PAGINADA de miembros de UNA red (pantalla
/// detalle de red). Usa el endpoint `/members` con `networkId` + los mismos
/// filtros que la lista general, sin contaminar el estado de la pantalla
/// Miembros ni el de "todos los miembros".
class NetworkMembersProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  static const int defaultPageSize = 10;

  String? _networkId;
  List<Member> _members = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 0;
  int _pageSize = defaultPageSize;
  MemberFilters _filters = const MemberFilters();

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get pageSize => _pageSize;
  MemberFilters get filters => _filters;
  bool get hasActiveFilters => _filters.isNotEmpty;

  Future<void> _fetch({int? page, int? size}) async {
    final networkId = _networkId;
    if (networkId == null) return;

    _currentPage = page ?? _currentPage;
    _pageSize = size ?? _pageSize;
    _isLoading = true;
    _error = null;
    _members = [];
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(
        '/members',
        queryParameters: {
          'pageNo': _currentPage,
          'pageSize': _pageSize,
          'sortType': 'asc',
          'networkId': networkId,
          ..._filters.toQuery(),
        },
      );

      final List<dynamic> data = response.data['content'] ?? [];
      _members = data.map((m) => Member.fromJson(m)).toList();
      _currentPage = response.data['number'] ?? _currentPage;
      _totalPages = response.data['totalPages'] ?? 0;
      if (response.data['size'] != null) _pageSize = response.data['size'];
    } on DioException catch (e) {
      _error = (e.error == 'SIN_CONEXION' ||
              e.type == DioExceptionType.connectionError)
          ? 'SIN_CONEXION'
          : 'Error al cargar miembros';
    } catch (_) {
      _error = 'Ocurrió un error inesperado';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Entra a la red: fija el scope y carga la primera página conservando los
  /// filtros vigentes.
  Future<void> loadFirstPage(String networkId, {int size = defaultPageSize}) async {
    _networkId = networkId;
    await _fetch(page: 0, size: size);
  }

  Future<void> refresh() => _fetch();
  Future<void> onPageChanged(int newPage) => _fetch(page: newPage);
  Future<void> onItemsPerPageChanged(int newSize) => _fetch(page: 0, size: newSize);

  Future<void> applyFilters(MemberFilters filters) {
    _filters = filters;
    return _fetch(page: 0);
  }

  Future<void> clearFilters() {
    _filters = const MemberFilters();
    return _fetch(page: 0);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
