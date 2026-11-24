import '../models/pago.dart';
import '../models/pedido.dart';
import 'api_service.dart';

class PedidoService {
  static Future<List<Pedido>> listar(int userId) async {
    final response = await ApiService.get('/users/$userId/orders/');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data.map((e) => Pedido.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Pedido> obtener(int userId, int orderId) async {
    final response = await ApiService.get('/users/$userId/orders/$orderId');
    asegurarExito(response, esperado: 200);
    return Pedido.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  // Crea el pedido desde el carrito: descuenta stock y vacia el carrito.
  static Future<Pedido> crear(int userId) async {
    final response = await ApiService.postJson('/users/$userId/orders/', {});
    asegurarExito(response, esperado: 201);
    return Pedido.fromJson(leerJson(response) as Map<String, dynamic>);
  }
}

class PagoService {
  static String _base(int userId, int orderId) => '/users/$userId/orders/$orderId/payment';

  // Devuelve null si el pedido todavia no tiene pago (la API responde 404)
  static Future<Pago?> obtener(int userId, int orderId) async {
    final response = await ApiService.get('${_base(userId, orderId)}/');
    if (response.statusCode == 404) return null;
    asegurarExito(response, esperado: 200);
    return Pago.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  static Future<Pago> crear(int userId, int orderId, int paymentMethodId) async {
    final response = await ApiService.postJson(
      '${_base(userId, orderId)}/',
      {'paymentMethodId': paymentMethodId},
    );
    asegurarExito(response, esperado: 201);
    return Pago.fromJson(leerJson(response) as Map<String, dynamic>);
  }

  // Solo admin
  static Future<Pago> confirmar(int userId, int orderId, int paymentStatusId) async {
    final response = await ApiService.patchJson(
      '${_base(userId, orderId)}/confirm',
      {'paymentStatusId': paymentStatusId},
    );
    asegurarExito(response, esperado: 200);
    return Pago.fromJson(leerJson(response) as Map<String, dynamic>);
  }
}
