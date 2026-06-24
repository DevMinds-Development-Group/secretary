import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../services/auth_service.dart';
import '../theme/motion.dart';
import '../utils/user_permissions.dart';
import '../utils/window_size.dart';
import 'nav_destinations.dart';
import 'user_menu.dart';

/// Shell de navegación adaptativo (Material 3):
/// - compacto (móvil): `NavigationBar` inferior + hoja "Más".
/// - medio/expandido: `NavigationRail` lateral **colapsado** (solo iconos) que
///   se expande sobre el contenido al pasar el cursor (hover), sin reflujo.
///
/// Header minimalista claro con el logo (pantallas primarias) o flecha de
/// retroceso (pantallas de detalle, [isSecondary] = true).
class NavShell extends StatelessWidget {
  final NavSection? current;
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool isSecondary;

  const NavShell({
    super.key,
    this.current,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final permissions = UserPermissions(authService);
    final visible =
        kNavItems.where((item) => item.canSee(permissions)).toList();

    final compact = context.isCompact;
    final secondary = isSecondary || current == null;

    if (compact) {
      // Móvil: la NavigationBar inferior aparece en TODAS las pantallas
      // (incluidos formularios/detalle). En secundarias la AppBar muestra
      // back + título.
      return _buildCompact(context, visible, secondary: secondary);
    }

    // Web/expandido: el riel aparece en TODAS las pantallas (incluidos
    // formularios y detalle). En secundarias la AppBar muestra back + título.
    return _buildRail(context, visible, secondary: secondary);
  }

  // ---------------------------------------------------------------------------
  // Header (AppBar minimalista). Primario = logo; secundario = back + título.
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar({required bool primary}) {
    final trailingActions = <Widget>[
      ...?actions,
      const UserMenu(),
      const SizedBox(width: 4),
    ];

    if (!primary) {
      return AppBar(title: Text(title), actions: trailingActions);
    }
    // Navbar primaria: solo el logo (sin título), centrado sobre la columna del
    // riel (80px) para que navbar y riel se lean como una sola pieza.
    return AppBar(
      leadingWidth: 200,
      leading:
          Center(
            child: Image.asset(
              'assets/koinos-navbar.png',
              height: 90,
              fit: BoxFit.contain,
            ),
      ),
      actions: trailingActions,
    );
  }

  // ---------------------------------------------------------------------------
  // COMPACTO (móvil): barra inferior con destinos primarios + "Más".
  // ---------------------------------------------------------------------------
  Widget _buildCompact(
    BuildContext context,
    List<NavItem> visible, {
    bool secondary = false,
  }) {
    final primary = visible
        .where((i) => kNavItems.indexOf(i) < kPrimaryCount)
        .toList();
    final overflow = visible
        .where((i) => kNavItems.indexOf(i) >= kPrimaryCount)
        .toList();

    final currentInPrimary = primary.indexWhere((i) => i.id == current);
    final selectedIndex =
        currentInPrimary >= 0 ? currentInPrimary : primary.length;

    final destinations = <NavigationDestination>[
      for (final item in primary)
        NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        ),
      const NavigationDestination(
        icon: Icon(Icons.more_horiz),
        selectedIcon: Icon(Icons.more_horiz),
        label: 'Más',
      ),
    ];

    return Scaffold(
      appBar: _buildAppBar(primary: !secondary),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: DecoratedBox(
        // Sombra hacia arriba para que la barra se note elevada del contenido.
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: shadowColor, blurRadius: 8, offset: Offset(0, -2)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
          destinations: destinations,
          onDestinationSelected: (index) {
            if (index < primary.length) {
              _go(context, primary[index]);
            } else {
              _showMoreSheet(context, overflow);
            }
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MEDIO / EXPANDIDO: riel lateral colapsado con expansión al hover.
  // ---------------------------------------------------------------------------
  Widget _buildRail(
    BuildContext context,
    List<NavItem> visible, {
    bool secondary = false,
  }) {
    return Scaffold(
      appBar: _buildAppBar(primary: !secondary),
      floatingActionButton: floatingActionButton,
      body: _NavRail(
        items: visible,
        current: current,
        body: body,
        onSelect: (item) => _go(context, item),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navegación y acciones
  // ---------------------------------------------------------------------------
  void _go(BuildContext context, NavItem item) {
    if (item.id == current) return;
    Navigator.pushReplacementNamed(context, item.route);
  }

  void _showMoreSheet(
    BuildContext context,
    List<NavItem> overflow,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in overflow)
                ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  selected: item.id == current,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _go(context, item);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// Riel lateral: colapsado (solo iconos) por defecto; al hacer hover se expande
// como overlay sobre el contenido (sin reflujo) mostrando las etiquetas.
// =============================================================================
class _NavRail extends StatefulWidget {
  final List<NavItem> items;
  final NavSection? current;
  final Widget body;
  final void Function(NavItem) onSelect;

  const _NavRail({
    required this.items,
    required this.current,
    required this.body,
    required this.onSelect,
  });

  @override
  State<_NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<_NavRail> {
  bool _hovering = false;

  /// Ancho colapsado por defecto del NavigationRail M3.
  static const double _collapsedWidth = 80;

  void _setHover(bool value) {
    if (_hovering != value) setState(() => _hovering = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedIndex =
        widget.items.indexWhere((i) => i.id == widget.current);

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Capa base: reserva el ancho colapsado (sin divisor) + contenido.
        // `stretch` hace que el contenido llene toda la altura del viewport
        // aunque sea corto (p. ej. hubs de Admin/Reportes), evitando que el
        // shell y el riel se encojan al alto del contenido.
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(width: _collapsedWidth),
            Expanded(child: widget.body),
          ],
        ),
        // Capa overlay: el riel real, que se expande sobre el contenido.
        // Sombra direccional (hacia la derecha) para que riel y navbar se lean
        // como una sola pieza elevada, sin costura entre ambos.
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            onEnter: (_) => _setHover(true),
            onExit: (_) => _setHover(false),
            child: AnimatedContainer(
              duration: AppMotion.standard,
              curve: AppMotion.standardCurve,
              decoration: BoxDecoration(
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: _hovering ? 16 : 6,
                    offset: Offset(_hovering ? 4 : 2, 0),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          extended: _hovering,
                          minExtendedWidth: 240,
                          labelType: NavigationRailLabelType.none,
                          backgroundColor: scheme.surface,
                          selectedIndex:
                              selectedIndex >= 0 ? selectedIndex : null,
                          onDestinationSelected: (index) =>
                              widget.onSelect(widget.items[index]),
                          leading: const SizedBox(height: 8),
                          destinations: [
                            for (final item in widget.items)
                              NavigationRailDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(item.selectedIcon),
                                label: Text(item.label),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
