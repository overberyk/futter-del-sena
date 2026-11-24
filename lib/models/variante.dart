

class ProductoSimple {
  final int id;
  final String nombre;
  final double precio;

  ProductoSimple({required this.id, required this.nombre, required this.precio});

  factory ProductoSimple.fromJson(Map<String, dynamic> json) {
    return ProductoSimple(
      id: json['productId'] as int,
      nombre: json['name'] as String,
      precio: double.parse(json['unitPrice'].toString()),
    );
  }
}

class Variante {
  final int id;
  final int stock;
  final ProductoSimple? producto;
  final String? talla;
  final String? color;

  Variante({
    required this.id,
    required this.stock,
    required this.producto,
    required this.talla,
    required this.color,
  });

  factory Variante.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final size = json['size'] as Map<String, dynamic>?;
    final color = json['color'] as Map<String, dynamic>?;

    return Variante(
      id: json['productVariantId'] as int,
      stock: json['stock'] as int,
      producto: product == null ? null : ProductoSimple.fromJson(product),
      talla: size?['name'] as String?,
      color: color?['name'] as String?,
    );
  }

  // "Talla M · Rojo"
  String get descripcion {
    final partes = <String>[];
    if (talla != null) partes.add('Talla $talla');
    if (color != null) partes.add(color!);
    return partes.isEmpty ? 'Variante #$id' : partes.join(' · ');
  }

  String get etiqueta => '$descripcion (stock $stock)';
}
