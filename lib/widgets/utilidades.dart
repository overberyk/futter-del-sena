import 'package:flutter/material.dart';

// Mensaje corto abajo de la pantalla.
void avisar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
}

// Muestra el precio con el signo de pesos y 2 decimales.
String precio(double valor) => '\$${valor.toStringAsFixed(2)}';

// Pregunta "¿Seguro?" y devuelve true si el usuario acepta.
Future<bool> confirmarAccion(BuildContext context, String mensaje) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar'),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Aceptar')),
      ],
    ),
  );
  return r ?? false;
}

// Abre otra pantalla.
void irA(BuildContext context, Widget pantalla) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
}

// Abre otra pantalla y borra las anteriores (para login y cerrar sesión).
void irAyLimpiar(BuildContext context, Widget pantalla) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => pantalla),
    (ruta) => false,
  );
}
