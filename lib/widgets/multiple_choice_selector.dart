import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Selector de opcion multiple (basado en optionsJson).
class MultipleChoiceSelector extends StatelessWidget {
  final String? optionsJson;
  final int? selectedValue;
  final ValueChanged<int> onSelected;

  const MultipleChoiceSelector({
    super.key,
    required this.optionsJson,
    required this.selectedValue,
    required this.onSelected,
  });

  List<String> _parseOptions() {
    if (optionsJson == null || optionsJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(optionsJson!);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final options = _parseOptions();

    if (options.isEmpty) {
      return const Text(
        'Esta pregunta no tiene opciones configuradas.',
        style: TextStyle(color: MetrixTheme.rose),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Column(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              final isSelected = selectedValue == index;

              return Padding(
                padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 14),
                child: GestureDetector(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: isSmallScreen ? 16 : 20,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MetrixTheme.indigo.withOpacity(0.15)
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(isSmallScreen ? 12 : 16),
                      border: Border.all(
                        color: isSelected
                            ? MetrixTheme.indigo
                            : MetrixTheme.lightGray,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: MetrixTheme.indigo.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 32 : 40,
                          height: isSmallScreen ? 32 : 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MetrixTheme.indigo
                                : MetrixTheme.lightGray,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : MetrixTheme.gray,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? MetrixTheme.indigo
                                  : MetrixTheme.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(target: isSelected ? 1 : 0)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                        duration: 200.ms,
                      ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
