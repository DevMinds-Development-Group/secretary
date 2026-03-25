import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/network_model.dart';
import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/add_button.dart'; // Importante para el botón superior
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../create/create_network.dart';

class NetworkManage extends StatefulWidget {
  const NetworkManage({Key? key}) : super(key: key);

  @override
  State<NetworkManage> createState() => _NetworkManageState();
}

class _NetworkManageState extends State<NetworkManage> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final List<NetworkModel> networks = networkProvider.networks;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Gestionar redes'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Botón de agregar alineado a la derecha (Web) o centro (Móvil)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: isMobile ? Alignment.center : Alignment.centerRight,
                child: AddButton(
                  size: isMobile
                      ? Size(MediaQuery.of(context).size.width * 0.9, 50)
                      : null,
                  onPressed: () => Navigator.push(
                    context,
                    createFadeRoute(const CreateNetwork()),
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 20 : 5),
            Expanded(
              child: networkProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : networks.isEmpty
                  ? const Center(child: Text('No hay redes para mostrar.'))
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildMainContent(context, isMobile, networks),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isMobile,
    List<NetworkModel> networks,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: isMobile
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMobileList(context, networks),
            )
          : CustomWebTable<NetworkModel>(
              items: networks,
              columnLabels: const ['Red', 'Misión', 'Líderes', 'Acciones'],
              columnSpacing: MediaQuery.of(context).size.width * 0.1,
              rowBuilder: (network) {
                final leaderNames = network.leaders
                    .map((l) => l.name)
                    .join(", ");
                return [
                  DataCell(
                    Text(network.name, style: const TextStyle(fontSize: 14)),
                  ),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        network.mission ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  DataCell(
                    Tooltip(
                      message: leaderNames.isEmpty
                          ? "Sin asignar"
                          : leaderNames,
                      child: SizedBox(
                        width: 250,
                        child: Text(
                          leaderNames.isEmpty ? "Sin asignar" : leaderNames,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  DataCell(_buildActions(context, network)),
                ];
              },
            ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<NetworkModel> networks) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: networks.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final network = networks[index];
        final leaderNames = network.leaders.map((l) => l.name).join(", ");

        return ListTile(
          title: Text(
            network.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Misión: ${network.mission ?? "N/A"}\nLíderes: ${leaderNames.isEmpty ? "Sin asignar" : leaderNames}',
            style: const TextStyle(fontSize: 13),
          ),
          isThreeLine: true,
          trailing: _buildActions(context, network),
        );
      },
    );
  }

  Widget _buildActions(BuildContext context, NetworkModel network) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => Navigator.push(
            context,
            createFadeRoute(CreateNetwork(networkToEdit: network)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _showDelete(context, network),
        ),
      ],
    );
  }

  void _showDelete(BuildContext context, NetworkModel network) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: network.name,
      onConfirm: () async {
        try {
          await Provider.of<NetworkProvider>(
            context,
            listen: false,
          ).deleteNetwork(network.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Red "${network.name}" eliminada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar la red'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }
}
