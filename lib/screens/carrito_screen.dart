import 'package:flutter/material.dart';

import '../models/carrito.dart';
import '../services/api_service.dart';
import '../services/carrito_service.dart';
import '../services/pedido_service.dart';
import '../services/sesion.dart';
import '../widgets/utilidades.dart';
import 'pedido_detalle_screen.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  late Future<Carrito> _carrito;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _carrito = CarritoService.obtener(Sesion.userId);
  }

  void _recargar() {
    setState(() {
      _carrito = CarritoService.obtener(Sesion.userId);
    });
  }

  Future<void> _accion(Future<void> Function() accion) async {
    try {
      await accion();
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _vaciar() async {
    if (!await confirmarAccion(context, '¿Vaciar el carrito?')) return;
    await _accion(() => CarritoService.vaciar(Sesion.userId));
  }

  Future<void> _crearPedido() async {
    setState(() => _procesando = true);
    try {
      final pedido = await PedidoService.crear(Sesion.userId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => PedidoDetalleScreen(orderId: pedido.id)),
      );
    } catch (error) {
      if (!mounted) return;
      avisar(context, mensajeError(error));
      setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = Sesion.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          IconButton(
            tooltip: 'Vaciar carrito',
            icon: const Icon(Icons.remove_shopping_cart),
            onPressed: _vaciar,
          ),
        ],
      ),
      body: FutureBuilder<Carrito>(
        future: _carrito,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final carrito = snapshot.data!;
          if (carrito.items.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.items.length,
                  itemBuilder: (_, i) {
                    final item = carrito.items[i];
                    return ListTile(
                      title: Text(item.variante.producto?.nombre ?? 'Variante #${item.variante.id}'),
                      subtitle: Text(
                        '${item.variante.descripcion}\n'
                        '${precio(item.precioUnitario)} c/u → ${precio(item.subtotal)}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: item.cantidad > 1
                                ? () => _accion(
                                    () => CarritoService.actualizar(uid, item.id, item.cantidad - 1))
                                : null,
                          ),
                          Text('${item.cantidad}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _accion(
                                () => CarritoService.actualizar(uid, item.id, item.cantidad + 1)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _accion(() => CarritoService.quitar(uid, item.id)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 20)),
                        Text(
                          precio(carrito.total),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_procesando)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _crearPedido,
                          child: const Text('Crear pedido'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
