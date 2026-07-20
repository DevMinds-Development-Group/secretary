import 'package:Koinos/providers/announcement_provider.dart';
import 'package:Koinos/providers/apostol_dashboard_provider.dart';
import 'package:Koinos/providers/attendance_provider.dart';
import 'package:Koinos/providers/dashboard_provider.dart';
import 'package:Koinos/providers/leader_provider.dart';
import 'package:Koinos/providers/log_provider.dart';
import 'package:Koinos/providers/member_provider.dart';
import 'package:Koinos/providers/ministry_provider.dart';
import 'package:Koinos/providers/network_members_provider.dart';
import 'package:Koinos/providers/network_provider.dart';
import 'package:Koinos/providers/role_provider.dart';
import 'package:Koinos/providers/service_provider.dart';
import 'package:Koinos/providers/service_type_provider.dart';
import 'package:Koinos/providers/user_provider.dart';
import 'package:Koinos/routes/routes.dart';
import 'package:Koinos/services/auth_service.dart';
import 'package:Koinos/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(create: (context) => LogProvider()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (context) => AttendanceProvider()),
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
        ChangeNotifierProvider(create: (context) => NetworkMembersProvider()),
        ChangeNotifierProvider(create: (context) => MinistryProvider()),
        ChangeNotifierProvider(create: (context) => ServiceTypeProvider()),
        ChangeNotifierProvider(create: (context) => LeaderProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
        ChangeNotifierProvider(create: (context) => ApostolDashboardProvider()),
        ChangeNotifierProvider.value(value: authService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viento Recio',
      initialRoute: '/',
      navigatorKey: navigatorKey,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
      locale: const Locale('es', ''),
    );
  }
}
