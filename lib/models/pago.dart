

class Pago {
  final int id;
  final double total;
  final String metodo;
  final String estado;

  Pago({
    required this.id,
    required this.total,
    required this.metodo,
    required this.estado,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['paymentId'] as int,
      total: double.parse(json['total'].toString()),
      metodo: (json['paymentMethod'] as Map<String, dynamic>)['name'] as String,
      estado: (json['paymentStatus'] as Map<String, dynamic>)['name'] as String,
    );
  }
}
