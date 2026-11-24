import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/variante.dart';
import '../services/api_service.dart';
import '../services/carrito_service.dart';
import '../services/producto_service.dart';
import '../services/sesion.dart';
import '../widgets/producto_imagen.dart';
import '../widgets/utilidades.dart';
import 'login_screen.dart';
import 'producto_form_screen.dart';
import 'variantes_screen.dart';

class ProductoDetalleScreen extends StatefulWidget {
  final Producto producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  State<ProductoDetalleScreen> createState() => _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends State<ProductoDetalleScreen> {
  late Future<List<Variante>> _variantes;
  Variante? _seleccionada;
  int _cantidad = 1;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _variantes = VarianteService.porProducto(widget.producto.id);
  }

  void _recargarVariantes() {
    setState(() {
      _seleccionada = null;
      _cantidad = 1;
      _variantes = VarianteService.porProducto(widget.producto.id);
    });
  }

  Future<void> _agregarAlCarrito() async {
    if (!Sesion.haySesion) {
      avisar(context, 'Inicia sesión para agregar al carrito');
      irA(context, const LoginScreen());
      return;
    }
    final variante = _seleccionada;
    if (variante == null) {
      avisar(context, 'Elige una variante (talla / color)');
      return;
    }
    setState(() => _loading = true);
    try {
      await CarritoService.agregar(Sesion.userId, variante.id, _cantidad);
      if (mounted) avisar(context, 'Agregado al carrito');
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editar() async {
    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => ProductoFormScreen(producto: widget.producto)),
    );
    if (cambio == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _eliminar() async {
    if (!await confirmarAccion(context, '¿Eliminar este producto y sus variantes?')) return;
    try {
      await ProductoService.eliminar(widget.producto.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _administrarVariantes() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => VariantesScreen(producto: widget.producto)),
    );
    if (mounted) _recargarVariantes();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nombre),
        actions: [
          if (Sesion.esStaff) ...[
            IconButton(tooltip: 'Editar', icon: const Icon(Icons.edit), onPressed: _editar),
            IconButton(tooltip: 'Eliminar', icon: const Icon(Icons.delete), onPressed: _eliminar),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: const Color(0xFF1B1D23),
                child: ProductoImagen(
                  productoId: p.id,
                  fit: BoxFit.contain,
                  iconSize: 90,
                ),
              ),
            ),
          ),
          if (Sesion.esStaff)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Imagen: lib/assets/images/productos/${p.id}.jpg',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          const SizedBox(height: 16),
          Text(precio(p.precio), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text([p.marca, p.tipo, p.categoria].whereType<String>().join(' · ')),
          if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(p.descripcion!),
          ],
          const Divider(height: 32),
          FutureBuilder<List<Variante>>(
            future: _variantes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('No se pudieron cargar las variantes: ${snapshot.error}');
              }

              final lista = (snapshot.data ?? const <Variante>[]).where((v) => v.stock > 0).toList();
              if (lista.isEmpty) {
                return const Text('Sin stock disponible por ahora');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Variante', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<Variante>(
                    value: _seleccionada,
                    isExpanded: true,
                    hint: const Text('Elige talla / color'),
                    items: lista
                        .map((v) => DropdownMenuItem(value: v, child: Text(v.etiqueta)))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _seleccionada = v;
                      _cantidad = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                      ),
                      Text('$_cantidad', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: (_seleccionada != null && _cantidad < _seleccionada!.stock)
                            ? () => setState(() => _cantidad++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _agregarAlCarrito,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Agregar al carrito'),
                      ),
                    ),
                ],
              );
            },
          ),
          if (Sesion.esStaff) ...[
            const Divider(height: 32),
            OutlinedButton.icon(
              onPressed: _administrarVariantes,
              icon: const Icon(Icons.inventory_2),
              label: const Text('Administrar variantes y stock'),
            ),
          ],
        ],
      ),
    );
  }
}
