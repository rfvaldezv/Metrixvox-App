import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/app_config.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/models/survey.dart';
import 'package:metrixvox_app/screens/kiosco/error_screen.dart';
import 'package:metrixvox_app/screens/kiosco/idle_screen.dart';
import 'package:metrixvox_app/screens/kiosco/pairing_screen.dart';
import 'package:metrixvox_app/screens/kiosco/survey_flow_screen.dart';
import 'package:metrixvox_app/services/kiosk_service.dart';
import 'package:metrixvox_app/services/storage_service.dart';
import 'package:metrixvox_app/services/survey_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

class KioskRootScreen extends StatefulWidget {
  const KioskRootScreen({super.key});

  @override
  State<KioskRootScreen> createState() => _KioskRootScreenState();
}

class _KioskRootScreenState extends State<KioskRootScreen> {
  KioskConfig? _config;
  String _errorMessage = '';
  bool _isLoading = true;
  bool _needsPairing = false;

  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _needsPairing = false;
    });

    try {
      // 1) Intentar obtener el token (Secure Storage tiene prioridad)
      String kioskToken = await _secureStorage.read(key: 'KIOSK_TOKEN') ?? '';

      // Fallback por si lo quieres seguir usando con --dart-define
      if (kioskToken.isEmpty && AppConfig.kioskTokenFromEnv.isNotEmpty) {
        kioskToken = AppConfig.kioskTokenFromEnv;
        await _secureStorage.write(key: 'KIOSK_TOKEN', value: kioskToken);
      }

      // 2) Si no hay token, mostrar pantalla de Pairing
      if (kioskToken.isEmpty) {
        if (!mounted) return;
        setState(() {
          _needsPairing = true;
          _isLoading = false;
        });
        return;
      }

      // 3) Consultar /kiosks/me
      final config = await KioskService.getMyConfig(kioskToken);

      if (!mounted) return;
      setState(() {
        _config = config;
        _isLoading = false;
        _needsPairing = false;
      });
    } on KioskException catch (e) {
      if (!mounted) return;
      
      // Si el servidor dice 401, la tablet debe re-vincularse (token revocado)
      if (e.statusCode == 401) {
        await _secureStorage.delete(key: 'KIOSK_TOKEN');
        setState(() {
          _needsPairing = true;
          _isLoading = false;
        });
        return;
      }

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

  Future<void> _onPaired(KioskConfig config) async {
    // Guardar el token devuelto por el pairing
    if (config.kioskToken != null && config.kioskToken!.isNotEmpty) {
      await _secureStorage.write(key: 'KIOSK_TOKEN', value: config.kioskToken!);
    }
    // Recargar config con el nuevo token
    await _bootstrap();
  }

  Future<void> _onStart() async {
    if (_config == null) return;

    try {
      final surveyService = SurveyService(tenantId: _config!.tenantId);
      final raw = await surveyService.fetchSurvey(_config!.surveyCode);
      final survey = Survey.fromJson(raw);

      if (!mounted) return;

      final navigator = Navigator.of(context);

      await navigator.push(
        MaterialPageRoute(
          builder: (routeContext) => SurveyFlowScreen(
            survey: survey,
            tenantId: _config!.tenantId,
            branchName: _config!.branchName,
            onCompleted: () {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_needsPairing) {
      return PairingScreen(onPaired: _onPaired);
    }

    if (_errorMessage.isNotEmpty) {
      return KioskErrorScreen(message: _errorMessage, onRetry: _bootstrap);
    }

    return IdleScreen(
      onStart: _onStart,
      onAdminTap: () {},
    );
  }
}
