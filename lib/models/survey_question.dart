/// Modelo de una pregunta individual dentro de una sección.
class SurveyQuestion {
  final String id;
  final String text;
  final String type; // 'CSAT_5', 'YES_NO', 'NPS_10', 'MULTIPLE_CHOICE', 'TEXT'
  final bool isRequired;
  final double weight;
  final String? optionsJson;

  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.isRequired,
    this.weight = 1.0,
    this.optionsJson,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'CSAT_5',
      isRequired: json['isRequired'] as bool? ?? true,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      optionsJson: json['optionsJson'] as String?,
    );
  }
}
