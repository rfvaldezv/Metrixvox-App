import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrixvox_app/config/app_config.dart';

/// Configuración que el kiosco obtiene del servidor.
class KioskConfig {
  final String tenantId;
  final String surveyCode;
  final String branchName;
  final String kioskName;

  KioskConfig({
    required this.tenantId,
    required this.surveyCode,
    required this.branchName,
    required this.kioskName,
  });

  factory KioskConfig.fromJson(Map<String, dynamic> json) => KioskConfig(
        tenantId: json['tenantId'] as String? ?? '',
        surveyCode: json['surveyCode'] as String? ?? '',
        branchName: json['branchName'] as String? ?? '',
        kioskName: json['kioskName'] as String? ?? '',
      );
}

/// Excepción específica de kiosk.
class KioskException implements Exception {
  final String message;
  final int? statusCode;

  KioskException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Servicio para obtener la configuración del kiosco desde el backend.
class KioskService {
  /// Obtiene la config del kiosco autenticándose con su token.
  static Future<KioskConfig> getMyConfig(String kioskToken) async {
    if (kioskToken.isEmpty) {
      throw KioskException('Kiosk token vacío. Contacta al administrador.');
    }

    final uri = Uri.parse('${AppConfig.kiosksUrl}/me');

    try {
      final response = await http.get(
        uri,
        headers: {'X-Kiosk-Token': kioskToken},
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        return KioskConfig.fromJson(json);
      }

      if (response.statusCode == 404) {
        throw KioskException(
          'Kiosco no registrado o inactivo.\n'
          'Verifica el token con tu administrador.',
          statusCode: 404,
        );
      }

      if (response.statusCode == 400) {
        throw KioskException(
          'El token del kiosco es obligatorio.',
          statusCode: 400,
        );
      }

      throw KioskException(
        'Error inesperado del servidor (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw KioskException(
        'Tiempo de espera agotado.\nVerifica la conexión a internet.',
      );
    } on KioskException {
      rethrow;
    } catch (e) {
      throw KioskException('Error de conexión: $e');
    }
  }
}
