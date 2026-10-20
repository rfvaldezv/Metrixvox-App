import 'package:flutter/material.dart';
import 'package:metrixvox_app/models/survey.dart';
import 'package:metrixvox_app/screens/kiosco/question_view.dart';
import 'package:metrixvox_app/screens/kiosco/thank_you_screen.dart';
import 'package:metrixvox_app/screens/kiosco/verbatim_view.dart';
import 'package:metrixvox_app/services/survey_service.dart';
import 'package:metrixvox_app/widgets/big_button.dart';
import 'package:metrixvox_app/widgets/progress_bar.dart';

/// Flujo completo del kiosco: una pregunta a la vez.
class SurveyFlowScreen extends StatefulWidget {
  final Survey survey;
  final String tenantId;
  final String? branchName;
  final VoidCallback onCompleted;

  const SurveyFlowScreen({
    super.key,
    required this.survey,
    required this.tenantId,
    this.branchName,
    required this.onCompleted,
  });

  @override
  State<SurveyFlowScreen> createState() => _SurveyFlowScreenState();
}

class _SurveyFlowScreenState extends State<SurveyFlowScreen> {
  late final List<dynamic> _questions;
  final Map<String, dynamic> _answers = {};
  final TextEditingController _verbatimController = TextEditingController();
  final Map<String, TextEditingController> _textControllers = {};

  int _currentIndex = 0;
  bool _isSubmitting = false;

  int get _totalSteps => _questions.length + 1;
  bool get _isVerbatimStep => _currentIndex == _questions.length;
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
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _next() async {
    if (_isVerbatimStep) {
      await _submit();
      return;
    }

    final q = _currentQuestion;
    if (q != null && q.isRequired && !_answers.containsKey(q.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una opcion para continuar')),
      );
      return;
    }

    setState(() => _currentIndex++);
  }

  void _previous() {
    if (_currentIndex == 0) return;
    setState(() => _currentIndex--);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final metricsPayload = <Map<String, dynamic>>[];
    String? verbatimText;

    _answers.forEach((questionId, value) {
      if (value is int) {
        metricsPayload.add({
          "category": "General",
          "metricKey": questionId,
          "numericValue": value.toDouble(),
          "weight": 1.0,
        });
      } else if (value is String && value.isNotEmpty) {
        verbatimText = value;
      }
    });

    final finalVerbatim = _verbatimController.text.trim();
    if (finalVerbatim.isNotEmpty) {
      verbatimText = verbatimText == null
          ? finalVerbatim
          : '$verbatimText | $finalVerbatim';
    }

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
        "verbatim": verbatimText ?? "",
      }
    };

    final service = SurveyService(tenantId: widget.tenantId);
    final success = await service.submitResponse(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(onComplete: widget.onCompleted),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar. Verifica la conexion.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String get _currentSection {
    if (_isVerbatimStep) return 'Comentario final';
    return widget.survey.sectionNameForQuestion(_currentIndex);
  }

  TextEditingController _getTextController(String questionId) {
    return _textControllers.putIfAbsent(
      questionId,
      () => TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            KioskProgressBar(current: _currentIndex + 1, total: _totalSteps),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _isVerbatimStep
                    ? VerbatimView(
                        key: const ValueKey('verbatim'),
                        controller: _verbatimController,
                      )
                    : SingleChildScrollView(
                        key: ValueKey('q_$_currentIndex'),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
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
                            textController: _currentQuestion?.type == 'TEXT'
                                ? _getTextController(_currentQuestion.id)
                                : null,
                          ),
                        ),
                      ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                return Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          flex: 2,
                          child: BigButton(
                            label: 'Atras',
                            icon: Icons.arrow_back_rounded,
                            onTap: _previous,
                            isPrimary: false,
                          ),
                        ),
                      if (_currentIndex > 0)
                        SizedBox(width: isSmallScreen ? 8 : 16),
                      Expanded(
                        flex: 3,
                        child: BigButton(
                          label: _isVerbatimStep ? 'Enviar opinion' : 'Continuar',
                          icon: _isVerbatimStep
                              ? Icons.send_rounded
                              : Icons.arrow_forward_rounded,
                          onTap: _next,
                          isLoading: _isSubmitting,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
