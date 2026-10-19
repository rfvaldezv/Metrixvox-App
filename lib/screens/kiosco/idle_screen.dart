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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;

              final logoSize = isSmallScreen ? 100.0 : 180.0;
              final logoIconSize = isSmallScreen ? 50.0 : 80.0;
              final titleFontSize = isSmallScreen ? 36.0 : 56.0;
              final subtitleFontSize = isSmallScreen ? 16.0 : 22.0;
              final buttonFontSize = isSmallScreen ? 18.0 : 26.0;
              final buttonPaddingH = isSmallScreen ? 32.0 : 64.0;
              final buttonPaddingV = isSmallScreen ? 20.0 : 32.0;
              final verticalSpacing = isSmallScreen ? 24.0 : 48.0;
              final horizontalPadding = isSmallScreen ? 24.0 : 48.0;

              return Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Ícono animado con pulso (adaptativo)
                          Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: MetrixLogo(
                                size: logoIconSize,
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

                          SizedBox(height: verticalSpacing),

                          // Título (adaptativo)
                          Text(
                            '¡Bienvenido!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: titleFontSize,
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

                          // Subtítulo (adaptativo)
                          Text(
                            'Tu opinión nos ayuda a mejorar',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: subtitleFontSize,
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

                          SizedBox(height: verticalSpacing),

                          // Botón gigante (adaptativo)
                          _BigStartButton(
                            onTap: onStart,
                            isSmallScreen: isSmallScreen,
                            fontSize: buttonFontSize,
                            paddingH: buttonPaddingH,
                            paddingV: buttonPaddingV,
                          )
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
                  // Botón admin discreto
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _AdminButton(onTap: onAdminTap),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Botón principal gigante "TOCA PARA COMENZAR"
class _BigStartButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSmallScreen;
  final double fontSize;
  final double paddingH;
  final double paddingV;

  const _BigStartButton({
    required this.onTap,
    required this.isSmallScreen,
    required this.fontSize,
    required this.paddingH,
    required this.paddingV,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        splashColor: Colors.white.withOpacity(0.3),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: isSmallScreen ? 15 : 30,
                offset: Offset(0, isSmallScreen ? 5 : 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: isSmallScreen ? 24 : 36,
                color: MetrixTheme.indigo,
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: 1000.ms,
                  ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Text(
                'TOCA PARA COMENZAR',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: fontSize,
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

/// Botón discreto para acceder al modo administrador
class _AdminButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AdminButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
      ),
    );
  }
}
