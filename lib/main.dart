import 'package:Koinos/providers/announcement_provider.dart';
import 'package:Koinos/providers/attendance_provider.dart';
import 'package:Koinos/providers/leader_provider.dart';
import 'package:Koinos/providers/log_provider.dart';
import 'package:Koinos/providers/member_provider.dart';
import 'package:Koinos/providers/ministry_provider.dart';
import 'package:Koinos/providers/network_provider.dart';
import 'package:Koinos/providers/role_provider.dart';
import 'package:Koinos/providers/service_provider.dart';
import 'package:Koinos/providers/service_type_provider.dart';
import 'package:Koinos/providers/user_provider.dart';
import 'package:Koinos/routes/routes.dart';
import 'package:Koinos/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'colors.dart';

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
        ChangeNotifierProvider(create: (context) => MinistryProvider()),
        ChangeNotifierProvider(create: (context) => ServiceTypeProvider()),
        ChangeNotifierProvider(create: (context) => LeaderProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementProvider()),
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
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
      locale: const Locale('es', ''),
    );
  }

  // Función para reutilizar tu DatePickerTheme en ambos temas
  DatePickerThemeData _buildDatePickerTheme({required bool isDark}) {
    final bgColor = isDark ? const Color(0xFF1E293B) : cardColor;
    final textColor = isDark ? Colors.white : Colors.black87;

    return DatePickerThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: bgColor,
      headerBackgroundColor: primaryColor,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return textColor;
      }),
      todayForegroundColor: WidgetStateProperty.all(textColor),
      todayBackgroundColor: WidgetStateProperty.all(
        Colors.blue.withOpacity(0.3),
      ),
      yearForegroundColor: WidgetStateProperty.all(textColor),
      headerHelpStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      headerHeadlineStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      weekdayStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.redAccent,
      ),
      dayStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      yearStyle: const TextStyle(fontSize: 18),
    );
  }
}
