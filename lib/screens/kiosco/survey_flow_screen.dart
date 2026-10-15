import 'package:flutter/material.dart';
import 'package:metrixvox_app/models/survey.dart';
import 'package:metrixvox_app/screens/kiosco/question_view.dart';
import 'package:metrixvox_app/screens/kiosco/thank_you_screen.dart';
import 'package:metrixvox_app/screens/kiosco/verbatim_view.dart';
import 'package:metrixvox_app/services/survey_service.dart';
import 'package:metrixvox_app/widgets/big_button.dart';
import 'package:metrixvox_app/widgets/progress_bar.dart';

/// Flujo completo del kiosco: una pregunta a la vez, con animaciones,
/// barra de progreso y pantalla final de agradecimiento.
class SurveyFlowScreen extends StatefulWidget {
  final Survey survey;
  final String tenantId;
  final String? branchName;
  final VoidCallback onCompleted;   // 🆕

  const SurveyFlowScreen({
    super.key,
    required this.survey,
    required this.tenantId,
    this.branchName,
    required this.onCompleted,      // 🆕
  });

  @override
  State<SurveyFlowScreen> createState() => _SurveyFlowScreenState();
}

class _SurveyFlowScreenState extends State<SurveyFlowScreen> {
  late final List<dynamic> _questions;
  final Map<String, int> _answers = {};
  final TextEditingController _verbatimController = TextEditingController();

  int _currentIndex = 0;
  bool _isSubmitting = false;

  /// Total de "pasos": N preguntas + 1 paso de verbatim.
  int get _totalSteps => _questions.length + 1;

  /// True si estamos en el paso de verbatim (último).
  bool get _isVerbatimStep => _currentIndex == _questions.length;

  /// Pregunta actual (null si estamos en verbatim).
  dynamic get _currentQuestion =>
      _isVerbatimStep ? null : _questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _questions = widget.survey.allQuestions;
  }

  @override
  void dispose() {
    _verbatimController.dispose();
    super.dispose();
  }

  /// Avanza al siguiente paso o envía si es el último.
  Future<void> _next() async {
    if (_isVerbatimStep) {
      await _submit();
      return;
    }

    // Validar que la pregunta actual tenga respuesta
    final q = _currentQuestion;
    if (q != null && q.isRequired && !_answers.containsKey(q.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una opción para continuar')),
      );
      return;
    }

    setState(() => _currentIndex++);
  }

  /// Retrocede un paso.
  void _previous() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex--);
  }

  /// Envía la respuesta completa al backend.
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    // Construir payload de métricas
    final metricsPayload = <Map<String, dynamic>>[];
    _answers.forEach((questionId, value) {
      metricsPayload.add({
        "category": "General",
        "metricKey": questionId,
        "numericValue": value.toDouble(),
        "weight": 1.0,
      });
    });

    final payload = {
      "tenantId": widget.tenantId,
      "surveyCode": widget.survey.surveyCode,
      "respondentContext": {
      "subjectId": null,
      "branchOrLocationId": widget.branchName ?? "SUCURSAL_CENTRO",
      "channel": "TABLET",
      },
      "metrics": metricsPayload,
      "sentimentAnalysis": {
      "verbatim": _verbatimController.text.trim(),
      }
    };

    final service = SurveyService(tenantId: widget.tenantId);
    final success = await service.submitResponse(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      // Ir a la pantalla de agradecimiento
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => ThankYouScreen(
                  onComplete: widget.onCompleted,  // ← llama al callback del padre
              ),
          ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar. Verifica la conexión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Texto de la sección actual.
  String get _currentSection {
    if (_isVerbatimStep) return 'Comentario final';
    return widget.survey.sectionNameForQuestion(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso superior
            KioskProgressBar(
              current: _currentIndex + 1,
              total: _totalSteps,
            ),

            // Contenido principal con transición
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _isVerbatimStep
                    ? VerbatimView(
                        key: const ValueKey('verbatim'),
                        controller: _verbatimController,
                      )
                    : SingleChildScrollView(
                        key: ValueKey('q_$_currentIndex'),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: QuestionView(
                            question: _currentQuestion,
                            sectionName: _currentSection,
                            questionNumber: _currentIndex + 1,
                            totalQuestions: _questions.length,
                            currentAnswer: _answers[_currentQuestion?.id],
                            onAnswerChanged: (value) {
                              setState(() {
                                _answers[_currentQuestion.id] = value;
                              });
                            },
                          ),
                        ),
                      ),
              ),
            ),

            // Controles inferiores
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  // Botón atrás (solo si no estamos en la primera)
                  if (_currentIndex > 0)
                    Expanded(
                      flex: 1,
                      child: BigButton(
                        label: 'Atrás',
                        icon: Icons.arrow_back_rounded,
                        onTap: _previous,
                        isPrimary: false,
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 16),

                  // Botón continuar / enviar
                  Expanded(
                    flex: 2,
                    child: BigButton(
                      label: _isVerbatimStep
                          ? 'Enviar opinión'
                          : (_currentIndex == _questions.length - 1
                              ? 'Continuar'
                              : 'Continuar'),
                      icon: _isVerbatimStep
                          ? Icons.send_rounded
                          : Icons.arrow_forward_rounded,
                      onTap: _next,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
