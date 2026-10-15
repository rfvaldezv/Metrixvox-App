import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Selector de calificación 1-5 con emojis grandes y animaciones.
/// Diseñado para pantallas táctiles de kiosco.
class StarRatingSelector extends StatelessWidget {
  final int? selectedValue;
  final ValueChanged<int> onSelected;

  const StarRatingSelector({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  static const List<String> _emojis = ['😡', '🙁', '😐', '🙂', '😍'];
  static const List<String> _labels = ['Muy malo', 'Malo', 'Regular', 'Bueno', 'Excelente'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final value = index + 1;
          final isSelected = selectedValue == value;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _EmojiOption(
                emoji: _emojis[index],
                label: _labels[index],
                value: value,
                isSelected: isSelected,
                onTap: () => onSelected(value),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmojiOption extends StatelessWidget {
  final String emoji;
  final String label;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiOption({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? MetrixTheme.indigo.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? MetrixTheme.indigo : MetrixTheme.lightGray,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MetrixTheme.indigo.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 64 : 52),
            )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: isSelected ? 32 : 26,
                fontWeight: FontWeight.w700,
                color: isSelected ? MetrixTheme.indigo : MetrixTheme.gray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? MetrixTheme.indigo : MetrixTheme.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
