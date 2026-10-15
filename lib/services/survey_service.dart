import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrixvox_app/config/app_config.dart';

/// Excepción personalizada con mensaje amigable y código HTTP opcional.
class SurveyException implements Exception {
  final String message;
  final int? statusCode;

  SurveyException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SurveyService {
  // Identificador del cliente (tenant) activo, ej. 'HOSPITAL_SAN_JOSE'
  final String tenantId;

  SurveyService({required this.tenantId});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "X-Tenant-Id": tenantId,
      };

  // Obtiene la estructura dinámica de la encuesta
  Future<Map<String, dynamic>> fetchSurvey(String surveyCode) async {
    final uri = Uri.parse(
        '${AppConfig.surveysUrl}/${Uri.encodeComponent(surveyCode)}');

    try {
      final response =
          await http.get(uri, headers: _headers).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      }
      if (response.statusCode == 404) {
        throw SurveyException(
          'La encuesta "$surveyCode" no existe para este cliente.\n'
          'Verifica el Tenant ID y el Código de Encuesta.',
          statusCode: 404,
        );
      }
      if (response.statusCode == 400) {
        throw SurveyException(
          'Solicitud inválida. Verifica el header X-Tenant-Id.',
          statusCode: 400,
        );
      }
      if (response.statusCode >= 500) {
        throw SurveyException(
          'Error del servidor (${response.statusCode}). '
          'Intenta de nuevo en unos minutos.',
          statusCode: response.statusCode,
        );
      }
      throw SurveyException(
        'Error inesperado (código ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw SurveyException(
        'Tiempo de espera agotado. Verifica tu conexión a internet.',
      );
    } on SurveyException {
      rethrow;
    } catch (e) {
      throw SurveyException('Error de conexión: $e');
    }
  }

  // Envía la respuesta; devuelve true si el servidor la aceptó (cualquier 2xx)
  Future<bool> submitResponse(Map<String, dynamic> responsePayload) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.surveysUrl}/submit'),
            headers: _headers,
            body: jsonEncode(responsePayload),
          )
          .timeout(AppConfig.apiTimeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      // Futuro punto de enganche para modo offline (guardar localmente si falla la red)
      return false;
    }
  }
}
