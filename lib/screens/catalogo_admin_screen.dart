import 'package:flutter/material.dart';

import '../models/item_catalogo.dart';
import '../services/api_service.dart';
import '../services/catalogo_service.dart';
import '../widgets/utilidades.dart';

// CRUD generico para Categorias, Marcas, Tipos, Tallas y Colores (admin / seller).
class CatalogoAdminScreen extends StatefulWidget {
  final String titulo;
  final CatalogoService servicio;
  final bool conDescripcion;

  const CatalogoAdminScreen({
    super.key,
    required this.titulo,
    required this.servicio,
    this.conDescripcion = false,
  });

  @override
  State<CatalogoAdminScreen> createState() => _CatalogoAdminScreenState();
}

class _CatalogoAdminScreenState extends State<CatalogoAdminScreen> {
  late Future<List<ItemCatalogo>> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.servicio.listar();
  }

  void _recargar() {
    setState(() {
      _items = widget.servicio.listar();
    });
  }

  Future<void> _formulario([ItemCatalogo? item]) async {
    final nombre = TextEditingController(text: item?.nombre ?? '');
    final descripcion = TextEditingController(text: item?.descripcion ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Nuevo' : 'Editar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
            if (widget.conDescripcion)
              TextField(
                  controller: descripcion,
                  decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok != true) return;

    final body = <String, dynamic>{'name': nombre.text.trim()};
    if (widget.conDescripcion) body['description'] = descripcion.text.trim();

    try {
      if (item == null) {
        await widget.servicio.crear(body);
      } else {
        await widget.servicio.editar(item.id, body);
      }
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _eliminar(ItemCatalogo item) async {
    if (!await confirmarAccion(context, '¿Eliminar "${item.nombre}"?')) return;
    try {
      await widget.servicio.eliminar(item.id);
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: FutureBuilder<List<ItemCatalogo>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final data = snapshot.data ?? const <ItemCatalogo>[];
          if (data.isEmpty) {
            return const Center(child: Text('Sin registros. Usa + para crear uno.'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];
              return ListTile(
                title: Text(item.nombre),
                subtitle: item.descripcion != null ? Text(item.descripcion!) : null,
                onTap: () => _formulario(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminar(item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _formulario(),
        tooltip: 'Nuevo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
