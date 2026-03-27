import 'package:Koinos/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../models/user_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/add_button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_web_table.dart';
import '../../widgets/showDeleteConfirmationDialog.dart';
import '../create/create_user.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final userProvider = Provider.of<UserProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final List<User> users = userProvider.users;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Usuarios'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Botón de agregar siempre visible arriba
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: isMobile ? Alignment.center : Alignment.centerRight,
                child: AddButton(
                  size: isMobile
                      ? Size(MediaQuery.of(context).size.width * 0.9, 50)
                      : null,
                  onPressed: () => Navigator.push(
                    context,
                    createFadeRoute(const CreateUser()),
                  ),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 20 : 5),
            Expanded(
              child: userProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : userProvider.users.isEmpty
                  ? const Center(child: Text('No hay usuarios para mostrar.'))
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                        child: _buildMainContent(
                          context,
                          isMobile,
                          userProvider.users,
                          memberProvider,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildMainContent(
  BuildContext context,
  bool isMobile,
  List<User> users,
  MemberProvider memberProvider,
) {
  return Padding(
    padding: const EdgeInsets.all(0),
    child: isMobile
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMobileList(users, memberProvider),
          )
        : CustomWebTable<User>(
            items: users,
            columnLabels: [
              'Nombre de usuario',
              'Rol',
              'Miembro asociado',
              'Acciones',
            ],
            columnSpacing: MediaQuery.of(context).size.width * (0.7 / 7.5),
            rowBuilder: (user) {
              final member = user.member;
              return [
                DataCell(Text(user.username)),
                DataCell(Text(user.role)),
                DataCell(
                  Text(
                    member != null
                        ? '${member.name} ${member.lastName}'
                        : 'Sin miembro',
                  ),
                ),
                DataCell(_buildActions(context, user)),
              ];
            },
          ),
  );
}

Widget _buildMobileList(List<User> users, MemberProvider memberProvider) {
  return ListView.separated(
    padding: const EdgeInsets.all(10),
    itemCount: users.length,
    separatorBuilder: (context, index) => const Divider(),
    itemBuilder: (context, index) {
      final user = users[index];
      final member = user.member;
      return ListTile(
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Rol: ${user.role}\nMiembro: ${member != null ? "${member.name} ${member.lastName}" : "Sin asignar"}',
        ),
        trailing: _buildActions(context, user),
      );
    },
  );
}

Widget _buildActions(BuildContext context, User user) {
  return ActionButtons(
    onEdit: () =>
        Navigator.push(context, createFadeRoute(CreateUser(userToEdit: user))),
    onDelete: () => _showDelete(context, user),
  );
}

Future<void> _showDelete(BuildContext context, User user) {
  return showDeleteConfirmationDialog(
    context: context,
    itemName: user.username,
    onConfirm: () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.deleteUser(user.username);
    },
  );
}
