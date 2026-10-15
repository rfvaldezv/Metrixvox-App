import 'survey_question.dart';

/// Una sección de la encuesta, con sus preguntas.
class SurveySection {
  final String name;
  final List<SurveyQuestion> questions;

  const SurveySection({
    required this.name,
    required this.questions,
  });

  factory SurveySection.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return SurveySection(
      name: json['sectionName'] as String? ?? '',
      questions: rawQuestions
          .map((q) => SurveyQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
