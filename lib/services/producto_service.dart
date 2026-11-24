import '../models/producto.dart';
import '../models/variante.dart';
import 'api_service.dart';

class ProductoService {
  static Future<List<Producto>> listar({int? categoryId, int? brandId, int? typeId}) async {
    final query = <String>['skip=0', 'limit=100'];
    if (categoryId != null) query.add('categoryId=$categoryId');
    if (brandId != null) query.add('brandId=$brandId');
    if (typeId != null) query.add('typeId=$typeId');

    final response = await ApiService.get('/products/?${query.join('&')}');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data.map((e) => Producto.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Crear, editar y eliminar requieren rol admin o seller
  static Future<void> crear(Map<String, dynamic> data) async {
    final response = await ApiService.postJson('/products/', data);
    asegurarExito(response, esperado: 201);
  }

  static Future<void> editar(int id, Map<String, dynamic> data) async {
    final response = await ApiService.patchJson('/products/$id', data);
    asegurarExito(response, esperado: 200);
  }

  static Future<void> eliminar(int id) async {
    final response = await ApiService.delete('/products/$id');
    asegurarExito(response, esperado: 204);
  }
}

class VarianteService {
  static Future<List<Variante>> porProducto(int productId) async {
    final response = await ApiService.get('/variants/?productId=$productId&skip=0&limit=100');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data.map((e) => Variante.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Crear, editar y eliminar requieren rol admin o seller
  static Future<void> crear(Map<String, dynamic> data) async {
    final response = await ApiService.postJson('/variants/', data);
    asegurarExito(response, esperado: 201);
  }

  static Future<void> editar(int id, Map<String, dynamic> data) async {
    final response = await ApiService.patchJson('/variants/$id', data);
    asegurarExito(response, esperado: 200);
  }

  static Future<void> eliminar(int id) async {
    final response = await ApiService.delete('/variants/$id');
    asegurarExito(response, esperado: 204);
  }
}
