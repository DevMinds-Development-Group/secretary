import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../theme/design_constants.dart';
import '../../utils/error_messages.dart';
import '../no_connection_widget.dart';
import '../retry_button.dart';

/// Estado de error reutilizable. Nunca muestra el texto crudo del provider:
/// pasa el código por [friendlyError]. Para falta de conexión delega en
/// [NoConnectionWidget].
class ErrorState extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    if (isNoConnection(error)) {
      return NoConnectionWidget(onRefresh: onRetry);
    }

    final textTheme = Theme.of(context).textTheme;
    final message = friendlyError(error) ??
        'No pudimos cargar la información. Intenta de nuevo.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: errorColor),
            const SizedBox(height: Spacing.lg),
            Text(
              'Algo salió mal',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: secondaryText),
            ),
            const SizedBox(height: Spacing.xl),
            RetryButton(onRefresh: onRetry),
          ],
        ),
      ),
    );
  }
}
