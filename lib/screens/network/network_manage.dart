import 'package:Koinos/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/network_model.dart';
import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
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
            SizedBox(height: isMobile ? 20 : 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: networkProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : networks.isEmpty
                  ? const Center(child: Text('No hay redes para mostrar.'))
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
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
      padding: const EdgeInsets.all(0),
      child: isMobile
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMobileList(context, networks),
            )
          : CustomWebTable<NetworkModel>(
              items: networks,
              columnLabels: const ['Red', 'Misión', 'Líderes', 'Acciones'],
              columnSpacing: MediaQuery.of(context).size.width * (0.7 / 7.5),
              rowBuilder: (network) {
                final leaderNames = network.leaders
                    .map((l) => l.name)
                    .join(", ");
                return [
                  DataCell(
                    Text(network.name, style: const TextStyle(fontSize: 14)),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        network.mission ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      leaderNames.isEmpty ? "Sin asignar" : leaderNames,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  DataCell(_buildActions(context, network)),
                ];
              },
            ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<NetworkModel> networks) {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 5, top: 5),
        itemCount: networks.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final network = networks[index];
          final leaderNames = network.leaders.map((l) => l.name).join(", ");

          return ListTile(
            title: Text(
              network.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Misión: ${network.mission ?? "N/A"}\nLíderes: ${leaderNames.isEmpty ? "Sin asignar" : leaderNames}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Align(
                  child: _buildActions(context, network),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, NetworkModel network) {
    return ActionButtons(
      onEdit: () => Navigator.push(
        context,
        createFadeRoute(CreateNetwork(networkToEdit: network)),
      ),
      onDelete: () => _showDelete(context, network),
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
                backgroundColor: negativeColor,
              ),
            );
          }
        }
      },
    );
  }
}
