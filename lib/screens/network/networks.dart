import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/network_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/menu.dart';
import '../../widgets/no_connection_widget.dart';
import '../create/create_network.dart';
import 'network_manage.dart';
import 'network_members.dart';

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
      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).fetchMembers(page: 0, size: 1000);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final networkProvider = context.watch<NetworkProvider>();
    final List<NetworkModel> networks = networkProvider.networks;
    final memberProvider = context.watch<MemberProvider>();
    final permissions = UserPermissions(context.read<AuthService>());

    if (networkProvider.error == "SIN_CONEXION") {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: 'Redes', isDrawerEnabled: isMobile),
        drawer: isMobile ? const Drawer(child: Menu()) : null,
        body: Center(
          child: NoConnectionWidget(
            onRefresh: () => networkProvider.fetchNetworks(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Redes', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) Menu(),
            Expanded(
              child: networkProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context, isMobile),

                          const SizedBox(height: 24),

                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: isMobile
                                        ? 350.0
                                        : 400.0,
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: isMobile ? 10 : 20,
                                  ),
                              itemCount: networks.length,
                              itemBuilder: (context, index) {
                                final network = networkProvider.networks[index];
                                final membersInNetwork = memberProvider.members
                                    .where((m) => m.networkName == network.name)
                                    .toList();
                                final leaderNames = network.leaders
                                    .map(
                                      (leader) =>
                                          '${leader.name} ${leader.lastName}',
                                    )
                                    .join(', ');
                                final memberCount = membersInNetwork.length;

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NetworkMembers(network: network),
                                      ),
                                    );
                                  },
                                  child: _buildGroupCard(
                                    title: network.name,
                                    leaderNames: leaderNames.isEmpty
                                        ? 'Sin líderes'
                                        : leaderNames,
                                    memberCount: memberCount,
                                    icon: Icons.group,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NetworkMembers(network: network),
                                        ),
                                      );
                                    },
                                  ),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final headerItems = _buildHeaderItems(
      context,
      isMobile,
      UserPermissions(context.read<AuthService>()),
    );

    if (isMobile) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: headerItems,
      );
    }

    return Row(children: headerItems);
  }

  List<Widget> _buildHeaderItems(
    BuildContext context,
    bool isMobile,
    UserPermissions permissions,
  ) {
    return [
      isMobile
          ? SizedBox()
          : Text(
              'Redes',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),

      isMobile ? const SizedBox(height: 16) : const Spacer(),
      if (permissions.canCreateMember) ...[
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
      ],
    ];
  }

  Widget _buildGroupCard({
    required String title,
    required String leaderNames,
    required int memberCount,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Card(
      color: cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                    'Lideres: $leaderNames',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$memberCount Miembros',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
