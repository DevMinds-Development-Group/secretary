import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../colors.dart';
import '../../theme/design_constants.dart';

/// Placeholders animados (shimmer) que imitan la forma del contenido durante
/// la carga, en lugar de un spinner centrado.
class AppSkeleton extends StatelessWidget {
  /// Tipo de plantilla a renderizar.
  final _SkeletonKind _kind;
  final int count;

  const AppSkeleton._(this._kind, {this.count = 6, super.key});

  /// Lista de filas (miembros, usuarios, roles, registros…).
  const AppSkeleton.list({Key? key, int count = 6})
      : this._(_SkeletonKind.list, count: count, key: key);

  /// Cuadrícula de tarjetas (redes, ministerios, reportes, admin).
  const AppSkeleton.grid({Key? key, int count = 6})
      : this._(_SkeletonKind.grid, count: count, key: key);

  /// Tablero (tarjetas de métricas + bloque de gráfico/lista).
  const AppSkeleton.dashboard({Key? key})
      : this._(_SkeletonKind.dashboard, key: key);

  /// Formulario (campos apilados).
  const AppSkeleton.form({Key? key, int count = 5})
      : this._(_SkeletonKind.form, count: count, key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: surfaceSubtle,
      highlightColor: secondaryBackground,
      child: switch (_kind) {
        _SkeletonKind.list => _buildList(),
        _SkeletonKind.grid => _buildGrid(),
        _SkeletonKind.dashboard => _buildDashboard(),
        _SkeletonKind.form => _buildForm(),
      },
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
      itemBuilder: (_, __) => Row(
        children: [
          _box(48, 48, radius: 24),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(double.infinity, 14),
                const SizedBox(height: Spacing.sm),
                _box(160, 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(Spacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 2.2,
        mainAxisSpacing: Spacing.lg,
        crossAxisSpacing: Spacing.lg,
      ),
      itemBuilder: (_, __) => _box(double.infinity, double.infinity, radius: 12),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _box(double.infinity, 96, radius: 12),
        const SizedBox(height: Spacing.lg),
        Row(
          children: [
            Expanded(child: _box(double.infinity, 72, radius: 12)),
            const SizedBox(width: Spacing.lg),
            Expanded(child: _box(double.infinity, 72, radius: 12)),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        _box(double.infinity, 220, radius: 12),
      ],
    );
  }

  Widget _buildForm() {
    return ListView.separated(
      padding: const EdgeInsets.all(Spacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.lg),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(120, 12),
          const SizedBox(height: Spacing.sm),
          _box(double.infinity, 48, radius: 12),
        ],
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: secondaryBackground,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

enum _SkeletonKind { list, grid, dashboard, form }
