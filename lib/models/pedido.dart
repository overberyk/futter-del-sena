import 'direccion.dart';
import 'variante.dart';

class DetallePedido {
  final int id;
  final int cantidad;
  final double precio;
  final Variante variante;

  DetallePedido({
    required this.id,
    required this.cantidad,
    required this.precio,
    required this.variante,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['orderDetailId'] as int,
      cantidad: json['quantity'] as int,
      precio: double.parse(json['price'].toString()),
      variante: Variante.fromJson(json['productVariant'] as Map<String, dynamic>),
    );
  }
}

class Pedido {
  final int id;
  final Direccion direccion;
  final String estado;
  final List<DetallePedido> detalles;

  Pedido({
    required this.id,
    required this.direccion,
    required this.estado,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final details = (json['orderDetail'] as List<dynamic>? ?? const []);
    return Pedido(
      id: json['orderId'] as int,
      direccion: Direccion.fromJson(json['address'] as Map<String, dynamic>),
      estado: (json['orderStatus'] as Map<String, dynamic>)['name'] as String,
      detalles: details.map((e) => DetallePedido.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  double get total => detalles.fold(0.0, (suma, d) => suma + d.precio * d.cantidad);
}
