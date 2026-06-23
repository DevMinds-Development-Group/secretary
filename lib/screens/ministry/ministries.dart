import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/ministry_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../theme/design_constants.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/nav_destinations.dart';
import '../../widgets/nav_shell.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../../widgets/states/app_skeleton.dart';
import '../../widgets/states/empty_state.dart';
import '../../widgets/states/error_state.dart';
import '../create/create_ministry.dart';
import 'ministry_members.dart';

class Ministries extends StatefulWidget {
  const Ministries({super.key});

  @override
  State<Ministries> createState() => _MinistriesState();
}

class _MinistriesState extends State<Ministries> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MinistryProvider>(context, listen: false).fetchMinistries();
      Provider.of<MemberProvider>(
        context,
        listen: false,
      ).fetchMembers(page: 0, size: 1000);
    });
  }

  Future<void> _editMinistry(MinistryModel ministry) async {
    await Navigator.push(
      context,
      createFadeRoute(CreateMinistry(ministryToEdit: ministry)),
    );
    if (mounted) context.read<MinistryProvider>().fetchMinistries();
  }

  void _confirmDelete(MinistryModel ministry) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: ministry.name,
      onConfirm: () =>
          context.read<MinistryProvider>().deleteMinistry(ministry.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final ministryProvider = context.watch<MinistryProvider>();
    final List<MinistryModel> ministries = ministryProvider.ministries;
    final permissions = UserPermissions(context.read<AuthService>());

    if (ministryProvider.error != null) {
      return NavShell(
        current: NavSection.ministries,
        title: 'Ministerios',
        body: ErrorState(
          error: ministryProvider.error,
          onRetry: () async {
            ministryProvider.clearError();

            await ministryProvider.fetchMinistries();
          },
        ),
      );
    }

    return NavShell(
      current: NavSection.ministries,
      title: 'Ministerios',
      body: ministryProvider.isLoading
          ? const AppSkeleton.grid()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isMobile),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ministries.isEmpty
                        ? EmptyState(
                            icon: Icons.diversity_3_outlined,
                            title: 'Aún no hay ministerios',
                            message: 'Crea tu primer ministerio.',
                            action: AddButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  createFadeRoute(CreateMinistry()),
                                );
                              },
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () =>
                                ministryProvider.fetchMinistries(),
                            child: GridView.builder(
                      shrinkWrap: true,
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
                      itemCount: ministries.length,
                      itemBuilder: (context, index) {
                        final ministry = ministries[index];
                        final leaderNames = ministry.leaders
                            .map(
                              (leader) =>
                                  '${leader.name} ${leader.lastName}',
                            )
                            .join(', ');
                        // final membersInNetwork = memberProvider.members
                        //     .where((m) => m.networkName == ministry.name)
                        //     .toList();
                        final memberCount = ministryProvider
                            .getMemberCountForMinistry(ministry.id);
                        return _buildMinistryCard(
                          title: ministry.name,
                          details: ministry.description,
                          leaderNames: leaderNames.isEmpty
                              ? 'Sin líderes'
                              : leaderNames,
                          icon: Icons.group,
                          memberCount: memberCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MinistryMembers(ministry: ministry),
                              ),
                            );
                          },
                          onEdit: permissions.canSeeReports
                              ? () => _editMinistry(ministry)
                              : null,
                          onDelete: permissions.canSeeReports
                              ? () => _confirmDelete(ministry)
                              : null,
                        );
                      },
                    ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMinistryCard({
    required String title,
    required String details,
    required String leaderNames,
    required IconData icon,
    required int memberCount,
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    const SizedBox(height: 4),
                    Text(
                      'Lideres: $leaderNames',
                      style:
                          const TextStyle(fontSize: 14, color: secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$memberCount Miembros',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
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
    permissions,
  ) {
    return [
      isMobile
          ? SizedBox()
          : Text(
              'Ministerios',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Figtree',
              ),
            ),
      isMobile ? const SizedBox(height: 16) : const Spacer(),
      if (permissions.canSeeReports)
        AddButton(
          onPressed: () {
            Navigator.push(context, createFadeRoute(CreateMinistry()));
          },
          size: Size(
            isMobile ? MediaQuery.of(context).size.width * 0.9 : 180,
            isMobile ? 50 : 45,
          ),
        ),
    ];
  }
}
