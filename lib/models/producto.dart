

class Producto {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final int categoriaId;
  final int? marcaId;
  final int? tipoId;
  final String? categoria;
  final String? marca;
  final String? tipo;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoriaId,
    required this.marcaId,
    required this.tipoId,
    required this.categoria,
    required this.marca,
    required this.tipo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final brand = json['brand'] as Map<String, dynamic>?;
    final type = json['type'] as Map<String, dynamic>?;

    return Producto(
      id: json['productId'] as int,
      nombre: json['name'] as String,
      descripcion: json['description'] as String?,
      // La API manda el precio como texto ("19.90")
      precio: double.parse(json['unitPrice'].toString()),
      categoriaId: json['categoryId'] as int,
      marcaId: json['brandId'] as int?,
      tipoId: json['typeId'] as int?,
      categoria: category?['name'] as String?,
      marca: brand?['name'] as String?,
      tipo: type?['name'] as String?,
    );
  }
}
