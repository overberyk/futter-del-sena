import 'package:flutter/material.dart';

import '../models/direccion.dart';
import '../services/api_service.dart';
import '../services/direccion_service.dart';
import '../services/sesion.dart';
import '../widgets/utilidades.dart';

// Direcciones de envio del usuario. Necesitas al menos una para crear pedidos.
class DireccionesScreen extends StatefulWidget {
  const DireccionesScreen({super.key});

  @override
  State<DireccionesScreen> createState() => _DireccionesScreenState();
}

class _DireccionesScreenState extends State<DireccionesScreen> {
  late Future<List<Direccion>> _direcciones;

  @override
  void initState() {
    super.initState();
    _direcciones = DireccionService.listar(Sesion.userId);
  }

  void _recargar() {
    setState(() {
      _direcciones = DireccionService.listar(Sesion.userId);
    });
  }

  Future<void> _agregar() async {
    final ciudad = TextEditingController();
    final departamento = TextEditingController();
    final barrio = TextEditingController();
    final calle = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva dirección'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: ciudad, decoration: const InputDecoration(labelText: 'Ciudad')),
              TextField(
                  controller: departamento,
                  decoration: const InputDecoration(labelText: 'Departamento')),
              TextField(
                  controller: barrio,
                  decoration: const InputDecoration(labelText: 'Barrio (opcional)')),
              TextField(controller: calle, decoration: const InputDecoration(labelText: 'Dirección')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok != true) return;

    if (ciudad.text.trim().isEmpty || departamento.text.trim().isEmpty || calle.text.trim().isEmpty) {
      if (mounted) avisar(context, 'Ciudad, departamento y dirección son obligatorios');
      return;
    }

    try {
      await DireccionService.crear(Sesion.userId, {
        'city': ciudad.text.trim(),
        'department': departamento.text.trim(),
        'neighborhood': barrio.text.trim().isEmpty ? null : barrio.text.trim(),
        'streetAddress': calle.text.trim(),
      });
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _eliminar(Direccion direccion) async {
    if (!await confirmarAccion(context, '¿Eliminar esta dirección?')) return;
    try {
      await DireccionService.eliminar(Sesion.userId, direccion.id);
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis direcciones')),
      body: FutureBuilder<List<Direccion>>(
        future: _direcciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final data = snapshot.data ?? const <Direccion>[];
          if (data.isEmpty) {
            return const Center(child: Text('Sin direcciones. Agrega una para poder comprar.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final d = data[i];
              return ListTile(
                leading: const Icon(Icons.home),
                title: Text(d.direccion),
                subtitle: Text('${d.ciudad} (${d.departamento})'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminar(d),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        tooltip: 'Agregar dirección',
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
