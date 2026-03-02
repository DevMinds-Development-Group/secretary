// main.dart

import 'package:app/colors.dart';
import 'package:app/providers/attendance_provider.dart';
import 'package:app/providers/log_provider.dart';
import 'package:app/providers/member_provider.dart';
import 'package:app/providers/ministry_provider.dart';
import 'package:app/providers/network_provider.dart';
import 'package:app/providers/pastor_provider.dart';
import 'package:app/providers/role_provider.dart';
import 'package:app/providers/service_provider.dart';
import 'package:app/providers/service_type_provider.dart';
// 1. Importa el nuevo UserProvider que creamos
import 'package:app/providers/user_provider.dart';
import 'package:app/routes/routes.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // 2. Reemplaza ChangeNotifierProvider por MultiProvider
    MultiProvider(
      providers: [
        // 3. Registra aquí todos tus proveedores
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(create: (context) => LogProvider()),
        ChangeNotifierProvider(create: (context) => MemberProvider()),
        ChangeNotifierProvider(create: (context) => AttendanceProvider()),
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
        ChangeNotifierProvider(create: (context) => MinistryProvider()),
        ChangeNotifierProvider(create: (context) => ServiceTypeProvider()),
        ChangeNotifierProvider(create: (context) => PastorProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
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
      title: 'Secretaría Viento Recio',
      initialRoute: AppRoutes.auth_wrapper,
      routes: AppRoutes.getRoutes(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Inglés
        Locale('es', ''), // Español
      ],
      locale: const Locale('es', ''),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade200,
          primary: primaryColor,
          onPrimary: cardColor,
          surface: cardColor,
          onSurface: Colors.black87,
        ),
        datePickerTheme: DatePickerThemeData(
          // --- PADDINGS Y FORMA ---
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Bordes más redondeados
          ),

          // --- COLORES ---
          backgroundColor: Colors.white, // Fondo general del calendario
          headerBackgroundColor:
              primaryColor, // Color de fondo de la cabecera ("Seleccionar fecha")
          headerForegroundColor: cardColor, // Color del texto de la cabecera
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            // Color de los días del mes
            if (states.contains(MaterialState.selected)) {
              return Colors.white; // Color del número del día seleccionado
            }
            return Colors.black87; // Color de los otros días
          }),
          todayForegroundColor: WidgetStateProperty.all(
            Colors.black87,
          ), // Color del número del día de "hoy"
          todayBackgroundColor: WidgetStateProperty.all(
            Colors.blue.shade100,
          ), // Fondo del día de "hoy"
          yearForegroundColor: WidgetStateProperty.all(
            Colors.black87,
          ), // Color de los años en la vista de selección de año
          // --- TAMAÑOS Y ESTILOS DE LETRA ---
          headerHelpStyle: const TextStyle(
            // Estilo para "Seleccionar fecha"
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          headerHeadlineStyle: const TextStyle(
            // Estilo para la fecha seleccionada (ej. "vie, 10 de ene")
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          weekdayStyle: const TextStyle(
            // Estilo para los días de la semana (L, M, M, J, V, S, D)
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: negativeColor,
          ),
          dayStyle: const TextStyle(
            // Estilo para los números de los días
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          yearStyle: const TextStyle(
            // Estilo para los años en la lista
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
