import 'survey_section.dart';
import 'survey_question.dart';

/// Modelo completo de una encuesta con todas sus secciones y preguntas.
class Survey {
  final String surveyCode;
  final String surveyTitle;
  final String scope;
  final List<SurveySection> sections;

  const Survey({
    required this.surveyCode,
    required this.surveyTitle,
    required this.scope,
    required this.sections,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>? ?? [];
    return Survey(
      surveyCode: json['surveyCode'] as String? ?? '',
      surveyTitle: json['surveyTitle'] as String? ?? 'Encuesta',
      scope: json['scope'] as String? ?? 'Customer',
      sections: rawSections
          .map((s) => SurveySection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Aplana todas las preguntas en una sola lista (para el flujo "una a la vez").
  List<SurveyQuestion> get allQuestions {
    final questions = <SurveyQuestion>[];
    for (final section in sections) {
      questions.addAll(section.questions);
    }
    return questions;
  }

  /// Nombre de la sección a la que pertenece una pregunta por su índice.
  String sectionNameForQuestion(int index) {
    int counter = 0;
    for (final section in sections) {
      for (final _ in section.questions) {
        if (counter == index) return section.name;
        counter++;
      }
    }
    return '';
  }

  /// Total de preguntas.
  int get totalQuestions => sections.fold(0, (sum, s) => sum + s.questions.length);
}
