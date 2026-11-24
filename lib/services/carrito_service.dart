import '../models/carrito.dart';
import 'api_service.dart';

class CarritoService {
  static Future<Carrito> obtener(int userId) async {
    final response = await ApiService.get('/users/$userId/cart/');
    asegurarExito(response, esperado: 200);
    return Carrito.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<void> agregar(int userId, int variantId, int cantidad) async {
    final response = await ApiService.postJson('/users/$userId/cart/details', {
      'productVariantId': variantId,
      'quantity': cantidad,
    });
    asegurarExito(response, esperado: 201);
  }

  static Future<void> actualizar(int userId, int detailId, int cantidad) async {
    final response = await ApiService.patchJson(
      '/users/$userId/cart/details/$detailId',
      {'quantity': cantidad},
    );
    asegurarExito(response, esperado: 200);
  }

  static Future<void> quitar(int userId, int detailId) async {
    final response = await ApiService.delete('/users/$userId/cart/details/$detailId');
    asegurarExito(response, esperado: 204);
  }

  static Future<void> vaciar(int userId) async {
    final response = await ApiService.delete('/users/$userId/cart/');
    asegurarExito(response, esperado: 204);
  }
}
