// lib/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../main.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              'https://vri-secretary-backend-production.up.railway.app/api/v1',
        ),
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
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
