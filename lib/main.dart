import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/app_config.dart';
import 'package:metrixvox_app/config/theme.dart';
import 'package:metrixvox_app/models/survey.dart';
import 'package:metrixvox_app/screens/dashboard_screen.dart';
import 'package:metrixvox_app/screens/kiosco/idle_screen.dart';
import 'package:metrixvox_app/screens/kiosco/survey_flow_screen.dart';
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

/// Pantalla raíz que decide qué mostrar según el estado de la config.
class KioskRootScreen extends StatefulWidget {
  const KioskRootScreen({super.key});

  @override
  State<KioskRootScreen> createState() => _KioskRootScreenState();
}

class _KioskRootScreenState extends State<KioskRootScreen> {
  String _tenantId = AppConfig.defaultTenantId;
  String _surveyCode = AppConfig.defaultSurveyCode;
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  Future<void> _loadSavedConfig() async {
    final config = await StorageService.loadConfig();
    if (!mounted) return;

    setState(() {
      if (config.tenantId != null && config.tenantId!.isNotEmpty) {
        _tenantId = config.tenantId!;
      }
      if (config.surveyCode != null && config.surveyCode!.isNotEmpty) {
        _surveyCode = config.surveyCode!;
      }
      _configLoaded = true;
    });
  }

  /// Botón "TOCA PARA COMENZAR" del kiosco.
  Future<void> _onStart() async {
    try {
      final surveyService = SurveyService(tenantId: _tenantId);
      final raw = await surveyService.fetchSurvey(_surveyCode);
      final survey = Survey.fromJson(raw);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SurveyFlowScreen(
            survey: survey,
            tenantId: _tenantId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error de conexión"),
          content: Text("No se pudo cargar la encuesta.\n\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  }

  /// Botón admin discreto: abre el panel de configuración.
  void _onAdminTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AdminConfigScreen(
          initialTenantId: _tenantId,
          initialSurveyCode: _surveyCode,
          onSaved: (tenant, survey) {
            setState(() {
              _tenantId = tenant;
              _surveyCode = survey;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_configLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return IdleScreen(
      onStart: _onStart,
      onAdminTap: _onAdminTap,
    );
  }
}

/// Panel de configuración accesible desde el botón admin del kiosco.
class _AdminConfigScreen extends StatefulWidget {
  final String initialTenantId;
  final String initialSurveyCode;
  final void Function(String tenant, String survey) onSaved;

  const _AdminConfigScreen({
    required this.initialTenantId,
    required this.initialSurveyCode,
    required this.onSaved,
  });

  @override
  State<_AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<_AdminConfigScreen> {
  late final TextEditingController _tenantController;
  late final TextEditingController _surveyController;

  @override
  void initState() {
    super.initState();
    _tenantController = TextEditingController(text: widget.initialTenantId);
    _surveyController = TextEditingController(text: widget.initialSurveyCode);
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _surveyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final tenant = _tenantController.text.trim().toUpperCase();
    final survey = _surveyController.text.trim();

    if (tenant.isEmpty || survey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    await StorageService.saveConfig(tenantId: tenant, surveyCode: survey);
    widget.onSaved(tenant, survey);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }

  Future<void> _openDashboard() async {
    final tenant = _tenantController.text.trim().toUpperCase();
    if (tenant.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(tenantId: tenant),
      ),
    );
  }

  Future<void> _forget() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Olvidar configuración'),
        content: const Text(
          'Se borrarán el Tenant ID y Código de Encuesta guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Olvidar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await StorageService.clearConfig();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administrador'),
        backgroundColor: MetrixTheme.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Olvidar configuración',
            onPressed: _forget,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.settings_rounded,
                    size: 64,
                    color: MetrixTheme.indigo,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuración del kiosco',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MetrixTheme.indigo,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _tenantController,
                    decoration: const InputDecoration(
                      labelText: 'Tenant ID',
                      helperText: 'Ej. HOSPITAL_SAN_JOSE',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _surveyController,
                    decoration: const InputDecoration(
                      labelText: 'Código de Encuesta',
                      helperText: 'Ej. SURVEY_HOSPITAL_01',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar configuración'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openDashboard,
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('Ver Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
