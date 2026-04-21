import 'package:Koinos/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class UserHelp extends StatelessWidget {
  const UserHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Manual de Usuario'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildManualSection(
              icon: Icons.dashboard_outlined,
              title: '1. Panel de Inicio (Dashboard)',
              content: [
                '• Tarjeta Total Miembros: Cantidad de miembros de la iglesia.',
                '• Tarjeta Activos: Personas con asistencia en los últimos 3 domingos.',
                '• Tarjeta Inactivos: Miembros ausentes más de 3 domingos.',
                '• Tarjeta Redes: Cantidad de redes de la iglesia.',
                '• Tarjeta Ministerios: Cantidad de ministerios de la iglesia.',
                '• Gráfico de Comportamiento: Visualiza el comportamiento mensual de la iglesia.',
                '• Gráfico de Actividad: Visualiza la actividad de los miembros.',
                '• Servicios de la Semana: Lista de los próximos eventos programados en la semana.',
              ],
            ),
            _buildManualSection(
              icon: Icons.event_available,
              title: '2. Servicios',
              content: [
                '• Botón [+ Añadir]: Abre el formulario para registrar un nuevo culto o reunión.',
                '• Tarjeta con cada servicio: Muestra datos importantes como nombre del servicio, fecha, hora, predicador, ministro de alabanza y alguna decsripción (Opcional).',
                '• Icono Lápiz (Azul): Permite modificar datos de un servicio ya creado.',
                '• Icono Papelera (Rojo): Elimina el registro del servicio permanentemente.',
              ],
            ),
            _buildManualSection(
              icon: Icons.edit_calendar_outlined,
              title: '2.1 Crear Servicio',
              content: [
                '• Nombre del Servicio: Título del evento (ej. Culto de Adoración o Ayuno de la Iglesia).',
                '• Descripción: Espacio para anotar algún detalle específico sobre el servicio (Opcional).',
                '• Tipo de Actividad: Menú desplegable para categorizar el evento (Culto, Reunión, Evento, etc.).',
                '• ¿Es Recurrente?: Si se activa, el sistema marcará este evento como fijo en el calendario semanal.',
                '• Fecha: Selector de calendario para definir el día exacto del evento o día semana si el evento es recurrente.',
                '• Hora de Inicio: Selector de reloj para establecer el momento exacto en que comienza la actividad.',
                '• Predicador: Campo de búsqueda para asignar al Predicador.',
                '• Ministro de Alabanza: Campo de búsqueda para registrar al Ministro de Alabanza.',
              ],
            ),
            _buildManualSection(
              icon: Icons.people_outline,
              title: '3. Miembros',
              content: [
                '• Barra de Buscar: Escribe el nombre o apellido de un miembro para encontrarlo rápidamente en la lista.',
                '• Botón [+ Añadir]: Abre el formulario para registrar a un nuevo miembro.',
                '• Tarjeta de Miembro: Muestra el nombre completo y la Red a la que pertenece (ej. Generación de Fuego).',
                '• Icono Lápiz (Azul): Permite editar la información personal, dirección o teléfono del miembro seleccionado.',
                '• Icono Papelera (Rojo): Elimina al miembro del sistema.',
              ],
            ),
            _buildManualSection(
              icon: Icons.person_add_alt_1_outlined,
              title: '3.1 Crear Miembro',
              content: [
                '• Nombre y Apellidos: Campos obligatorios para el registro.',
                '• Dirección: Espacio para registrar la dirección particular.',
                '• Teléfono: Número de contacto para comunicación directa.',
                '• Seleccionar Red: Menú desplegable para vincular al miembro con una red específica según su edad.',
                '• Fecha de Nacimiento: Al tocar el icono de calendario, permite registrar el cumpleaños.',
                '• Botón Guardar: Al presionarlo, el sistema añade oficialmente al miembro.',
              ],
            ),
            _buildManualSection(
              icon: Icons.fact_check_outlined,
              title: '4. Asistencia',
              content: [
                '• Barra de Buscar: Escribe el nombre de un evento o una red para encontrarlo rápidamente en la lista.',
                '• Selector de Fecha: Selecciona una fecha para listar los eventos de ese día específico.',
                '• Botón [Tomar Asistencia]: Abre el formulario para tomar asistencia de cada servicio.',
                '• Tarjeta de Asistencia: Muestra el nombre del servicio, la red, fecha y la asistencia detallada.',
                '• Icono PDF: Genera un documento listo para imprimir con el resumen del evento.',
                '• Icono Lápiz (Azul): Permite editar la información personal, dirección o teléfono del miembro seleccionado.',
                '• Icono Papelera (Rojo): Elimina al miembro del sistema.',
              ],
            ),
            _buildManualSection(
              icon: Icons.checklist_rtl_outlined,
              title: '4.1 Tomar Asistencia',
              content: [
                '• Seleccionar Evento: Menú desplegable para elegir el tipo de evento (ej. Tiempo de Adoración).',
                '• Todas las Redes (Filtro): Selecciona una red para tomar asistencia de sus miembros.',
                '• Contador de Visitas: Botones [+] y [-] para sumar personas que asistieron al servicio pero no son miembros registrados.',
                '• Visitas Pastorales: Botones [+] y [-] para registrar cuántos hermanos recibieron una visita pastoral.',
                '• Casillas de Verificación: Toca el cuadro a la derecha de cada nombre para marcar a la persona como "Presente".',
                '• Botón Guardar: Al presionarlo, se procesan los datos y se genera el resumen que verás en el Historial de Asistencias.',
              ],
            ),
            _buildManualSection(
              icon: Icons.groups_outlined,
              title: '5. Redes',
              content: [
                '• Tarjetas de Red: Resumen visual que muestra el nombre de la red, los líderes asignados y el total de miembros vinculados.',
                '• Botón [+ Añadir]: Abre el formulario para crear una nueva red.',
                '• Botón [Gestionar redes]: Acceso a la edición o eliminación de las redes.',
              ],
            ),
            _buildManualSection(
              icon: Icons.group,
              title: '5.1 Crear Red',
              content: [
                '• Nombre de la Red: Campo de texto para asignar el nombre de una red.',
                '• Misión/Descripción: Área para redactar el propósito, visión o los objetivos específicos que guían a esta red.',
                '• Líderes: Selector que permite asignar a los líderes responsables de pastorear la red.',
                '• Botón Guardar: Al presionarlo, el sistema guarda y lista la nueva red en el panel general de Redes.',
              ],
            ),
            _buildManualSection(
              icon: Icons.group_outlined,
              title: '5.2  Gestionar Redes',
              content: [
                '• Red: Muestra el nombre oficial de cada red registrada.',
                '• Misión: Visualiza la descripción o propósito específico asignado a cada red.',
                '• Líderes: Indica el nombre de los líderes responsables de la dirección de la red.',
                '• Botón [+ Añadir]: Permite crear una nueva red desde cero.',
                '• Icono Lápiz (Azul): Abre el formulario de edición para actualizar el nombre, la misión o los líderes de la red.',
                '• Icono Papelera (Rojo): Elimina de forma permanente la red del sistema. Se recomienda verificar que no tenga miembros activos antes de proceder.',
              ],
            ),
            _buildManualSection(
              icon: Icons.groups_outlined,
              title: '6. Ministerios',
              content: [
                '• Tarjetas de Ministerio: Resumen visual que muestra el nombre del ministerio, los líderes asignados y el total de miembros vinculados.',
                '• Botón [+ Añadir]: Abre el formulario para crear un nuevo ministerio.',
                '• Botón [Gestionar ministerios]: Acceso a la edición o eliminación de los ministerios.',
              ],
            ),
            _buildManualSection(
              icon: Icons.group,
              title: '6.1 Crear Ministerio',
              content: [
                '• Nombre del Ministerio: Campo de texto para asignar el nombre de un ministerio.',
                '• Misión/Descripción: Área para redactar el propósito, visión o los objetivos específicos que guían a este ministerio.',
                '• Líderes: Selector que permite asignar a los líderes responsables de pastorear el ministerio.',
                '• Botón Guardar: Al presionarlo, el sistema guarda y lista la nuevo ministerio en el panel general de Ministerios.',
              ],
            ),
            _buildManualSection(
              icon: Icons.group_outlined,
              title: '6.2  Gestionar Ministerios',
              content: [
                '• Red: Muestra el nombre oficial de cada ministerio registrado.',
                '• Misión: Visualiza la descripción o propósito específico asignado a cada ministerio.',
                '• Líderes: Indica el nombre de los líderes responsables de la dirección del ministerio.',
                '• Botón [+ Añadir]: Permite crear una nuevo ministerio desde cero.',
                '• Icono Lápiz (Azul): Abre el formulario de edición para actualizar el nombre, la misión o los líderes del ministerio.',
                '• Icono Papelera (Rojo): Elimina de forma permanente el ministerio del sistema. Se recomienda verificar que no tenga miembros activos antes de proceder.',
              ],
            ),
            _buildManualSection(
              icon: Icons.assessment_outlined,
              title: '7. Reportes',
              content: [
                '• Panel de Asistencias: Acceso directo para generar resúmenes detallados de la participación en los servicios.',
              ],
            ),
            _buildManualSection(
              icon: Icons.analytics_outlined,
              title: '7.1 Reportes Generales de Asistencia',
              content: [
                '• Exportar Datos: Permite generar el informe en formato PDF para el archivo físico de la iglesia.',
              ],
            ),
            _buildManualSection(
              icon: Icons.fact_check,
              title: '8. Reportes de Asistencia',
              content: [
                '• Barra de Buscar: Campo de texto para buscar los reportes por el nombre del servicio.',
                '• Fecha Inicial: Botón con icono de calendario para seleccionar desde qué fecha mostrar los reportes.',
                '• Fecha Final: Botón con icono de calendario para establecer hasta qué fecha mostrar los reportes.',
                '• Tarjeta de Asistencia General: Muestra la asistencia general de un evento y su fecha.',
                '• Icono PDF: Genera un documento listo para imprimir con el resumen de la asistencia general de un evento.',
              ],
            ),
            _buildManualSection(
              icon: Icons.person_outline,
              title: '9. Mi Perfil',
              content: [
                '• Avatar y Nombre: Muestra la imagen de perfil y el nombre completo del usuario autenticado en el sistema.',
                '• Información Personal: Tarjeta contenedora que detalla el teléfono de contacto, dirección particular y red a la que pertenece.',
                '• Fecha de Cumpleaños: Indica la fecha de nacimiento registrada del usuario.',
                '• Botón Cambiar Contraseña: Permite actualizar la contraseña del usuario.',
              ],
            ),
            _buildManualSection(
              icon: Icons.person_outline,
              title: '10. Cerrar sesión',
              content: [
                '• Permite finalizar de forma segura tu acceso al sistema para proteger la privacidad de tu cuenta y datos personales.',
              ],
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Sistema Koinos - Viento Recio - 2026',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
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
            'Encuentra aquí el detalle de cada botón, opción y proceso del software "Koinos - Viento Recio".',
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.grey[800],
                      height: 1.4,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
