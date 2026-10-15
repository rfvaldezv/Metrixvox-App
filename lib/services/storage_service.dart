import 'package:shared_preferences/shared_preferences.dart';
import 'package:metrixvox_app/config/app_config.dart';

/// Servicio para persistir la configuración del dispositivo
/// (tenant activo, código de encuesta) entre sesiones.
class StorageService {
  /// Guarda el tenant y código de encuesta activos.
  static Future<void> saveConfig({
    required String tenantId,
    required String surveyCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.storageKeyTenant, tenantId);
    await prefs.setString(AppConfig.storageKeySurvey, surveyCode);
  }

  /// Carga la configuración guardada. Devuelve nulls si no existe.
  static Future<({String? tenantId, String? surveyCode})> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      tenantId: prefs.getString(AppConfig.storageKeyTenant),
      surveyCode: prefs.getString(AppConfig.storageKeySurvey),
    );
  }

  /// Limpia la configuración guardada.
  static Future<void> clearConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.storageKeyTenant);
    await prefs.remove(AppConfig.storageKeySurvey);
  }

  /// Guarda el kiosk token (para modo config manual en el futuro).
  static Future<void> saveKioskToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.storageKeyKioskToken, token);
  }

  /// Lee el kiosk token guardado.
  static Future<String?> loadKioskToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.storageKeyKioskToken);
  }

  /// Limpia el kiosk token.
  static Future<void> clearKioskToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.storageKeyKioskToken);
  }
}
