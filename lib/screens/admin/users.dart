// En tu archivo 'users_screen.dart'
import 'package:app/colors.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/showDeleteConfirmationDialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/member_provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes/page_route_builder.dart';
import '../../widgets/add_button.dart';
import '../../widgets/button.dart';
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
      // Llamamos al provider para que inicie la carga de datos.
      Provider.of<UserProvider>(context, listen: false).fetchUsers();
      Provider.of<RoleProvider>(context, listen: false).fetchRoles();
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    //bool isMobile = MediaQuery.of(context).size.width < 700;
    final userProvider = Provider.of<UserProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final List<User> users = userProvider.users;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Usuarios'),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${userProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 45),
                  Button(
                    text: 'Reintentar',
                    onPressed: () => userProvider.fetchUsers(),
                    size: const Size(160, 45),
                  ),
                ],
              ),
            );
          }
          final users = userProvider.users;
          return RefreshIndicator(
            onRefresh: () => userProvider.fetchUsers(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth < 700
                    ? _buildMobileLayout(context, users, memberProvider)
                    : _buildWebLayout(context, users);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<User> users,
    memberProvider,
  ) {
    return Column(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.center,
            child: AddButton(
              size: Size(MediaQuery.of(context).size.width * 0.9, 50),
              onPressed: () {
                Navigator.push(context, createFadeRoute(CreateUser()));
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),

            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final associatedMember = memberProvider.findById(user.memberId);
              final String memberName = associatedMember != null
                  ? '${associatedMember.name} ${associatedMember.lastName}'
                  : 'Sin miembro asociado';

              return Card(
                margin: EdgeInsets.only(bottom: 16.0),
                child: ListTile(
                  title: Text(user.username),
                  subtitle: Column(
                    children: [
                      Text('Rol: ${user.role}'),
                      Text(
                        'Persona: $memberName',
                        style: TextStyle(
                          color: associatedMember != null
                              ? Colors.blueGrey
                              : Colors.grey,
                          fontWeight: associatedMember != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            createFadeRoute(CreateUser(userToEdit: user)),
                          );
                        },
                      ),

                      // 2. Botón de Eliminar
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ), // Ícono de eliminar
                        onPressed: () {
                          _showDelete(context, user);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context, List<User> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AddButton(
                onPressed: () {
                  Navigator.push(context, createFadeRoute(CreateUser()));
                },
              ),
              SizedBox(width: 35),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1500),
              child: Card(
                elevation: 5,
                color: Colors.white,
                child: DataTable(
                  columnSpacing: MediaQuery.of(context).size.width * 0.1,
                  columns: [
                    DataColumn(
                      label: Text('Nombre de usuario', style: _headerStyle()),
                    ),
                    DataColumn(label: Text('Rol', style: _headerStyle())),
                    DataColumn(
                      label: Text('Miembro asociado', style: _headerStyle()),
                    ),
                    DataColumn(label: Text('Acciones', style: _headerStyle())),
                  ],
                  rows: users
                      .map(
                        (user) => DataRow(
                          cells: [
                            DataCell(Text(user.username)),
                            DataCell(Text(user.role)),
                            DataCell(
                              Text(
                                user.member != null
                                    ? '${user.member!.name} ${user.member!.lastName}'
                                    : 'Sin miembro asociado',
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        createFadeRoute(
                                          CreateUser(userToEdit: user),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _showDelete(context, user);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
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

  TextStyle _headerStyle() {
    return TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
  }
}
