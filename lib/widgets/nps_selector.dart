import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Selector NPS (escala 0-10) para kiosco.
class NpsSelector extends StatelessWidget {
  final int? selectedValue;
  final ValueChanged<int> onSelected;

  const NpsSelector({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  Color _colorForScore(int score) {
    if (score <= 6) return MetrixTheme.rose;
    if (score <= 8) return MetrixTheme.amber;
    return MetrixTheme.emerald;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final buttonSize = isSmallScreen ? 52.0 : 68.0;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: isSmallScreen ? 8 : 12,
          runSpacing: isSmallScreen ? 8 : 12,
          children: List.generate(11, (score) {
            final isSelected = selectedValue == score;
            final color = _colorForScore(score);

            return GestureDetector(
              onTap: () => onSelected(score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  border: Border.all(
                    color: isSelected ? color : MetrixTheme.lightGray,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: isSmallScreen ? 22 : 28,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 200.ms,
                  ),
            );
          }),
        );
      },
    );
  }
}
