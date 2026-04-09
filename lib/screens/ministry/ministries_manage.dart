import 'package:Koinos/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/ministry_model.dart';
import '../../providers/ministry_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../create/create_ministry.dart';

class MinistryManage extends StatefulWidget {
  const MinistryManage({Key? key}) : super(key: key);

  @override
  State<MinistryManage> createState() => _MinistryManageState();
}

class _MinistryManageState extends State<MinistryManage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MinistryProvider>(context, listen: false).fetchMinistries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ministryProvider = context.watch<MinistryProvider>();
    final List<MinistryModel> ministries = ministryProvider.ministries;
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Gestionar ministerios'),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ministryProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : ministries.isEmpty
                  ? const Center(
                      child: Text('No hay ministerios para mostrar.'),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                        child: _buildMainContent(context, isMobile, ministries),
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
    List<MinistryModel> ministries,
  ) {
    return Padding(
      padding: isMobile
          ? EdgeInsets.only(left: 20, bottom: 15, right: 20)
          : EdgeInsets.all(20),
      child: isMobile
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _buildMobileList(context, ministries),
            )
          : CustomWebTable<MinistryModel>(
              items: ministries,
              columnLabels: const [
                'Ministerio',
                'Descripción',
                'Pastores',
                'Acciones',
              ],
              columnSpacing: MediaQuery.of(context).size.width * (0.7 / 7.5),
              rowBuilder: (ministry) => [
                DataCell(
                  Text(ministry.name, style: const TextStyle(fontSize: 14)),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      ministry.description,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),

                DataCell(
                  Text(
                    ministry.leaders.map((l) => l.name).join(', '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                DataCell(_buildActions(context, ministry)),
              ],
            ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<MinistryModel> ministries,
  ) {
    return Card(
      color: Colors.white,
      elevation: 5,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 5),
        itemCount: ministries.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final ministry = ministries[index];
          return ListTile(
            title: Text(
              ministry.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              ministry.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: _buildActions(context, ministry),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, MinistryModel ministry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionButtons(
          onEdit: () => Navigator.push(
            context,
            createFadeRoute(CreateMinistry(ministryToEdit: ministry)),
          ),
          onDelete: () => _showDelete(context, ministry),
        ),
      ],
    );
  }

  void _showDelete(BuildContext context, MinistryModel ministry) {
    showDeleteConfirmationDialog(
      context: context,
      itemName: ministry.name,
      onConfirm: () async {
        try {
          await Provider.of<MinistryProvider>(
            context,
            listen: false,
          ).deleteMinistry(ministry.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ministerio ${ministry.name} eliminado'),
                backgroundColor: accentColor,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el ministerio'),
                backgroundColor: negativeColor,
              ),
            );
          }
        }
      },
    );
  }
}
