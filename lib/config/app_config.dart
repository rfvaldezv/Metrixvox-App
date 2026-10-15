// Configuración central de la App.
// La URL de la API puede cambiarse al ejecutar, sin tocar el código:
//   flutter run -d chrome --dart-define=API_URL=http://localhost:5188
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.metrixvox.com',
  );

  static String get surveysUrl => '$apiBaseUrl/api/v1/surveys';
  static String get dashboardUrl => '$apiBaseUrl/api/v1/dashboard';
}
