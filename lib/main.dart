import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/app_config.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/models/survey.dart';
import 'package:metrixvox_app/screens/kiosco/error_screen.dart';
import 'package:metrixvox_app/screens/kiosco/idle_screen.dart';
import 'package:metrixvox_app/screens/kiosco/survey_flow_screen.dart';
import 'package:metrixvox_app/services/kiosk_service.dart';
import 'package:metrixvox_app/services/storage_service.dart';
import 'package:metrixvox_app/services/survey_service.dart';

void main() {
  runApp(const MetrixVoxApp());
}

class MetrixVoxApp extends StatelessWidget {
  const MetrixVoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetrixVox',
      theme: MetrixTheme.light(),
      home: const KioskRootScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Pantalla raíz del kiosco.
/// Flujo:
///   1. Obtiene el kiosk token (de env o storage)
///   2. Llama a /api/v1/kiosks/me para obtener su config
///   3. Al tocar "TOCA PARA COMENZAR", carga la encuesta
class KioskRootScreen extends StatefulWidget {
  const KioskRootScreen({super.key});

  @override
  State<KioskRootScreen> createState() => _KioskRootScreenState();
}

class _KioskRootScreenState extends State<KioskRootScreen> {
  KioskConfig? _config;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Arranca el kiosco: obtiene config y prepara todo.
  Future<void> _bootstrap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1) Obtener kiosk token (de env o storage)
      final kioskToken = await _resolveKioskToken();

      if (kioskToken.isEmpty) {
        throw KioskException(
          'Kiosco no configurado.\n'
          'Contacta al administrador para asignarte un token.',
        );
      }

      // 2) Consultar /kiosks/me
      final config = await KioskService.getMyConfig(kioskToken);

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
      });
    } on KioskException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error inesperado: $e';
        _isLoading = false;
      });
    }
  }

  /// Resuelve el token del kiosco desde:
  ///   1. --dart-define=KIOSK_TOKEN=xxxxx
  ///   2. shared_preferences (si se configuró alguna vez)
  Future<String> _resolveKioskToken() async {
    if (AppConfig.kioskTokenFromEnv.isNotEmpty) {
      return AppConfig.kioskTokenFromEnv;
    }
    return await StorageService.loadKioskToken() ?? '';
  }

  /// Botón "TOCA PARA COMENZAR": carga la encuesta y entra al flujo.
  Future<void> _onStart() async {
    if (_config == null) return;

    try {
      final surveyService = SurveyService(tenantId: _config!.tenantId);
      final raw = await surveyService.fetchSurvey(_config!.surveyCode);
     final survey = Survey.fromJson(raw);

      if (!mounted) return;

      // Capturamos el Navigator antes del push
      final navigator = Navigator.of(context);

      await navigator.push(
        MaterialPageRoute(
          builder: (routeContext) => SurveyFlowScreen(
            survey: survey,
            tenantId: _config!.tenantId,
            branchName: _config!.branchName,
            onCompleted: () {
              // Usar el Navigator capturado (siempre válido)
              debugPrint('[Main] onCompleted — popUntil ejecutado');
              navigator.popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
  } catch (e) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('No se pudo cargar la encuesta.\n\n$e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return KioskErrorScreen(
        message: _errorMessage,
        onRetry: _bootstrap,
      );
    }

    return IdleScreen(
      onStart: _onStart,
      onAdminTap: () {}, // Ya no hay panel admin en el kiosco
    );
  }
}
