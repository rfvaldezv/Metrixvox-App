import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final emojiSize = isSmallScreen ? 36.0 : 52.0;
        final selectedEmojiSize = isSmallScreen ? 44.0 : 64.0;
        final numberSize = isSmallScreen ? 22.0 : 32.0;
        final numberSizeSmall = isSmallScreen ? 18.0 : 26.0;
        final labelSize = isSmallScreen ? 9.0 : 13.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final value = index + 1;
              final isSelected = selectedValue == value;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
                  child: GestureDetector(
                    onTap: () => onSelected(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 10 : 20,
                        horizontal: isSmallScreen ? 4 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? MetrixTheme.indigo.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 20),
                        border: Border.all(
                          color: isSelected ? MetrixTheme.indigo : MetrixTheme.lightGray,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: MetrixTheme.indigo.withOpacity(0.3),
                                  blurRadius: isSmallScreen ? 10 : 20,
                                  offset: Offset(0, isSmallScreen ? 4 : 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _emojis[index],
                            style: TextStyle(
                              fontSize: isSelected ? selectedEmojiSize : emojiSize,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 4 : 12),
                          Text(
                            '$value',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: isSelected ? numberSize : numberSizeSmall,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? MetrixTheme.indigo : MetrixTheme.gray,
                            ),
                          ),
                          if (!isSmallScreen) ...[
                            const SizedBox(height: 4),
                            Text(
                              _labels[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: labelSize,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? MetrixTheme.indigo : MetrixTheme.gray,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
