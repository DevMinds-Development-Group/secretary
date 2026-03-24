import 'package:app/routes/route_guard.dart';
import 'package:app/screens/admin/admin.dart';
import 'package:app/screens/admin/profile.dart';
import 'package:app/screens/attendance/attendance.dart';
import 'package:app/screens/auth/auth_wrapper.dart';
import 'package:app/screens/create/create_member.dart';
import 'package:app/screens/create/create_network.dart';
import 'package:app/screens/create/create_service.dart';
import 'package:app/screens/members.dart';
import 'package:app/screens/ministry/ministries.dart';
import 'package:app/screens/network/network_manage.dart';
import 'package:app/screens/service/services.dart';
import 'package:flutter/material.dart';

import '../screens/admin/users.dart';
import '../screens/attendance/attendance_history.dart';
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
  static const String create_other_service = 'create_other_service';
  static const String attendance_history = 'attendance_history';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      auth_wrapper: (context) => AuthWrapper(),
      home: (context) => Home(),
      login: (context) => Login(),

      profile: (context) => Profile(),
      dashboard: (context) => RouteGuard.checkAuth(context, const Dashboard()),
      services: (context) => RouteGuard.checkAuth(context, const Services()),
      members: (context) => RouteGuard.checkAuth(context, const Members()),
      attendance: (context) =>
          RouteGuard.checkAuth(context, const Attendance()),
      networks: (context) => RouteGuard.checkAuth(context, const Networks()),
      create_network: (context) =>
          RouteGuard.checkAuth(context, const CreateNetwork()),
      ministries: (context) =>
          RouteGuard.checkAuth(context, const Ministries()),
      create_ministry: (context) =>
          RouteGuard.checkAuth(context, const CreateMinistry()),
      //reports: (context) => Reports(),
      create_service: (context) =>
          RouteGuard.checkAuth(context, const CreateService()),
      create_member: (context) =>
          RouteGuard.checkAuth(context, const CreateMember()),
      admin: (context) => RouteGuard.checkAuth(context, const Admin()),
      users: (context) => RouteGuard.checkAuth(context, const Users()),
      network_manage: (context) =>
          RouteGuard.checkAuth(context, const NetworkManage()),
      attendance_history: (context) =>
          RouteGuard.checkAuth(context, const AttendanceHistory()),
    };
  }
}
