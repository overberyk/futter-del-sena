

class Direccion {
  final int id;
  final String ciudad;
  final String departamento;
  final String? barrio;
  final String direccion;

  Direccion({
    required this.id,
    required this.ciudad,
    required this.departamento,
    required this.barrio,
    required this.direccion,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      id: json['addressId'] as int,
      ciudad: json['city'] as String,
      departamento: json['department'] as String,
      barrio: json['neighborhood'] as String?,
      direccion: json['streetAddress'] as String,
    );
  }

  String get resumen {
    final b = (barrio != null && barrio!.isNotEmpty) ? '$barrio, ' : '';
    return '$direccion, $b$ciudad ($departamento)';
  }
}
