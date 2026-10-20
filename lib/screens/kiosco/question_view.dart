import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/models/survey_question.dart';
import 'package:metrixvox_app/widgets/multiple_choice_selector.dart';
import 'package:metrixvox_app/widgets/nps_selector.dart';
import 'package:metrixvox_app/widgets/star_rating.dart';
import 'package:metrixvox_app/widgets/text_question_selector.dart';
import 'package:metrixvox_app/widgets/yes_no_selector.dart';

class QuestionView extends StatelessWidget {
  final SurveyQuestion question;
  final String sectionName;
  final int questionNumber;
  final int totalQuestions;
  final dynamic currentAnswer;
  final ValueChanged<dynamic> onAnswerChanged;
  final TextEditingController? textController;

  const QuestionView({
    super.key,
    required this.question,
    required this.sectionName,
    required this.questionNumber,
    required this.totalQuestions,
    required this.currentAnswer,
    required this.onAnswerChanged,
    this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
        final questionFontSize = isSmallScreen ? 26.0 : 40.0;
        final badgeFontSize = isSmallScreen ? 11.0 : 14.0;
        final verticalSpacing = isSmallScreen ? 24.0 : 40.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 20,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: MetrixTheme.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    sectionName.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.w700,
                      color: MetrixTheme.indigo,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.3, end: 0, duration: 400.ms),
                SizedBox(height: verticalSpacing),
                Text(
                  question.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: questionFontSize,
                    fontWeight: FontWeight.w700,
                    color: MetrixTheme.dark,
                    height: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut),
                SizedBox(height: verticalSpacing),
                _buildSelector()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelector() {
    switch (question.type) {
      case 'CSAT_5':
        return StarRatingSelector(
          selectedValue: currentAnswer as int?,
          onSelected: (value) => onAnswerChanged(value),
        );
      case 'YES_NO':
        return YesNoSelector(
          selectedValue: currentAnswer as int?,
          onSelected: (value) => onAnswerChanged(value),
        );
      case 'NPS_10':
        return NpsSelector(
          selectedValue: currentAnswer as int?,
          onSelected: (value) => onAnswerChanged(value),
        );
      case 'MULTIPLE_CHOICE':
        return MultipleChoiceSelector(
          optionsJson: question.optionsJson,
          selectedValue: currentAnswer as int?,
          onSelected: (value) => onAnswerChanged(value),
        );
      case 'TEXT':
        return TextQuestionSelector(
          controller: textController ?? TextEditingController(),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MetrixTheme.rose.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Tipo de pregunta no soportado: ${question.type}',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: MetrixTheme.rose,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }
  }
}
