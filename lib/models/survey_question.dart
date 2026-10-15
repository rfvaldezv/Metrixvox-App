/// Modelo de una pregunta individual dentro de una sección.
class SurveyQuestion {
  final String id;
  final String text;
  final String type; // 'CSAT_5', 'NPS_10', 'TEXT', etc.
  final bool isRequired;

  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.isRequired,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'CSAT_5',
      isRequired: json['isRequired'] as bool? ?? true,
    );
  }
}
