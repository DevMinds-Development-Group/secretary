import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/announcement_model.dart';

class AnnouncementProvider with ChangeNotifier {
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
      final response = await Dio().get(
        'https://vri-secretary-backend-production.up.railway.app/api/v1/event-definitions/weekly',
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
