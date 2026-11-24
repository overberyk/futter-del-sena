import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/variante.dart';
import '../services/api_service.dart';
import '../services/catalogo_service.dart';
import '../services/producto_service.dart';
import '../widgets/utilidades.dart';

// Administrar las variantes (talla + color + stock) de un producto. Solo admin / seller.
class VariantesScreen extends StatefulWidget {
  final Producto producto;

  const VariantesScreen({super.key, required this.producto});

  @override
  State<VariantesScreen> createState() => _VariantesScreenState();
}

class _VariantesScreenState extends State<VariantesScreen> {
  late Future<List<Variante>> _variantes;

  @override
  void initState() {
    super.initState();
    _variantes = VarianteService.porProducto(widget.producto.id);
  }

  void _recargar() {
    setState(() {
      _variantes = VarianteService.porProducto(widget.producto.id);
    });
  }

  Future<void> _agregar() async {
    try {
      final tallas = await CatalogoService.tallas.listar();
      final colores = await CatalogoService.colores.listar();
      if (!mounted) return;
      if (tallas.isEmpty || colores.isEmpty) {
        avisar(context, 'Primero crea tallas y colores en Administración');
        return;
      }

      int? tallaId;
      int? colorId;
      final stockController = TextEditingController(text: '0');

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: const Text('Nueva variante'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: tallaId,
                  isExpanded: true,
                  hint: const Text('Talla'),
                  items: tallas
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)))
                      .toList(),
                  onChanged: (v) => setLocal(() => tallaId = v),
                ),
                DropdownButton<int>(
                  value: colorId,
                  isExpanded: true,
                  hint: const Text('Color'),
                  items: colores
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre)))
                      .toList(),
                  onChanged: (v) => setLocal(() => colorId = v),
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock inicial'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Crear')),
            ],
          ),
        ),
      );
      if (ok != true) return;

      final stock = int.tryParse(stockController.text.trim());
      if (tallaId == null || colorId == null || stock == null || stock < 0) {
        if (mounted) avisar(context, 'Elige talla, color y un stock válido (0 o más)');
        return;
      }

      await VarianteService.crear({
        'productId': widget.producto.id,
        'sizeId': tallaId,
        'colorId': colorId,
        'stock': stock,
      });
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _cambiarStock(Variante variante) async {
    final controller = TextEditingController(text: '${variante.stock}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(variante.descripcion),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stock'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (ok != true) return;

    final stock = int.tryParse(controller.text.trim());
    if (stock == null || stock < 0) {
      if (mounted) avisar(context, 'El stock debe ser 0 o más');
      return;
    }
    try {
      await VarianteService.editar(variante.id, {'stock': stock});
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _eliminar(Variante variante) async {
    if (!await confirmarAccion(context, '¿Eliminar "${variante.descripcion}"?')) return;
    try {
      await VarianteService.eliminar(variante.id);
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Variantes · ${widget.producto.nombre}')),
      body: FutureBuilder<List<Variante>>(
        future: _variantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data ?? const <Variante>[];
          if (data.isEmpty) {
            return const Center(child: Text('Este producto aún no tiene variantes'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final v = data[i];
              return ListTile(
                title: Text(v.descripcion),
                subtitle: Text('Stock: ${v.stock}'),
                onTap: () => _cambiarStock(v),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _eliminar(v),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregar,
        tooltip: 'Nueva variante',
        child: const Icon(Icons.add),
      ),
    );
  }
}
