import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Vista final: comentario libre (verbatim).
class VerbatimView extends StatefulWidget {
  final TextEditingController controller;

  const VerbatimView({super.key, required this.controller});

  @override
  State<VerbatimView> createState() => _VerbatimViewState();
}

class _VerbatimViewState extends State<VerbatimView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: MetrixTheme.indigo,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

          const SizedBox(height: 24),

          const Text(
            '¿Hay algo más que nos\nquieras compartir?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: MetrixTheme.dark,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOut),

          const SizedBox(height: 16),

          const Text(
            'Opcional — tu opinión es anónima',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: MetrixTheme.gray,
            ),
          ),

          const SizedBox(height: 40),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: TextField(
              controller: widget.controller,
              maxLines: 4,
              maxLength: 2000,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: MetrixTheme.dark,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe tu comentario aquí...',
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  color: MetrixTheme.gray,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MetrixTheme.lightGray,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MetrixTheme.lightGray,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MetrixTheme.indigo,
                    width: 3,
                  ),
                ),
                contentPadding: const EdgeInsets.all(24),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
