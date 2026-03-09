import 'package:app/routes/page_route_builder.dart';
import 'package:app/screens/create/create_other_service.dart';
import 'package:app/screens/create/create_service.dart';
import 'package:app/widgets/add_button.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../providers/service_provider.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import 'edit_service.dart';
import 'manage_service_types.dart';

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
                      padding: const EdgeInsets.all(25.0),
                      child: _buildServicesContent(isMobile),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildServicesContent(bool isMobile) {
    final servicesProvider = Provider.of<ServiceProvider>(context);
    final upcomingServices = servicesProvider.services;

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
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2.5,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
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
                    _buildMobileButtons(),
                  ],
                )
              else
                Row(
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
                        Button(
                          size: const Size(220, 45),
                          text: 'Gestionar Servicios',
                          onPressed: () => Navigator.push(
                            context,
                            createFadeRoute(const ManageServiceTypesScreen()),
                          ),
                        ),
                        const SizedBox(width: 16),
                        AddButton(onPressed: () => _showAddOptions(context)),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 16),
              const Divider(color: Colors.black12),

              // LÓGICA DE ESTADOS (Cargando / Error / Lista)
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
              else if (upcomingServices.isEmpty)
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
                  itemCount: upcomingServices.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.grey,
                    height: 1,
                    thickness: 0.2,
                  ),
                  itemBuilder: (context, index) {
                    final service = upcomingServices[index];

                    final DateFormat dateFormatter = DateFormat(
                      'EEEE, dd \'de\' MMMM \'de\' yyyy',
                      'es',
                    );
                    final String formattedDate = dateFormatter.format(
                      service.date,
                    );
                    final String formattedTime = service.time.format(context);

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
                                Text(
                                  '$formattedDate a las $formattedTime',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Predica: ${service.preachers.isEmpty ? "Por asignar" : service.preachers.join(", ")}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                Text(
                                  'Ministra: ${service.worshipMinistries.isEmpty ? "Por asignar" : service.worshipMinistries.join(", ")}',
                                  style: const TextStyle(fontSize: 15),
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
                                onPressed: () => Navigator.push(
                                  context,
                                  createFadeRoute(
                                    EditService(serviceToEdit: service),
                                  ),
                                ),
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

  Widget _buildMobileButtons() {
    return Column(
      children: [
        Button(
          size: Size(MediaQuery.of(context).size.width * 0.9, 50),
          text: 'Gestionar Servicios',
          onPressed: () => Navigator.push(
            context,
            createFadeRoute(const ManageServiceTypesScreen()),
          ),
        ),
        const SizedBox(height: 15),
        AddButton(
          size: Size(MediaQuery.of(context).size.width * 0.9, 50),
          onPressed: () => _showAddOptions(context),
        ),
      ],
    );
  }

  void _showAddOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('¿Qué deseas crear?', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.church, color: Colors.blue),
                title: const Text('Servicio'),
                subtitle: const Text('Cultos, reuniones, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    createFadeRoute(const CreateService()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.event_note, color: Colors.orange),
                title: const Text('Otro'),
                subtitle: const Text('Eventos especiales, ensayos, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    createFadeRoute(const CreateOtherService()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
