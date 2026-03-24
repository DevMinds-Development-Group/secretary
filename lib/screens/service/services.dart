import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/action_buttons.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/menu.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../create/create_service.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  // --- MÉTODOS DE FORMATO ---
  String _getDisplayDay(ServiceModel service) {
    final Map<String, String> daysMap = {
      '1': 'Lunes',
      '2': 'Martes',
      '3': 'Miércoles',
      '4': 'Jueves',
      '5': 'Viernes',
      '6': 'Sábado',
      '7': 'Domingo',
    };
    if (service.recurring) {
      return daysMap[service.weekDay.toString()] ?? service.weekDay;
    } else {
      return daysMap[service.date.weekday.toString()] ?? '';
    }
  }

  String _formatTime12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildServiceInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required List<String> items,
    required bool isMobile,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final List<Widget> children = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor.withOpacity(0.7), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      if (!isMobile) const SizedBox(width: 8) else const SizedBox(height: 4),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: items
            .map(
              (item) => Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: primaryColor.withOpacity(0.1),
                side: BorderSide.none,
                label: Text(item, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: 'Servicios',
        isDrawerEnabled: isMobile,
        showBackButton: true,
      ),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Menu(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: _buildServicesContent(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesContent(bool isMobile) {
    final servicesProvider = context.watch<ServiceProvider>();
    final services = servicesProvider.services;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          const Divider(height: 32),
          _buildListState(servicesProvider, services, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final title = const Text(
      'Servicios de la semana',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );

    final addButton = AddButton(
      onPressed: () async {
        await Navigator.push(context, createFadeRoute(const CreateService()));
        if (mounted) context.read<ServiceProvider>().fetchServices();
      },
    );

    return isMobile
        ? Column(
            children: [
              title,
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: addButton),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [title, addButton],
          );
  }

  Widget _buildListState(
    ServiceProvider provider,
    List<ServiceModel> services,
    bool isMobile,
  ) {
    if (provider.isLoading)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );

    if (provider.error != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            Text(provider.error!),
            TextButton(
              onPressed: () => provider.fetchServices(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (services.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No hay servicios programados.'),
        ),
      );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final service = services[index];
        return Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Fecha y Hora
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_getDisplayDay(service)} - ${_formatTime12h(service.time)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Predicadores (Dinámico Row/Column)
                  if (service.type != 'REUNION' && service.type != 'OTRO')
                    _buildServiceInfoRow(
                      icon: Icons.menu_book_outlined,
                      iconColor: Colors.cyan,
                      label: 'Predica:',
                      items: service.preachers.map((m) => m.name).toList(),
                      isMobile: isMobile,
                    ),

                  // Alabanza (Dinámico Row/Column)
                  _buildServiceInfoRow(
                    icon: Icons.music_note,
                    iconColor: Colors.deepPurpleAccent,
                    label: 'Ministra:',
                    items: service.worshipMinistries
                        .map((m) => m.name)
                        .toList(),
                    isMobile: isMobile,
                  ),

                  // Descripción
                  if (service.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            size: 18,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.description,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            ActionButtons(
              onEdit: () async {
                await Navigator.push(
                  context,
                  createFadeRoute(CreateService(serviceToEdit: service)),
                );
                if (mounted) context.read<ServiceProvider>().fetchServices();
              },
              onDelete: () {
                showDeleteConfirmationDialog(
                  context: context,
                  itemName: service.title,
                  onConfirm: () => provider.deleteService(service.id),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
