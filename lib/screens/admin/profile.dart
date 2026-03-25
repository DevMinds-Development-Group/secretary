import 'package:flutter/material.dart';

import '../../widgets/custom_appbar.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Perfil'),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 500, // Ancho máximo para la vista web
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 10.0),
                _buildContactInfoCard(),
                const SizedBox(height: 15.0),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  elevation: 5,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return constraints.maxWidth < 600
                          ? _buildMobileLayout()
                          : _buildWebLayout();
                    },
                  ),
                ),
                const SizedBox(height: 15.0),
                _buildAccountActionsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget para el encabezado del perfil ---
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Imagen del perfil circular
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
            'assets/perfil.png',
          ), // Reemplaza con tu imagen
        ),
        const SizedBox(height: 10.0),
        const Text(
          'Yamilet Yero',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'yami.yero@email.com',
          style: TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'Admin',
          style: TextStyle(fontSize: 14.0, color: Colors.grey),
        ),
      ],
    );
  }

  // --- Widget para la tarjeta de información de contacto ---
  Widget _buildContactInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de Contacto',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildInfoTile(Icons.phone, 'Teléfono', '+1 (555) 123-4567'),
            _buildInfoTile(
              Icons.location_on,
              'Dirección',
              '123 Church St, Anytown, USA',
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget para la tarjeta de acciones de la cuenta ---
  Widget _buildAccountActionsCard() {
    return Card(
      color: Colors.blueAccent,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: _buildActionButton('Cambiar Contraseña', Icons.lock_outline, () {
          print('Navegar a la pantalla para cambiar la contraseña');
        }),
      ),
    );
  }

  // --- Widgets reutilizables ---

  // Para las filas de información de contacto
  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Para los botones de acción
  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            //fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          side: const BorderSide(
            color: Colors.transparent,
          ), // Quita el borde por defecto
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSettingTile('Notificaciones', Icons.notifications, true),
          _buildSettingTile('Modo Oscuro', Icons.dark_mode, false),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: SizedBox(
          width: 800,
          child: Card(
            elevation: 5,
            child: Column(
              children: [
                _buildSettingTile('Notificaciones', Icons.notifications, true),
                _buildSettingTile('Modo Oscuro', Icons.dark_mode, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, [
    bool showSwitch = false,
  ]) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      trailing: Switch(
        focusColor: Colors.cyan,
        value: true, // Debes manejar el estado con setState
        onChanged: (bool value) {
          print('Switch cambiado a $value');
        },
      ),

      onTap: () {
        print('Presionaste: $title');
      },
    );
  }
}
