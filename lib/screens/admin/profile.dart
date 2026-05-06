import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/no_connection_widget.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _appVersion = "Cargando...";

  @override
  void initState() {
    super.initState();
    _getAppVersion();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);

      // authService.addListener(() {
      //   if (authService.error == "SIN_CONEXION" && mounted) {
      //     // Esto cierra el diálogo si está abierto (Navigator.pop)
      //     // Usamos canPop para no cerrar la pantalla principal por error
      //     if (Navigator.of(context).canPop()) {
      //       Navigator.of(context).pop();
      //     }
      //   }
      // });

      if (authService.userName != null) {
        authService.fetchUserProfile(authService.userName!);
      }
    });
  }

  Future<void> _getAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // Verificamos si el widget sigue presente antes de actualizar el estado
      if (!mounted) return;

      setState(() {
        _appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = "Error al cargar";
        });
      }
    }
  }

  // Diálogo de cambio de contraseña estilo "CreateUser"
  void _showChangePasswordDialog(dynamic user) {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    final _formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            scrollable: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Nueva Contraseña",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Ingresa la nueva contraseña para tu cuenta."),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'La contraseña no puede estar vacía.'
                        : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Confirmar contraseña",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Repite la contraseña.';
                      if (v != passwordController.text)
                        return 'Las contraseñas no coinciden.'; // Validación clave
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              Button(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userProvider = context.read<UserProvider>();
                    // 1. Quitamos authService de aquí si no se usa para evitar triggers extra

                    bool success = await userProvider.updateUser(
                      username: user.username,
                      password: passwordController.text,
                      roleIds: [],
                      memberId: user.memberId,
                    );

                    if (!mounted) return;

                    // 2. IMPORTANTE: Solo un Navigator.pop() para cerrar el diálogo
                    // independientemente de si falló o tuvo éxito.
                    Navigator.of(context, rootNavigator: true).pop();

                    if (success) {
                      // ÉXITO: Un solo SnackBar verde
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Contraseña actualizada con éxito"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // ERROR: Determinamos el mensaje según el tipo de error
                      String mensajeError =
                          (userProvider.error == "SIN_CONEXION")
                          ? "Sin conexión a internet. Inténtalo más tarde."
                          : (userProvider.error ?? "Error al actualizar");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(mensajeError),
                          backgroundColor: negativeColor,
                        ),
                      );

                      // 3. Si fue error de red, disparamos la actualización del perfil
                      // para que el fondo muestre el NoConnectionWidget automáticamente
                      if (userProvider.error == "SIN_CONEXION") {
                        context.read<AuthService>().fetchUserProfile(
                          user.username,
                        );
                      }
                    }
                  }
                },
                text: "Actualizar",
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;
    final authService = context.watch<AuthService>();
    final user = authService.user;

    if (authService.error == "SIN_CONEXION") {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(title: 'Perfil'),
        body: Center(
          child: NoConnectionWidget(
            onRefresh: () async {
              authService.clearError();
              await authService.fetchUserProfile(authService.userName!);
            },
          ),
        ),
      );
    }
    if (authService.isLoading || user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Perfil'),
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Perfil'),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(user, isMobile),
                      const SizedBox(height: 20.0),
                      _buildContactInfoCard(user),
                      const SizedBox(height: 15.0),
                      _buildAccountActionsCard(user),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(user, isMobile) {
    final String? memberName = user.member?.name;
    final String? memberLastName = user.member?.lastName;
    final String username = user.username ?? 'Usuario';

    // Determinamos qué inicial mostrar
    String initial = '?';
    if (memberName != null && memberName.isNotEmpty) {
      initial = memberName.substring(0, 1).toUpperCase();
    } else if (username.isNotEmpty) {
      initial = username.substring(0, 1).toUpperCase();
    }

    return Column(
      children: [
        SizedBox(height: 20),
        CircleAvatar(
          maxRadius: isMobile ? 30 : 40,
          backgroundColor: negativeColor.withOpacity(0.1),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: isMobile ? 28 : 32,
              color: negativeColor.withOpacity(0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15.0),
        Text(
          (memberName != null && memberName.isNotEmpty)
              ? "$memberName ${memberLastName ?? ''}"
              : username,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          user.username,
          style: const TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContactInfoCard(user) {
    final member = user.member;
    if (member == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Este usuario no tiene un miembro asociado."),
        ),
      );
    }

    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información personal',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            _buildInfoTile(
              Icons.phone_android_rounded,
              'Teléfono',
              member.phone ?? 'N/A',
            ),
            _buildInfoTile(
              Icons.location_on_outlined,
              'Dirección',
              member.address ?? 'N/A',
            ),
            _buildInfoTile(
              Icons.group,
              'Red Ministerial',
              member.networkName ?? 'Sin Red',
            ),
            _buildInfoTile(
              Icons.cake_outlined,
              'Cumpleaños',
              member.birthdate != null
                  ? "${member.birthdate.day}/${member.birthdate.month}/${member.birthdate.year}"
                  : 'N/A',
            ),
            _buildInfoTile(
              Icons.settings,
              'Versión de Koinos',
              'v${_appVersion}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(user) {
    final authService = context.read<AuthService>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            if (authService.error == "SIN_CONEXION") {
              await authService.fetchUserProfile(authService.userName!);
            }
            if (authService.error == "SIN_CONEXION") {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "No puedes cambiar la contraseña sin conexión a internet.",
                  ),
                  backgroundColor: negativeColor,
                ),
              );
              return;
            }
            _showChangePasswordDialog(user);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_reset_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Cambiar Contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.blueGrey, size: 22),
          ),
          const SizedBox(width: 15.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
