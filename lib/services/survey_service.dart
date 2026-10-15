import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metrixvox_app/config/app_config.dart';

class SurveyService {
  static const Duration _timeout = Duration(seconds: 15);

  // Identificador del cliente (tenant) activo, ej. 'HOSPITAL_SAN_JOSE'
  final String tenantId;

  SurveyService({required this.tenantId});

  Map<String, String> get _headers => {
        "Content-Type": "application/json",
        "X-Tenant-Id": tenantId,
      };

  // Obtiene la estructura dinámica de la encuesta
  Future<Map<String, dynamic>> fetchSurvey(String surveyCode) async {
    final uri = Uri.parse('${AppConfig.surveysUrl}/${Uri.encodeComponent(surveyCode)}');
    final response = await http.get(uri, headers: _headers).timeout(_timeout);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    }
    if (response.statusCode == 404) {
      throw Exception('La encuesta "$surveyCode" no existe para este cliente.');
    }
    throw Exception('Error al cargar la encuesta (código ${response.statusCode}).');
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
          .timeout(_timeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      // Futuro punto de enganche para modo offline (guardar localmente si falla la red)
      return false;
    }
  }
}
