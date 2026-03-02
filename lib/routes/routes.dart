import 'package:app/screens/admin/admin.dart';
import 'package:app/screens/admin/profile.dart';
import 'package:app/screens/attendance.dart';
import 'package:app/screens/auth/auth_wrapper.dart';
import 'package:app/screens/create/create_member.dart';
import 'package:app/screens/create/create_network.dart';
import 'package:app/screens/create/create_service.dart';
import 'package:app/screens/members.dart';
import 'package:app/screens/ministry/ministries.dart';
import 'package:app/screens/network/network_manage.dart';
import 'package:app/screens/reports.dart';
import 'package:app/screens/service/services.dart';
import 'package:flutter/material.dart';

import '../screens/admin/users.dart';
import '../screens/create/create_ministry.dart';
import '../screens/home/dashboard.dart';
import '../screens/home/home.dart';
import '../screens/home/login.dart';
import '../screens/network/networks.dart';

class AppRoutes {
  static const String auth_wrapper = '/';
  static const String home = 'home';
  static const String login = 'login';
  static const String profile = 'profile';
  static const String dashboard = 'dashboard';
  static const String services = 'services';
  static const String members = 'members';
  static const String attendance = 'attendance';
  static const String networks = 'networks';
  static const String create_network = 'create_network';
  static const String ministries = 'ministries';
  static const String create_ministry = 'create_ministry';
  static const String reports = 'reports';
  static const String create_service = 'create_service';
  static const String create_member = 'create_member';
  static const String admin = 'admin';
  static const String users = 'users';
  static const String network_manage = 'network_manage';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      home: (context) => Home(),
      login: (context) => Login(),
      profile: (context) => Profile(),
      dashboard: (context) => Dashboard(),
      services: (context) => Services(),
      members: (context) => Members(),
      attendance: (context) => Attendance(),
      networks: (context) => Networks(),
      create_network: (context) => CreateNetwork(),
      ministries: (context) => Ministries(),
      create_ministry: (context) => CreateMinistry(),
      reports: (context) => Reports(),
      create_service: (context) => CreateService(),
      create_member: (context) => CreateMember(),
      admin: (context) => Admin(),
      users: (context) => Users(),
      network_manage: (context) => NetworkManage(),
      auth_wrapper: (context) => AuthWrapper(),
    };
  }
}
