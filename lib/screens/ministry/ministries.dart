import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/ministry_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/ministry_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../services/auth_service.dart';
import '../../utils/user_permissions.dart';
import '../../widgets/add_button.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/menu.dart';
import '../../widgets/no_connection_widget.dart';
import '../create/create_ministry.dart';
import 'ministries_manage.dart';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final ministryProvider = context.watch<MinistryProvider>();
    final List<MinistryModel> ministries = ministryProvider.ministries;
    final memberProvider = context.watch<MemberProvider>();
    // final permissions = UserPermissions(context.read<AuthService>());

    if (ministryProvider.error == "SIN_CONEXION") {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: 'Ministerios', isDrawerEnabled: isMobile),
        drawer: isMobile ? Drawer(child: Menu()) : null,
        body: Center(
          child: NoConnectionWidget(
            onRefresh: () async {
              ministryProvider.clearError();

              await ministryProvider.fetchMinistries();
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Ministerios', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMobile) Menu(),
            Expanded(
              child: ministryProvider.isLoading
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
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: isMobile
                                        ? 350.0
                                        : 400.0, // Ancho máximo de cada elemento
                                    childAspectRatio: 2.5,
                                    crossAxisSpacing:
                                        20, // Espacio entre columnas
                                    mainAxisSpacing: isMobile
                                        ? 10
                                        : 20, // Espacio entre filas
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
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MinistryMembers(ministry: ministry),
                                      ),
                                    );
                                  },
                                  child: _buildMinistryCard(
                                    title: ministry.name,
                                    details: ministry.description,
                                    leaderNames: leaderNames.isEmpty
                                        ? 'Sin líderes'
                                        : leaderNames,
                                    icon: Icons.group,
                                    memberCount: memberCount,
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

  Widget _buildMinistryCard({
    required String title,
    required String details,
    required String leaderNames,
    required IconData icon,
    required int memberCount,
  }) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lideres: $leaderNames',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$memberCount Miembros',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
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
              ),
            ),
      isMobile ? const SizedBox(height: 16) : const Spacer(),
      if (permissions.canSeeReports) ...[
        Button(
          text: 'Gestionar ministerios',
          onPressed: () {
            Navigator.push(context, createFadeRoute(MinistryManage()));
          },
          size: Size(
            isMobile ? MediaQuery.of(context).size.width * 0.9 : 230,
            isMobile ? 50 : 45,
          ),
        ),

        isMobile ? const SizedBox(height: 10) : const SizedBox(width: 15),
        AddButton(
          onPressed: () {
            Navigator.push(context, createFadeRoute(CreateMinistry()));
          },
          size: Size(
            isMobile ? MediaQuery.of(context).size.width * 0.9 : 180,
            isMobile ? 50 : 45,
          ),
        ),
      ],
    ];
  }
}
