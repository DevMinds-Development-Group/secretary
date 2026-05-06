import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- MODELOS INTERNOS PARA EL AUTHSERVICE ---
class UserProfile {
  final String username;
  final String role;
  final String? memberId;
  final MemberProfile? member;

  UserProfile({
    required this.username,
    required this.role,
    this.memberId,
    this.member,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'] as List?;
    final roleDesc = (roles != null && roles.isNotEmpty)
        ? roles[0]['description'] ?? 'Usuario'
        : 'Usuario';

    return UserProfile(
      username: json['username'],
      role: roleDesc,
      memberId: json['memberId'],
      member: json['member'] != null
          ? MemberProfile.fromJson(json['member'])
          : null,
    );
  }
}

class MemberProfile {
  final String name;
  final String lastName;
  final String? phone;
  final String? address;
  final String? networkName;
  final DateTime? birthdate;

  MemberProfile({
    required this.name,
    required this.lastName,
    this.phone,
    this.address,
    this.networkName,
    this.birthdate,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      networkName: json['networkName'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
    );
  }
}

class AuthService with ChangeNotifier {
  // Variables de estado
  String? _userName;
  String? _userRoleDescription;
  String? _rawRole;
  UserProfile? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get userName => _userName;
  String? get userRole => _userRoleDescription;
  String? get rawRole => _rawRole;
  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> _permissions = [];

  List<String> get permissions => _permissions;

  bool hasPermission(String permissionName) {
    return _permissions.contains(permissionName);
  }

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://vri-secretary-backend-production.up.railway.app/api/v1',
    ),
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> fetchUserProfile(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await getToken();
      final response = await _dio.get(
        '/users/$username',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _error = null;
        _user = UserProfile.fromJson(response.data);
        final userData = response.data;

        final roles = userData['roles'] as List?;
        if (roles != null && roles.isNotEmpty) {
          _userRoleDescription = roles[0]['description'];
          _rawRole = roles[0]['name'];
          _permissions = List<String>.from(roles[0]['permissions'] ?? []);
        }

        _user = UserProfile.fromJson(userData);
        _userName = _user!.username;
        _userRoleDescription = _user!.role;

        await _secureStorage.write(key: 'user_name', value: _userName ?? "");
        await _secureStorage.write(
          key: 'user_role_desc',
          value: _userRoleDescription ?? "",
        );
        await _secureStorage.write(key: 'raw_role', value: _rawRole ?? "");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.message?.contains('SocketException') == true) {
        _error = "SIN_CONEXION";
      } else {
        _error = "Error de servidor";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 && response.data['jwtToken'] != null) {
        final token = response.data['jwtToken'];
        await _saveToken(token);
        await fetchUserProfile(username);
        return null; // Éxito
      }
      return 'Error desconocido';
    } on DioException catch (e) {
      // Si el servidor responde con un error (como 401)
      if (e.response != null) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return 'CREDENTIALS_ERROR'; // Clave para la UI
        }
        return 'SERVER_ERROR';
      }
      // Si es un error de red (timeout, sin internet)
      return 'NETWORK_ERROR';
    } catch (e) {
      return 'UNKNOWN_ERROR';
    }
  }

  Future<void> loadUserData() async {
    try {
      final savedName = await _secureStorage.read(key: 'user_name');
      final savedRoleDesc = await _secureStorage.read(key: 'user_role_desc');
      final savedRawRole = await _secureStorage.read(key: 'raw_role');

      if (savedName != null) {
        _userName = savedName;
        _userRoleDescription = savedRoleDesc;
        _rawRole = savedRawRole;

        fetchUserProfile(savedName);

        notifyListeners();
      }
    } catch (e) {
      print("Error leyendo SecureStorage: $e");
    }
  }

  // Métodos de Token
  Future<void> _saveToken(String token) async =>
      await _secureStorage.write(key: 'auth_token', value: token);
  Future<String?> getToken() async =>
      await _secureStorage.read(key: 'auth_token');

  Future<void> signOut() async {
    await _secureStorage.deleteAll();
    _userName = null;
    _userRoleDescription = null;
    _rawRole = null;
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
