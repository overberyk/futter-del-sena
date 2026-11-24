import 'dart:convert';

import '../models/usuario.dart';
import 'api_service.dart';
import 'sesion.dart';

class UsuarioService {
  static Future<List<Usuario>> getUsuarios() async {
    final response = await ApiService.get('/users/?skip=0&limit=100');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data
        .map((item) => Usuario.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Usuario> getUsuario(int id) async {
    final response = await ApiService.get('/users/$id');
    asegurarExito(response, esperado: 200);
    return Usuario.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<Usuario> registrar(Map<String, dynamic> data) async {
    final response = await ApiService.postJson('/users/', data);
    asegurarExito(response, esperado: 201);
    return Usuario.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<Usuario> editar(int id, Map<String, dynamic> data) async {
    final response = await ApiService.patchJson('/users/$id', data);
    asegurarExito(response, esperado: 200);
    return Usuario.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<String> eliminar(int id) async {
    final response = await ApiService.delete('/users/$id');
    asegurarExito(response, esperado: 204);
    return 'Usuario eliminado correctamente';
  }

  // Solo admin
  static Future<Usuario> cambiarRol(int id, int roleId) async {
    final response = await ApiService.patchJson('/users/$id/role', {'roleId': roleId});
    asegurarExito(response, esperado: 200);
    return Usuario.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<void> iniciarSesion(String email, String password) async {
    final response = await ApiService.postForm('/auth/login', {
      'username': email,
      'password': password,
    });
    asegurarExito(response, esperado: 200);

    final tokens = leerJson(response) as Map<String, dynamic>;
    ApiService.setTokens(
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
    );

    // Guardamos quién es el usuario (id y rol) para decidir qué mostrar.
    try {
      await cargarSesion();
    } catch (_) {
      ApiService.clearTokens();
      Sesion.limpiar();
      rethrow;
    }
  }

  // El "sub" del token (JWT) es el id del usuario.
  static Future<void> cargarSesion() async {
    final token = ApiService.accessToken;
    if (token == null) throw Exception('No hay sesión iniciada');
    Sesion.usuario = await getUsuario(_idDesdeToken(token));
  }

  static Future<void> cerrarSesion() async {
    final refreshToken = ApiService.refreshToken;
    try {
      if (refreshToken != null) {
        await ApiService.postJson('/auth/logout', {'refreshToken': refreshToken});
      }
    } catch (_) {
      // Si no hay red igual cerramos la sesion local.
    } finally {
      ApiService.clearTokens();
      Sesion.limpiar();
    }
  }

  static int _idDesdeToken(String token) {
    final partes = token.split('.');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
    final data = jsonDecode(payload) as Map<String, dynamic>;
    return int.parse(data['sub'].toString());
  }
}
