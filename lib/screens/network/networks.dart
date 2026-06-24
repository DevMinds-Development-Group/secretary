import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/network_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/network_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../theme/design_constants.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/body_width.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../create/create_network.dart';
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

  Future<void> _editNetwork(NetworkModel network) async {
    await Navigator.push(
      context,
      createFadeRoute(CreateNetwork(networkToEdit: network)),
    );
    if (mounted) context.read<NetworkProvider>().fetchNetworks();
  }

  void _confirmDelete(NetworkModel network) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: network.name,
      onConfirm: () =>
          context.read<NetworkProvider>().deleteNetwork(network.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    final networkProvider = context.watch<NetworkProvider>();
    final List<NetworkModel> networks = networkProvider.networks;
    final memberProvider = context.watch<MemberProvider>();
    final permissions = UserPermissions(context.read<AuthService>());

    if (networkProvider.error != null) {
      return NavShell(
        current: NavSection.networks,
        title: 'Redes',
        body: ErrorState(
          error: networkProvider.error,
          onRetry: () => networkProvider.fetchNetworks(),
        ),
      );
    }

    return NavShell(
      current: NavSection.networks,
      title: 'Redes',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: BodyWidth(child: _buildHeader(context, isMobile)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BodyWidth(
              child: networkProvider.isLoading
                  ? const AppSkeleton.grid()
                  : networks.isEmpty
                      ? EmptyState(
                          icon: Icons.hub_outlined,
                          title: 'Aún no hay redes',
                          message: 'Crea tu primera red.',
                          action: AddButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                createFadeRoute(const CreateNetwork()),
                              );
                            },
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => networkProvider.fetchNetworks(),
                          child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: isMobile
                                ? const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisExtent: 136,
                                    mainAxisSpacing: 12,
                                  )
                                : const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 400.0,
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
                              final leaderNames = network.leaders
                                  .map(
                                    (leader) =>
                                        '${leader.name} ${leader.lastName}',
                                  )
                                  .join(', ');
                              final memberCount = membersInNetwork.length;

                              return _buildGroupCard(
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
                                onEdit: permissions.canCreateMember
                                    ? () => _editNetwork(network)
                                    : null,
                                onDelete: permissions.canCreateMember
                                    ? () => _confirmDelete(network)
                                    : null,
                              );
                            },
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 20),
        ],
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
                fontFamily: 'Figtree',
              ),
            ),

      isMobile ? const SizedBox(height: 16) : const Spacer(),
      if (permissions.canCreateMember)
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
    required String leaderNames,
    required int memberCount,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alternateColor, width: 1),
            boxShadow: elevationLow,
          ),
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
                      style:
                          const TextStyle(fontSize: 14, color: secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$memberCount Miembros',
                      style:
                          const TextStyle(fontSize: 14, color: secondaryText),
                    ),
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                _cardMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardMenu({VoidCallback? onEdit, VoidCallback? onDelete}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: secondaryText),
      onSelected: (v) {
        if (v == 'edit') onEdit?.call();
        if (v == 'delete') onDelete?.call();
      },
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
        if (onDelete != null)
          const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
      ],
    );
  }
}
