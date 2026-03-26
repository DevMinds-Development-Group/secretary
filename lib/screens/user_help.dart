import 'package:Koinos/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class UserHelp extends StatelessWidget {
  const UserHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Manual de Usuario'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildManualSection(
            icon: Icons.dashboard_outlined,
            title: '1. Panel de Inicio (Dashboard)',
            content: [
              '• Tarjeta Total Miembros: Cantidad histórica de personas registradas.',
              '• Tarjeta Activos (30 días): Personas con asistencia en el último mes.',
              '• Tarjeta Inactivos: Miembros sin actividad reciente registrada.',
              '• Gráfico de Comportamiento: Visualiza el crecimiento mensual de la iglesia.',
              '• Servicios de la Semana: Lista rápida de los próximos eventos programados.',
            ],
          ),
          _buildManualSection(
            icon: Icons.event_available,
            title: '2. Gestión de Servicios',
            content: [
              '• Botón [+ Añadir]: Abre el formulario para registrar un nuevo culto o reunión.',
              '• Icono Lápiz (Azul): Permite modificar datos de un servicio ya creado.',
              '• Icono Papelera (Rojo): Elimina el registro del servicio permanentemente.',
              '• Switch "¿Es Recurrente?": Si se activa, el sistema repetirá el evento semanalmente.',
              '• Campos Predicador/Ministro: Permiten asignar responsables específicos a cada fecha.',
            ],
          ),
          _buildManualSection(
            icon: Icons.person_add_alt_1_outlined,
            title: '3. Registro de Membresía',
            content: [
              '• Campo Nombre/Apellidos: Datos obligatorios para la identificación.',
              '• Selector de Red: Menú para asignar al hermano a un grupo (Jóvenes, Damas, etc.).',
              '• Fecha de Nacimiento: Importante para el control de edades y cumpleaños.',
              '• Botón Guardar: Procesa la información y actualiza el contador del Dashboard.',
            ],
          ),
          _buildManualSection(
            icon: Icons.fact_check_outlined,
            title: '4. Asistencia y Seguimiento',
            content: [
              '• Botón [Tomar Asistencia]: Abre la lista de miembros para marcar presentes.',
              '• Checkboxes: Casillas al lado de cada nombre para confirmar su llegada.',
              '• Contador Visitas: Campo numérico para anotar personas nuevas no registradas.',
              '• Visitas Pastorales: Registro de personas que recibieron atención especial.',
              '• Icono PDF: Genera un documento listo para imprimir con el resumen del día.',
            ],
          ),
          _buildManualSection(
            icon: Icons.account_tree_outlined,
            title: '5. Redes y Ministerios',
            content: [
              '• Tarjetas de Red: Resumen visual de líderes y cantidad de miembros por grupo.',
              '• Botón Gestionar Redes: Tabla administrativa para editar la estructura.',
              '• Campo Misión/Descripción: Define el propósito específico de cada red o ministerio.',
              '• Selección de Líderes: Permite asignar uno o varios responsables a un grupo.',
            ],
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Sistema Viento Recio v1.0 - 2026',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guía Operativa del Sistema',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Encuentra aquí el detalle de cada botón, opción y proceso del software "Viento Recio".',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSection({
    required IconData icon,
    required String title,
    required List<String> content,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        expandedAlignment: Alignment.topLeft,
        children: content
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  item,
                  style: TextStyle(color: Colors.grey[800], height: 1.4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
