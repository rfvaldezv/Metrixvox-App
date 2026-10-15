// Configuración central de la App.
// La URL de la API puede cambiarse al ejecutar, sin tocar el código:
//   flutter run -d chrome --dart-define=API_URL=http://localhost:5188
class AppConfig {
  // ============================================================
  // API
  // ============================================================
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.metrixvox.com',
  );

  static String get surveysUrl => '$apiBaseUrl/api/v1/surveys';
  static String get dashboardUrl => '$apiBaseUrl/api/v1/dashboard';

  // ============================================================
  // Defaults del Tenant Selector
  // Pueden sobreescribirse con --dart-define=TENANT_ID=OTRO
  // ============================================================
  static const String defaultTenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: 'HOSPITAL_SAN_JOSE',
  );

  static const String defaultSurveyCode = String.fromEnvironment(
    'SURVEY_CODE',
    defaultValue: 'SURVEY_HOSPITAL_01',
  );

  // ============================================================
  // Claves de almacenamiento local (shared_preferences)
  // ============================================================
  static const String storageKeyTenant = 'metrixvox.tenant_id';
  static const String storageKeySurvey = 'metrixvox.survey_code';

  // ============================================================
  // Timeouts
  // ============================================================
  static const Duration apiTimeout = Duration(seconds: 15);
}
