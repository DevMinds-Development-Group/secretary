// lib/services/api_client.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../main.dart';
import 'tenant_scope.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient()
    : _dio = Dio(
        BaseOptions(baseUrl: ApiConfig.baseUrl),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('No se encontró token para la petición a: ${options.path}');
          }

          // Sólo la manda el Ministerio, y sólo cuando ha descendido a una
          // iglesia. Sin ella el servidor entrega el consolidado.
          final selectedChurch = TenantScope.selectedChurchId;
          if (selectedChurch != null) {
            options.headers[ApiConfig.tenantHeader] = selectedChurch;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'Respuesta recibida: ${response.statusCode} desde ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('TOKEN EXPIRADO: Limpiando sesión...');
            await _secureStorage.deleteAll();
            await TenantScope.clear();

            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              'login',
              (route) => false,
            );

            return handler.resolve(
              Response(
                requestOptions: e.requestOptions,
                statusCode: 200,
                data: {},
              ),
            );
          }
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.error is SocketException) {
            // Enviamos un error con un mensaje específico que el Provider reconocerá
            return handler.next(
              DioException(
                requestOptions: e.requestOptions,
                error: 'SIN_CONEXION',
                type: DioExceptionType.unknown,
              ),
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
