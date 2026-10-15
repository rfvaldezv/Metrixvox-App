import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Barra de progreso superior del flujo de encuesta.
class KioskProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const KioskProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pregunta $current de $total',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MetrixTheme.gray,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MetrixTheme.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 12,
              color: MetrixTheme.lightGray,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: const BoxDecoration(
                    gradient: MetrixTheme.brandGradient,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
