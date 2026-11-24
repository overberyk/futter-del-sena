

class Usuario {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String? telefono;
  final String rol;

  Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final roleJson = json['role'];
    if (roleJson is! Map<String, dynamic>) {
      throw const FormatException('La respuesta del usuario no incluye su rol');
    }

    return Usuario(
      id: json['userId'] as int,
      nombres: json['firstName'] as String,
      apellidos: json['lastName'] as String,
      correo: json['email'] as String,
      telefono: json['phone']?.toString(),
      rol: roleJson['name'] as String,
    );
  }
}
