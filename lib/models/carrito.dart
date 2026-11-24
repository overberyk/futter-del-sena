import 'variante.dart';

class ItemCarrito {
  final int id;
  final int cantidad;
  final double precioUnitario;
  final Variante variante;

  ItemCarrito({
    required this.id,
    required this.cantidad,
    required this.precioUnitario,
    required this.variante,
  });

  factory ItemCarrito.fromJson(Map<String, dynamic> json) {
    return ItemCarrito(
      id: json['cartDetailId'] as int,
      cantidad: json['quantity'] as int,
      precioUnitario: double.parse(json['unitPrice'].toString()),
      variante: Variante.fromJson(json['productVariant'] as Map<String, dynamic>),
    );
  }

  double get subtotal => precioUnitario * cantidad;
}

class Carrito {
  final int id;
  final List<ItemCarrito> items;

  Carrito({required this.id, required this.items});

  factory Carrito.fromJson(Map<String, dynamic> json) {
    final details = (json['details'] as List<dynamic>? ?? const []);
    return Carrito(
      id: json['cartId'] as int,
      items: details.map((e) => ItemCarrito.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  double get total => items.fold(0.0, (suma, item) => suma + item.subtotal);
}
