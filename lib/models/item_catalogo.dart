

class ItemCatalogo {
  final int id;
  final String nombre;
  final String? descripcion;

  ItemCatalogo({required this.id, required this.nombre, this.descripcion});

  factory ItemCatalogo.fromJson(Map<String, dynamic> json, String idKey) {
    return ItemCatalogo(
      id: json[idKey] as int,
      nombre: json['name'] as String,
      descripcion: json['description'] as String?,
    );
  }
}
