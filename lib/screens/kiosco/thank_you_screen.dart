import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Pantalla de agradecimiento con confetti y auto-retorno.
class ThankYouScreen extends StatefulWidget {
  final Duration autoReturnDuration;
  final VoidCallback onComplete;

  const ThankYouScreen({
    super.key,
    this.autoReturnDuration = const Duration(seconds: 4),
    required this.onComplete,
  });

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  late final ConfettiController _confettiController;
  Timer? _returnTimer;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    _returnTimer = Timer(widget.autoReturnDuration, () {
        if (!mounted) return;
        // Ejecutar el callback en el siguiente frame para evitar
        // problemas de rebuild durante la animación
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onComplete();
        });
    });
  }

  @override
  void dispose() {
    _returnTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: MetrixTheme.successGradient,
        ),
        child: Stack(
          children: [
            // Confetti arriba
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.white,
                  Color(0xFFFCD34D),
                  Color(0xFF34D399),
                  Color(0xFF60A5FA),
                  Color(0xFFF472B6),
                ],
                numberOfParticles: 40,
                maxBlastForce: 40,
                minBlastForce: 10,
              ),
            ),

            // Contenido
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Check animado
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .then()
                        .shake(duration: 400.ms, hz: 3),

                    const SizedBox(height: 48),

                    const Text(
                      '¡Muchas gracias!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 300.ms)
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut),

                    const SizedBox(height: 16),

                    Text(
                      'Tu opinión hace la diferencia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 600.ms)
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut),

                    const SizedBox(height: 80),

                    // Indicador de auto-retorno
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Volviendo al inicio...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
