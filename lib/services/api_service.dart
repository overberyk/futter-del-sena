import 'dart:convert';
import 'package:http/http.dart' as http;

// Dirección del servidor (Render).
const String baseUrl = 'https://backend-8j0l.onrender.com';

// Convierte la respuesta del servidor en JSON.
dynamic leerJson(http.Response respuesta) {
  return jsonDecode(utf8.decode(respuesta.bodyBytes));
}

// Si el código de la respuesta no es el esperado, lanza un error con el mensaje del servidor.
void asegurarExito(http.Response respuesta, {required int esperado}) {
  if (respuesta.statusCode == esperado) return;

  String mensaje = 'Error HTTP ${respuesta.statusCode}';
  if (respuesta.bodyBytes.isNotEmpty) {
    final texto = utf8.decode(respuesta.bodyBytes);
    try {
      final datos = jsonDecode(texto);
      if (datos is Map<String, dynamic>) {
        final detalle = datos['detail'] ?? datos['error'] ?? datos['message'];
        if (detalle is List) {
          mensaje = detalle
              .map((e) => e is Map ? (e['msg'] ?? e).toString() : e.toString())
              .join('\n');
        } else if (detalle != null) {
          mensaje = detalle.toString();
        }
      }
    } on FormatException {
      mensaje = texto;
    }
  }
  throw Exception(mensaje);
}

// Quita el "Exception: " del texto para mostrarlo al usuario.
String mensajeError(Object error) {
  return error.toString().replaceFirst('Exception: ', '');
}

// Hace las peticiones al servidor y guarda los tokens de la sesión.
class ApiService {
  static String? accessToken;
  static String? refreshToken;

  static void setTokens({required String accessToken, required String refreshToken}) {
    ApiService.accessToken = accessToken;
    ApiService.refreshToken = refreshToken;
  }

  static void clearTokens() {
    accessToken = null;
    refreshToken = null;
  }

  static Uri _uri(String ruta) => Uri.parse('$baseUrl$ruta');

  static Map<String, String> _headers({String? contentType}) {
    return {
      'Accept': 'application/json',
      if (contentType != null) 'Content-Type': contentType,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  // Envía la petición. Si el token venció (401), pide uno nuevo y reintenta una vez.
  static Future<http.Response> _enviar(Future<http.Response> Function() peticion) async {
    final respuesta = await peticion();
    if (respuesta.statusCode != 401 || refreshToken == null) return respuesta;

    final renovado = await http.post(
      _uri('/auth/refresh'),
      headers: _headers(contentType: 'application/json'),
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (renovado.statusCode != 200) {
      clearTokens();
      return respuesta;
    }

    final datos = jsonDecode(renovado.body) as Map<String, dynamic>;
    setTokens(
      accessToken: datos['accessToken'] as String,
      refreshToken: datos['refreshToken'] as String,
    );
    return peticion();
  }

  static Future<http.Response> get(String ruta) {
    return _enviar(() => http.get(_uri(ruta), headers: _headers()));
  }

  static Future<http.Response> postJson(String ruta, Map<String, dynamic> datos) {
    return _enviar(() => http.post(
          _uri(ruta),
          headers: _headers(contentType: 'application/json'),
          body: jsonEncode(datos),
        ));
  }

  static Future<http.Response> postForm(String ruta, Map<String, String> campos) {
    return http.post(
      _uri(ruta),
      headers: _headers(contentType: 'application/x-www-form-urlencoded'),
      body: campos,
    );
  }

  static Future<http.Response> patchJson(String ruta, Map<String, dynamic> datos) {
    return _enviar(() => http.patch(
          _uri(ruta),
          headers: _headers(contentType: 'application/json'),
          body: jsonEncode(datos),
        ));
  }

  static Future<http.Response> delete(String ruta) {
    return _enviar(() => http.delete(_uri(ruta), headers: _headers()));
  }
}
