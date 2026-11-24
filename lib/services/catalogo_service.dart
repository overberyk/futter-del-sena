import '../models/item_catalogo.dart';
import 'api_service.dart';

// Un solo servicio para Marcas, Categorias, Tipos, Tallas y Colores (mismo CRUD).
class CatalogoService {
  final String ruta;
  final String idKey;

  const CatalogoService(this.ruta, this.idKey);

  static const marcas = CatalogoService('brands', 'brandId');
  static const categorias = CatalogoService('categories', 'categoryId');
  static const tipos = CatalogoService('types', 'typeId');
  static const tallas = CatalogoService('sizes', 'sizeId');
  static const colores = CatalogoService('colors', 'colorId');

  Future<List<ItemCatalogo>> listar() async {
    final response = await ApiService.get('/$ruta/?skip=0&limit=200');
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data
        .map((e) => ItemCatalogo.fromJson(e as Map<String, dynamic>, idKey))
        .toList();
  }

  // Crear, editar y eliminar requieren rol admin o seller
  Future<void> crear(Map<String, dynamic> data) async {
    final response = await ApiService.postJson('/$ruta/', data);
    asegurarExito(response, esperado: 201);
  }

  Future<void> editar(int id, Map<String, dynamic> data) async {
    final response = await ApiService.patchJson('/$ruta/$id', data);
    asegurarExito(response, esperado: 200);
  }

  Future<void> eliminar(int id) async {
    final response = await ApiService.delete('/$ruta/$id');
    asegurarExito(response, esperado: 204);
  }
}

// Listas auxiliares (rutas /lookups de la API) para no escribir IDs a mano.
class LookupService {
  static Future<List<ItemCatalogo>> _listar(String path, String idKey) async {
    final response = await ApiService.get(path);
    asegurarExito(response, esperado: 200);
    final List<dynamic> data = leerJson(response);
    return data
        .map((e) => ItemCatalogo.fromJson(e as Map<String, dynamic>, idKey))
        .toList();
  }

  static Future<List<ItemCatalogo>> metodosPago() =>
      _listar('/lookups/payment-methods', 'paymentMethodId');

  static Future<List<ItemCatalogo>> estadosPago() =>
      _listar('/lookups/payment-statuses', 'paymentStatusId');

  // Solo admin
  static Future<List<ItemCatalogo>> roles() => _listar('/lookups/roles', 'roleId');
}
