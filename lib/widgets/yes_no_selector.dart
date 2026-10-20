import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

/// Selector Sí/No con botones grandes (para kiosco).
class YesNoSelector extends StatelessWidget {
  final int? selectedValue; // 1 = Sí, 0 = No
  final ValueChanged<int> onSelected;

  const YesNoSelector({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final buttonHeight = isSmallScreen ? 100.0 : 140.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _YesNoButton(
              label: 'Sí',
              emoji: '👍',
              value: 1,
              isSelected: selectedValue == 1,
              onTap: () => onSelected(1),
              color: MetrixTheme.emerald,
              height: buttonHeight,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(width: isSmallScreen ? 16 : 24),
            _YesNoButton(
              label: 'No',
              emoji: '👎',
              value: 0,
              isSelected: selectedValue == 0,
              onTap: () => onSelected(0),
              color: MetrixTheme.rose,
              height: buttonHeight,
              isSmallScreen: isSmallScreen,
            ),
          ],
        );
      },
    );
  }
}

class _YesNoButton extends StatelessWidget {
  final String label;
  final String emoji;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  final double height;
  final bool isSmallScreen;

  const _YesNoButton({
    required this.label,
    required this.emoji,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.color,
    required this.height,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 28),
            border: Border.all(
              color: isSelected ? color : MetrixTheme.lightGray,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(fontSize: isSmallScreen ? 48 : 72),
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 250.ms,
                    ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isSmallScreen ? 24 : 32,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? color : MetrixTheme.dark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
