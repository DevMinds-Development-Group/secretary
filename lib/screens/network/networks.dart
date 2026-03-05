import 'package:app/routes/page_route_builder.dart';
import 'package:app/screens/create/create_network.dart';
import 'package:app/screens/network/network_manage.dart';
import 'package:app/widgets/add_button.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/network_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../widgets/menu.dart';
import 'network_detail.dart';

class Networks extends StatefulWidget {
  const Networks({super.key});

  @override
  State<Networks> createState() => _NetworksState();
}

class _NetworksState extends State<Networks> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NetworkProvider>(context, listen: false).fetchNetworks();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final networkProvider = context.watch<NetworkProvider>();
    final List<NetworkModel> networks = networkProvider.networks;
    final memberProvider = context.watch<MemberProvider>();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Redes', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Menu(),
          Expanded(
            child: networkProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isMobile),

                        const SizedBox(height: 24),

                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350.0,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                            itemCount: networks.length,
                            itemBuilder: (context, index) {
                              final network = networkProvider.networks[index];
                              final membersInNetwork = memberProvider.members
                                  .where((m) => m.networkName == network.name)
                                  .toList();
                              final memberCount = membersInNetwork.length;

                              return _buildGroupCard(
                                title: network.name,
                                memberCount: memberCount,
                                icon: Icons.group,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NetworkDetail(network: network),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final headerItems = _buildHeaderItems(context, isMobile);

    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: headerItems,
      );
    }

    return Row(children: headerItems);
  }

  List<Widget> _buildHeaderItems(BuildContext context, bool isMobile) {
    return [
      Text(
        'Redes',
        style: TextStyle(
          fontSize: isMobile ? 24 : 28,
          fontWeight: FontWeight.bold,
        ),
      ),

      isMobile ? const SizedBox(height: 16) : const Spacer(),

      Button(
        text: 'Gestionar redes',
        onPressed: () {
          Navigator.push(context, createFadeRoute(const NetworkManage()));
        },
        size: Size(
          isMobile ? MediaQuery.of(context).size.width * 0.9 : 180,
          isMobile ? 50 : 45,
        ),
      ),

      isMobile ? const SizedBox(height: 10) : const SizedBox(width: 15),
      AddButton(
        size: Size(
          isMobile ? MediaQuery.of(context).size.width * 0.9 : 180,
          isMobile ? 50 : 45,
        ),
        onPressed: () {
          Navigator.push(context, createFadeRoute(const CreateNetwork()));
        },
      ),
    ];
  }

  Widget _buildGroupCard({
    required String title,
    required int memberCount,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$memberCount Miembros',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
