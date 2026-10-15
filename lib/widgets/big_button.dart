import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/theme.dart';

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
          ? ElevatedButton.icon(
              onPressed: enabled ? onTap : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : (icon != null ? Icon(icon, size: 28) : const SizedBox.shrink()),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: enabled ? onTap : null,
              icon: icon != null
                  ? Icon(icon, size: 28, color: MetrixTheme.indigo)
                  : const SizedBox.shrink(),
              label: Text(label),
            ),
    );
  }
}
