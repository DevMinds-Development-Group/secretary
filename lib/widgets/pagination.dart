import 'package:flutter/material.dart';

import '../colors.dart';
import '../theme/design_constants.dart';

/// Paginador estilo "Ant Design": Anterior · chips numerados (la página actual
/// resaltada en un recuadro azul) · elipsis · última página · Siguiente, con un
/// selector de elementos por página alineado a la derecha.
///
/// API 0-indexada en [currentPage] / [onPageChanged]; el display es 1-indexado.
class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final List<int> availableItemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPage = 10,
    this.availableItemsPerPage = const [10, 25, 50, 100],
  }) : super(key: key);

  static const double _chipSize = 36;

  /// Ventana de páginas (1-indexada). `null` representa una elipsis.
  static List<int?> _pageWindow(int total, int current) {
    if (total <= 7) {
      return [for (var i = 1; i <= total; i++) i];
    }
    if (current <= 4) {
      return [1, 2, 3, 4, 5, null, total];
    }
    if (current >= total - 3) {
      return [1, null, total - 4, total - 3, total - 2, total - 1, total];
    }
    return [1, null, current - 1, current, current + 1, null, total];
  }

  void _go(int displayPage) {
    final target = displayPage.clamp(1, totalPages == 0 ? 1 : totalPages);
    if (target - 1 != currentPage) onPageChanged(target - 1);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final total = totalPages < 1 ? 1 : totalPages;
    final current = (currentPage + 1).clamp(1, total);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Spacing.md,
        horizontal: Spacing.xs,
      ),
      child: Row(
        children: [
          if (isMobile)
            ..._buildMobileControls(context, total, current)
          else
            ..._buildDesktopControls(context, total, current),
          const Spacer(),
          if (onItemsPerPageChanged != null) _buildPerPageSelector(isMobile),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop: Anterior · chips · Siguiente
  // ---------------------------------------------------------------------------
  List<Widget> _buildDesktopControls(
    BuildContext context,
    int total,
    int current,
  ) {
    final window = _pageWindow(total, current);
    return [
      _navTextButton(
        label: 'Anterior',
        onTap: current > 1 ? () => _go(current - 1) : null,
      ),
      const SizedBox(width: Spacing.xs),
      for (final page in window) ...[
        if (page == null)
          _ellipsis()
        else
          _pageChip(page: page, selected: page == current),
        const SizedBox(width: Spacing.xs),
      ],
      _navTextButton(
        label: 'Siguiente',
        onTap: current < total ? () => _go(current + 1) : null,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Móvil: ‹ · [C] / T · ›
  // ---------------------------------------------------------------------------
  List<Widget> _buildMobileControls(
    BuildContext context,
    int total,
    int current,
  ) {
    return [
      _navIconButton(
        icon: Icons.chevron_left,
        onTap: current > 1 ? () => _go(current - 1) : null,
      ),
      const SizedBox(width: Spacing.xs),
      _pageChip(page: current, selected: true),
      const SizedBox(width: Spacing.sm),
      Text(
        '/ $total',
        style: const TextStyle(
          fontSize: 15,
          color: secondaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: Spacing.xs),
      _navIconButton(
        icon: Icons.chevron_right,
        onTap: current < total ? () => _go(current + 1) : null,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Piezas
  // ---------------------------------------------------------------------------
  Widget _pageChip({required int page, required bool selected}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selected ? null : () => _go(page),
        borderRadius: BorderRadius.circular(8),
        hoverColor: neutralContainer,
        child: Container(
          width: _chipSize,
          height: _chipSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 14,
              color: selected ? primaryColor : primaryText,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ellipsis() {
    return const SizedBox(
      width: _chipSize,
      height: _chipSize,
      child: Center(
        child: Text(
          '…',
          style: TextStyle(fontSize: 16, color: tertiaryTextColor),
        ),
      ),
    );
  }

  Widget _navTextButton({required String label, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: neutralContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? primaryColor : tertiaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIconButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: neutralContainer,
        child: Container(
          width: _chipSize,
          height: _chipSize,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 22,
            color: enabled ? primaryColor : tertiaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPerPageSelector(bool isMobile) {
    final safeValue = availableItemsPerPage.contains(itemsPerPage)
        ? itemsPerPage
        : availableItemsPerPage.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(DesignConstants.borderRadiusInput),
        border: Border.all(color: alternateColor, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: safeValue,
          isDense: true,
          borderRadius: BorderRadius.circular(DesignConstants.borderRadiusInput),
          icon: const Icon(Icons.keyboard_arrow_down, color: secondaryText),
          style: const TextStyle(
            fontSize: 14,
            color: primaryText,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            if (value != null) onItemsPerPageChanged?.call(value);
          },
          items: availableItemsPerPage.map((item) {
            return DropdownMenuItem<int>(
              value: item,
              child: Text(isMobile ? '$item' : '$item / pág'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
