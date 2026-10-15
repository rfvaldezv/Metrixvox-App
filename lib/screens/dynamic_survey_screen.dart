import 'package:flutter/material.dart';
import 'package:metrixvox_app/services/survey_service.dart';

class DynamicSurveyScreen extends StatefulWidget {
  final Map<String, dynamic> surveyData;
  final String tenantId;

  const DynamicSurveyScreen({super.key, required this.surveyData, required this.tenantId});

  @override
  State<DynamicSurveyScreen> createState() => _DynamicSurveyScreenState();
}

class _DynamicSurveyScreenState extends State<DynamicSurveyScreen> {
  final Map<String, dynamic> _answers = {};
  final TextEditingController _verbatimController = TextEditingController();

  @override
  void dispose() {
    _verbatimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.surveyData['surveyTitle'] ?? 'MetrixVox Encuesta';
    final sections = widget.surveyData['sections'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sections.length + 1,
        itemBuilder: (context, index) {
          if (index < sections.length) {
            final section = sections[index];
            final questions = section['questions'] as List<dynamic>? ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['sectionName'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const Divider(),
                    ...questions.map((q) => _buildQuestionWidget(q)),
                  ],
                ),
              ),
            );
          } else {
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "¿Hay algo más que nos quiera compartir para mejorar?",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _verbatimController,
                      maxLines: 3,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        hintText: "Escriba sus comentarios aquí...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                        onPressed: _enviarRespuesta,
                        child: const Text("Enviar Opinión"),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final qId = question['id'];
    final qText = question['text'];
    final qType = question['type'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(qText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (qType == 'CSAT_5')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                int value = index + 1;
                return ChoiceChip(
                  label: Text('$value'),
                  selected: _answers[qId] == value,
                  onSelected: (selected) {
                    setState(() {
                      _answers[qId] = value;
                    });
                  },
                );
              }),
            )
          else
            Text("Tipo de pregunta no soportado: $qType", style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  void _enviarRespuesta() async {
    if (_answers.isEmpty && _verbatimController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, responde al menos una pregunta antes de enviar.')),
      );
      return;
    }

    List<Map<String, dynamic>> metricsPayload = [];
    _answers.forEach((questionId, value) {
      metricsPayload.add({
        "category": "General", // El servidor asigna la categoría real según la sección de la pregunta
        "metricKey": questionId,
        "numericValue": (value as num).toDouble(),
        "weight": 1.0
      });
    });

    final payload = {
      "tenantId": widget.tenantId,
      "surveyCode": widget.surveyData['surveyCode'] ?? "SURVEY_GENERAL",
      "respondentContext": {
        "subjectId": null,
        "branchOrLocationId": "SUCURSAL_CENTRO",
        "channel": "TABLET"
      },
      "metrics": metricsPayload,
      "sentimentAnalysis": {
        "verbatim": _verbatimController.text.trim()
      }
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );

    final surveyService = SurveyService(tenantId: widget.tenantId);
    bool success = await surveyService.submitResponse(payload);

    if (!mounted) return;
    Navigator.of(context).pop();

    if (success) {
      setState(() {
        _answers.clear();
        _verbatimController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("¡Gracias!"),
          content: const Text("Su opinión ha sido registrada con éxito en MetrixVox."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar"),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar la respuesta. Verifique su conexión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
