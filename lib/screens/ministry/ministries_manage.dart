import 'package:app/colors.dart';
import 'package:app/providers/ministry_provider.dart';
import 'package:app/screens/create/create_ministry.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ministry_model.dart';
import '../../providers/leader_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';

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
    final leaderProvider = context.watch<LeaderProvider>();
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Gestionar ministerios'),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: ministryProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ministries.isEmpty
                ? const Center(child: Text('No hay ministerios para mostrar.'))
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: _buildMainCard(context, isMobile, ministries),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    bool isMobile,
    List<MinistryModel> ministries,
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
              ? _buildMobileList(context, ministries)
              : _buildWebTable(context, ministries),
        ),
      ),
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<MinistryModel> ministries,
    // PastorProvider pastorProvider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(10.0),
      itemCount: ministries.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 0.1),
      itemBuilder: (context, index) {
        final ministry = ministries[index];

        return ListTile(
          title: Text(
            ministry.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ministry.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Text(
              //   'Pastores: ${leaderProvider.getleaderNamesByIds(ministry.leaders)}',
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
          trailing: _buildActions(context, ministry),
          //onTap: () {},
        );
      },
    );
  }

  Widget _buildWebTable(
    BuildContext context,
    List<MinistryModel> ministries,
    //PastorProvider pastorProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: DataTable(
          // headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
          columnSpacing: MediaQuery.of(context).size.width * 0.1,
          columns: [
            DataColumn(label: Text('Ministerio', style: _headerStyle())),
            DataColumn(label: Text('Detalles', style: _headerStyle())),
            DataColumn(label: Text('Pastores', style: _headerStyle())),
            DataColumn(label: Text('Acciones', style: _headerStyle())),
          ],
          rows: ministries.map((ministry) {
            // final pastorNames = pastorProvider.getPastorNamesByIds
            (ministry.leaders);
            return DataRow(
              cells: [
                DataCell(Text(ministry.name)),
                DataCell(Text(ministry.description)),
                DataCell(
                  Tooltip(
                    message: 'Pastores',
                    child: Text(
                      ministry.leaders.map((l) => l.name).join(', '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_buildActions(context, ministry)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, MinistryModel ministry) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
          onPressed: () => Navigator.push(
            context,
            createFadeRoute(CreateMinistry(ministryToEdit: ministry)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => _showDelete(context, ministry),
        ),
      ],
    );
  }

  Future<void> _showDelete(BuildContext context, MinistryModel ministry) {
    return showDeleteConfirmationDialog(
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
                content: Text(
                  'Ministerio ${ministry.name} eliminado con éxito',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo eliminar el ministerio.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          ;
        }
        ;
      },
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.blue[900],
    );
  }
}
