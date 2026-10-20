import 'package:flutter/material.dart';

/// Botón grande estilo kiosco, pensado para pantallas táctiles.
class BigButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;

  const BigButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;

    return SizedBox(
      height: 72,
      child: isPrimary
          ? ElevatedButton(
              onPressed: enabled ? onTap : null,
              child: _buildContent(),
            )
          : OutlinedButton(
              onPressed: enabled ? onTap : null,
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label),
          ),
        ),
      ],
    );
  }
}
