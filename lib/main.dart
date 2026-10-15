import 'package:flutter/material.dart';
import 'package:metrixvox_app/config/app_config.dart';
import 'package:metrixvox_app/screens/dashboard_screen.dart';
import 'package:metrixvox_app/screens/dynamic_survey_screen.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const TenantSelectorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Pantalla inicial de configuración de Sucursal / Tenant para la tablet o dispositivo
class TenantSelectorScreen extends StatefulWidget {
  const TenantSelectorScreen({super.key});

  @override
  State<TenantSelectorScreen> createState() => _TenantSelectorScreenState();
}

class _TenantSelectorScreenState extends State<TenantSelectorScreen> {
  final TextEditingController _tenantController = TextEditingController(text: "HOSPITAL_SAN_JOSE");
  final TextEditingController _surveyController = TextEditingController(text: "SURVEY_HOSPITAL_01");
  bool _isLoading = false;

  @override
  void dispose() {
    _tenantController.dispose();
    _surveyController.dispose();
    super.dispose();
  }

  void _cargarEncuesta() async {
    final tenantId = _tenantController.text.trim().toUpperCase();
    final surveyCode = _surveyController.text.trim();

    if (tenantId.isEmpty || surveyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el Tenant ID y el Código de Encuesta.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final surveyService = SurveyService(tenantId: tenantId);
      final surveyData = await surveyService.fetchSurvey(surveyCode);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navegar a la pantalla dinámica de la encuesta pasando los datos y el tenant
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DynamicSurveyScreen(
            surveyData: surveyData,
            tenantId: tenantId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error de Conexión"),
          content: Text("No se pudo cargar la encuesta desde ${AppConfig.apiBaseUrl}:\n$e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Aceptar"),
            )
          ],
        ),
      );
    }
  }

  void _abrirDashboard() {
    final tenantId = _tenantController.text.trim().toUpperCase();

    if (tenantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa el Tenant ID.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(tenantId: tenantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetrixVox - Terminal de Captura'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.analytics_rounded, size: 80, color: Colors.indigo),
                  const SizedBox(height: 16),
                  const Text(
                    "Configuración de Dispositivo",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _tenantController,
                    decoration: const InputDecoration(
                      labelText: "Tenant ID (Ej. HOSPITAL_SAN_JOSE)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _surveyController,
                    decoration: const InputDecoration(
                      labelText: "Código de Encuesta (Ej. SURVEY_01)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _cargarEncuesta,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Iniciar Cuestionario", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _abrirDashboard,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text("Ver Dashboard", style: TextStyle(fontSize: 16)),
                    ),
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
