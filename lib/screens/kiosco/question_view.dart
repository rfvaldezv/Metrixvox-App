import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/models/survey_question.dart';
import 'package:metrixvox_app/widgets/star_rating.dart';

/// Vista de UNA pregunta individual. Recibe la pregunta,
/// su número, total, nombre de la sección, la respuesta actual y callback.
class QuestionView extends StatelessWidget {
  final SurveyQuestion question;
  final String sectionName;
  final int questionNumber;
  final int totalQuestions;
  final int? currentAnswer;
  final ValueChanged<int> onAnswerChanged;

  const QuestionView({
    super.key,
    required this.question,
    required this.sectionName,
    required this.questionNumber,
    required this.totalQuestions,
    required this.currentAnswer,
    required this.onAnswerChanged,
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

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Etiqueta de la sección (adaptativa)
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

              // Texto de la pregunta (adaptativo)
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

              // Opciones según tipo
              if (question.type == 'CSAT_5')
                StarRatingSelector(
                  selectedValue: currentAnswer,
                  onSelected: onAnswerChanged,
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOut)
              else
                Text(
                  'Tipo de pregunta no soportado: ${question.type}',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
