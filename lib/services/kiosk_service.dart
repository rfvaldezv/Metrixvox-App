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
  final String? kioskToken; // Solo se llena cuando la tablet se acaba de vincular

  KioskConfig({
    required this.tenantId,
    required this.surveyCode,
    required this.branchName,
    required this.kioskName,
    this.kioskToken,
  });

  factory KioskConfig.fromJson(Map<String, dynamic> json) => KioskConfig(
        tenantId: json['tenantId'] as String? ?? '',
        surveyCode: json['surveyCode'] as String? ?? '',
        branchName: json['branchName'] as String? ?? '',
        kioskName: json['kioskName'] as String? ?? '',
        kioskToken: json['kioskToken'] as String?,
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
      throw KioskException(
        'Kiosk token vacío. La tablet no está vinculada.',
        statusCode: 401,
      );
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

      // 401: El kiosco existe pero no está vinculado o el token fue revocado
      if (response.statusCode == 401) {
        throw KioskException(
          'La tablet no está vinculada o su sesión expiró.',
          statusCode: 401,
        );
      }

      if (response.statusCode == 404) {
        throw KioskException(
          'Kiosco no registrado o inactivo.',
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

  /// Vincula la tablet al kiosco usando un código de pairing.
  /// Devuelve la config con el kioskToken ya incluido.
  static Future<KioskConfig> pairDevice(String pairingCode) async {
    final uri = Uri.parse('${AppConfig.kiosksUrl}/pair');
    final body = jsonEncode({'pairingCode': pairingCode.trim().toUpperCase()});

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        return KioskConfig.fromJson(json);
      }

      if (response.statusCode == 400) {
        throw KioskException(
          'Código inválido o expirado.\nSolicita uno nuevo al administrador.',
          statusCode: 400,
        );
      }

      throw KioskException(
        'Error inesperado del servidor (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw KioskException('Tiempo de espera agotado. Verifica tu conexión.');
    } on KioskException {
      rethrow;
    } catch (e) {
      throw KioskException('Error de conexión: $e');
    }
  }
}
