import 'package:app/routes/page_route_builder.dart';
import 'package:app/screens/create/create_ministry.dart';
import 'package:app/screens/ministry/ministries_manage.dart';
import 'package:app/widgets/add_button.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/ministry_model.dart';
import '../../providers/ministry_provider.dart';
import '../../widgets/button.dart';
import '../../widgets/menu.dart';
import 'ministry_member.dart';

class Ministries extends StatefulWidget {
  const Ministries({super.key});

  @override
  State<Ministries> createState() => _MinistriesState();
}

class _MinistriesState extends State<Ministries> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<MinistryProvider>(
        context,
        listen: false,
      ).fetchMinistries(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final ministryProvider = context.watch<MinistryProvider>();
    final List<MinistryModel> ministries = ministryProvider.ministries;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Ministerios', isDrawerEnabled: isMobile),
      drawer: isMobile ? Drawer(child: Menu()) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) Menu(),
          Expanded(
            child: ministryProvider.isLoading
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
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent:
                                      350.0, // Ancho máximo de cada elemento
                                  childAspectRatio: 2.3,
                                  crossAxisSpacing:
                                      20, // Espacio entre columnas
                                  mainAxisSpacing: 20, // Espacio entre filas
                                ),
                            itemCount: ministries.length,
                            itemBuilder: (context, index) {
                              final ministry = ministries[index];
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
    );
  }

  Widget _buildMinistryCard({
    required String title,
    required String details,
    required IconData icon,
    required int memberCount,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
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
                        details,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
          ],
        ),
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
        'Ministerios',
        style: TextStyle(
          fontSize: isMobile ? 24 : 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      isMobile ? const SizedBox(height: 16) : const Spacer(),
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
    ];
  }
}
