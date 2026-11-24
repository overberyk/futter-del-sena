import '../models/direccion.dart';
import 'api_service.dart';

class DireccionService {
  static Future<List<Direccion>> listar(int userId) async {
    final response = await ApiService.get('/users/$userId/addresses');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data.map((e) => Direccion.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> crear(int userId, Map<String, dynamic> data) async {
    final response = await ApiService.postJson('/users/$userId/addresses', data);
    asegurarExito(response, esperado: 201);
  }

  static Future<void> eliminar(int userId, int addressId) async {
    final response = await ApiService.delete('/users/$userId/addresses/$addressId');
    asegurarExito(response, esperado: 204);
  }
}
