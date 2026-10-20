// Configuración central de la App.
// La URL de la API y el KIOSK_TOKEN pueden cambiarse al ejecutar:
//   flutter run -d chrome --dart-define=API_URL=http://localhost:5188 --dart-define=KIOSK_TOKEN=xxxxx
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
  static String get kiosksUrl => '$apiBaseUrl/api/v1/kiosks';

  // ============================================================
  // KIOSK TOKEN
  // Puede venir de --dart-define=KIOSK_TOKEN=xxxxx
  // O guardarse en shared_preferences (modo config manual)
  // ============================================================
  static const String kioskTokenFromEnv = String.fromEnvironment(
    'KIOSK_TOKEN',
    defaultValue: '',
  );

  // ============================================================
  // Claves de almacenamiento local
  // ============================================================
  static const String storageKeyKioskToken = 'metrixvox.kiosk_token';
  static const String storageKeyTenant = 'metrixvox.tenant_id';
  static const String storageKeySurvey = 'metrixvox.survey_code';

  // ============================================================
  // Timeouts
  // ============================================================
  static const Duration apiTimeout = Duration(seconds: 30);
}
