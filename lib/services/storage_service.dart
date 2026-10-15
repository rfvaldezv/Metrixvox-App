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
}
