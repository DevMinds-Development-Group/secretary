import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../routes/routes.dart';
import '../services/auth_service.dart';
import '../theme/design_constants.dart';
import '../utils/window_size.dart';
import 'member_profile_image.dart';

/// Menú de usuario en la esquina superior derecha del header (estilo "cuenta"):
/// foto + nombre + `⋮`, que despliega una tarjeta con el perfil y las acciones
/// de cuenta (perfil, manual, cerrar sesión).
class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  String _displayName(AuthService auth) {
    final member = auth.user?.member;
    if (member != null) {
      final full = '${member.name} ${member.lastName}'.trim();
      if (full.isNotEmpty) return full;
    }
    return auth.userName ?? 'Usuario';
  }

  String? _photo(AuthService auth) =>
      auth.user?.profilePictureUrl ?? auth.user?.member?.profilePictureUrl;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final textTheme = Theme.of(context).textTheme;
    final isCompact = context.isCompact;

    final name = _displayName(auth);
    final role = auth.userRole ?? '';
    final photo = _photo(auth);

    return Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: PopupMenuButton<String>(
        tooltip: 'Cuenta',
        position: PopupMenuPosition.under,
        color: secondaryBackground,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
        onSelected: (value) {
          switch (value) {
            case 'profile':
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
            case 'help':
              Navigator.pushNamed(context, AppRoutes.user_help);
              break;
            case 'logout':
              _confirmLogout(context, auth);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            enabled: false,
            child: Row(
              children: [
                MemberProfileImage(
                  imageUrl: photo,
                  name: name,
                  radius: 24,
                  squared: true,
                  borderColor: primaryColor,
                  borderWidth: 1.5,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (role.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall
                              ?.copyWith(color: secondaryText),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          _menuItem(
            value: 'profile',
            icon: Icons.person_outline,
            label: 'Mi perfil',
          ),
          _menuItem(
            value: 'help',
            icon: Icons.help_outline,
            label: 'Manual de usuario',
          ),
          _menuItem(
            value: 'logout',
            icon: Icons.logout,
            label: 'Cerrar sesión',
            color: errorColor,
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MemberProfileImage(
              imageUrl: photo,
              name: name,
              radius: 16,
              squared: true,
              borderColor: primaryColor,
              borderWidth: 1.5,
            ),
            if (!isCompact) ...[
              const SizedBox(width: Spacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(color: primaryText),
                ),
              ),
            ],
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.more_vert, color: secondaryText),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final fg = color ?? primaryText;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? secondaryText),
          const SizedBox(width: Spacing.md),
          Text(label, style: TextStyle(color: fg)),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar', textAlign: TextAlign.center),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancelar', style: TextStyle(color: secondaryText)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await authService.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.auth_wrapper,
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: errorColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
