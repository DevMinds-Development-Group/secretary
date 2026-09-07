import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'package:flutter/material.dart';

import '../models/announcement_model.dart';

class AnnouncementProvider with ChangeNotifier {
  /// Iglesia cuyos eventos se muestran en la pantalla pública de anuncios.
  ///
  /// La pantalla es anónima, así que el servidor no puede deducir la iglesia y
  /// hay que nombrarla. Se puede fijar en compilación para una instalación
  /// dedicada a una congregación:
  /// `flutter build --dart-define=PUBLIC_CHURCH_SLUG=nueva-esperanza`
  static const String churchSlug = String.fromEnvironment(
    'PUBLIC_CHURCH_SLUG',
    defaultValue: 'casa-de-restauracion',
  );

  List<Announcement> _announcements = [];
  bool _isLoading = false;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;

  Announcement? get todayEvent {
    final now = DateTime.now();
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      return _announcements.firstWhere((a) => a.specificDate == todayStr);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Llamada anónima: sin token no hay inquilino, así que hay que decir de qué
      // iglesia se piden los eventos.
      final response = await Dio().get(
        '${ApiConfig.baseUrl}/event-definitions/weekly',
        queryParameters: {ApiConfig.publicChurchParam: churchSlug},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        _announcements = data
            .map((item) => Announcement.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
