import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Selector de texto libre (para preguntas tipo TEXT).
class TextQuestionSelector extends StatelessWidget {
  final TextEditingController controller;

  const TextQuestionSelector({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 2000,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isSmallScreen ? 16 : 18,
              color: MetrixTheme.dark,
            ),
            decoration: InputDecoration(
              hintText: 'Escribe tu respuesta aquí...',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: isSmallScreen ? 16 : 18,
                color: MetrixTheme.gray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
                borderSide: const BorderSide(
                  color: MetrixTheme.lightGray,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
                borderSide: const BorderSide(
                  color: MetrixTheme.lightGray,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
                borderSide: const BorderSide(
                  color: MetrixTheme.indigo,
                  width: 3,
                ),
              ),
              contentPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            ),
          ),
        );
      },
    );
  }
}
