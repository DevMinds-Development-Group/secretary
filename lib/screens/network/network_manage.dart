// lib/screens/network_manage.dart

import 'package:app/colors.dart';
import 'package:app/models/network_model.dart';
import 'package:app/screens/create/create_network.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';

class NetworkManage extends StatelessWidget {
  const NetworkManage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final List<NetworkModel> networks = networkProvider.networks;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Gestionar redes'),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isMobile ? 10 : 30),
            Expanded(
              child: networkProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : networks.isEmpty
                  ? const Center(child: Text('No hay redes para mostrar.'))
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildMainCard(context, isMobile, networks),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    bool isMobile,
    List<NetworkModel> networks,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isMobile
              ? _buildMobileList(context, networks)
              : CustomWebTable<NetworkModel>(
                  items: networks,
                  columnLabels: ['Red', 'Misión', 'Líderes', 'Acciones'],
                  rowBuilder: (network) => [
                    DataCell(Text(network.name)),
                    DataCell(Text(network.mission ?? 'N/A')),
                    DataCell(
                      Text(network.leaders.map((l) => l.name).join(", ")),
                    ),
                    DataCell(
                      _buildActions(context, network),
                    ), // Tu widget de botones
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<NetworkModel> networks) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: networks.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 0.7),
      itemBuilder: (context, index) {
        final network = networks[index];
        final leaderNames = network.leaders.map((l) => l.name).join(", ");

        return ListTile(
          title: Text(
            network.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Misión: ${network.mission ?? "Sin misión"}\nLíderes: ${leaderNames.isEmpty ? "Sin asignar" : leaderNames}',
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
          // Llamamos al provider para eliminar
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
                content: Text('No se pudo eliminar la red. Intente de nuevo.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  TextStyle _headerStyle() =>
      TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
}
