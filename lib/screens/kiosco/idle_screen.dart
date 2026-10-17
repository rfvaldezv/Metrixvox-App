import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/widgets/metrix_logo.dart';

/// Pantalla de bienvenida del kiosco (idle / attract screen).
/// Se muestra cuando nadie está usando la terminal.
class IdleScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onAdminTap;

  const IdleScreen({
    super.key,
    required this.onStart,
    required this.onAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: MetrixTheme.brandGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal centrado
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animado con pulso
                      Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                      child: MetrixLogo(
                        size: 70,
                        showText: false,
                        forceColor: Colors.white,
                        ),
                      ),
                    )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 48),

                      // Título
                      Text(
                        '¡Bienvenido!',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 200.ms)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOut),

                      const SizedBox(height: 16),

                      // Subtítulo
                      Text(
                        'Tu opinión nos ayuda a mejorar',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 500.ms)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOut),

                      const SizedBox(height: 64),

                      // Botón gigante
                      _BigStartButton(onTap: onStart)
                          .animate()
                          .fadeIn(duration: 800.ms, delay: 900.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón principal gigante "TOCA PARA COMENZAR"
class _BigStartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BigStartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        splashColor: Colors.white.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                size: 36,
                color: MetrixTheme.indigo,
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 1000.ms,
                  ),
              const SizedBox(width: 16),
              const Text(
                'TOCA PARA COMENZAR',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: MetrixTheme.indigo,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
