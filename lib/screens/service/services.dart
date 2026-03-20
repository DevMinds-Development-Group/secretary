import 'package:app/routes/page_route_builder.dart';
import 'package:app/screens/create/create_service.dart';
import 'package:app/widgets/add_button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';

class Services extends StatefulWidget {
  const Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  void initState() {
    super.initState();
    // Carga real desde el backend al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

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
      // Si es recurrente, usamos el campo weekDay (que es 1, 2, 3...)
      return daysMap[service.weekDay.toString()] ?? service.weekDay;
    } else {
      // Si no es recurrente, obtenemos el nombre del día a partir de la fecha
      final int dayNumber = service.date.weekday; // 1 = Lunes, 7 = Domingo
      return daysMap[dayNumber.toString()] ?? '';
    }
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
      body: isMobile
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildServicesContent(isMobile),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Menu(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: _buildServicesContent(isMobile),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTime12h(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  Widget _buildServicesContent(bool isMobile) {
    final servicesProvider = context.watch<ServiceProvider>();
    final services = servicesProvider.services;

    if (servicesProvider.isLoading && services.isEmpty) {
      return const Center(
        child: Column(
          children: [SizedBox(height: 200), CircularProgressIndicator()],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2.5,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  children: [
                    const Text(
                      'Servicios de la semana',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AddButton(
                      size: Size(MediaQuery.of(context).size.width * 0.9, 50),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          createFadeRoute(const CreateService()),
                        );
                        if (mounted) {
                          context.read<ServiceProvider>().fetchServices();
                        }
                      },
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Servicios de la semana',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        AddButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              createFadeRoute(const CreateService()),
                            );
                            if (mounted) {
                              context.read<ServiceProvider>().fetchServices();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),

              //const SizedBox(height: 16),
              const Divider(color: Colors.black, thickness: 0.3),

              if (servicesProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (servicesProvider.error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          servicesProvider.error!,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () => servicesProvider.fetchServices(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (services.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No hay servicios programados para esta semana.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.black,
                    height: 1,
                    thickness: 0.3,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  service.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      color: Colors.deepOrange.withOpacity(0.5),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${_getDisplayDay(service)} a las ${_formatTime12h(service.time)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (service.type != 'REUNION' &&
                                    service.type != 'OTRO') ...[
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.menu_book_outlined,
                                        color: Colors.cyan.withOpacity(0.5),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Predica: ',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Wrap(
                                        spacing: 5,
                                        runSpacing: isMobile ? 0 : 5,
                                        children: service.preachers.map((
                                          preacher,
                                        ) {
                                          return Chip(
                                            elevation: 5,
                                            padding: const EdgeInsets.all(4),
                                            backgroundColor: primaryColor
                                                .withOpacity(0.1),
                                            label: Text(
                                              '${service.preachers.isEmpty ? "" : service.preachers.join(", ")}',
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        color: Colors.deepPurpleAccent
                                            .withOpacity(0.5),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ministra: ',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Wrap(
                                        spacing: 5,
                                        runSpacing: isMobile ? 0 : 5,
                                        children: service.worshipMinistries.map((
                                          worship,
                                        ) {
                                          return Chip(
                                            elevation: 5,
                                            padding: const EdgeInsets.all(4),
                                            backgroundColor: primaryColor
                                                .withOpacity(0.1),
                                            label: Text(
                                              '${service.worshipMinistries.isEmpty ? "" : service.worshipMinistries.join(", ")}',
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 5),
                                if (service.description.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.description,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Descripción:  ${service.description}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue.shade700,
                                  size: 22,
                                ),
                                tooltip: 'Editar servicio',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    createFadeRoute(
                                      CreateService(serviceToEdit: service),
                                    ),
                                  );

                                  if (mounted) {
                                    await context
                                        .read<ServiceProvider>()
                                        .fetchServices();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade700,
                                  size: 22,
                                ),
                                tooltip: 'Eliminar servicio',
                                onPressed: () {
                                  showDeleteConfirmationDialog(
                                    context: context,
                                    itemName: service.title,
                                    onConfirm: () => servicesProvider
                                        .deleteService(service.id),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
