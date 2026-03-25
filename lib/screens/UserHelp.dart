import 'package:flutter/material.dart';

class UserHelp extends StatelessWidget {
  const UserHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía del Sistema'),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStep(
            icon: Icons.home,
            title: 'Inicio y Dashboard',
            description:
                'Visualiza el resumen general de la iglesia, como el total de miembros y los servicios programados para la semana actual.',
          ),
          _buildStep(
            icon: Icons.calendar_today,
            title: 'Gestión de Servicios',
            description:
                'Registra y administra los eventos (Cultos, Reuniones de Liderazgo, etc.). Puedes asignar quién predica y quién ministra.',
          ),
          _buildStep(
            icon: Icons.people,
            title: 'Membresía',
            description:
                'Módulo principal para añadir nuevos hermanos, editar sus datos o eliminarlos. Puedes buscarlos rápidamente por nombre.',
          ),
          _buildStep(
            icon: Icons.how_to_reg,
            title: 'Asistencia y Visitas',
            description:
                'Toma asistencia en tiempo real. Permite registrar presentes, visitas nuevas y visitas pastorales para un seguimiento efectivo.',
          ),
          _buildStep(
            icon: Icons.groups,
            title: 'Redes y Ministerios',
            description:
                'Organiza la iglesia por grupos (Hombres, Mujeres, Jóvenes) y áreas de servicio (Alabanza, Diaconado).',
          ),
          _buildStep(
            icon: Icons.bar_chart,
            title: 'Reportes en PDF',
            description:
                'Genera documentos listos para imprimir con los datos de asistencia y actividades filtrados por fecha.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido al Sistema de Gestión Eclesiástica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta guía te ayudará a entender las funciones principales de cada módulo.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[800],
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description),
        ),
      ),
    );
  }
}
