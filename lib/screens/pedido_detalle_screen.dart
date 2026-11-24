import 'package:flutter/material.dart';

import '../models/item_catalogo.dart';
import '../models/pago.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../services/catalogo_service.dart';
import '../services/pedido_service.dart';
import '../services/sesion.dart';
import '../widgets/utilidades.dart';

class _Datos {
  final Pedido pedido;
  final Pago? pago;
  final List<ItemCatalogo> metodos;
  final List<ItemCatalogo> estados;

  _Datos(this.pedido, this.pago, this.metodos, this.estados);
}

class PedidoDetalleScreen extends StatefulWidget {
  final int orderId;

  const PedidoDetalleScreen({super.key, required this.orderId});

  @override
  State<PedidoDetalleScreen> createState() => _PedidoDetalleScreenState();
}

class _PedidoDetalleScreenState extends State<PedidoDetalleScreen> {
  late Future<_Datos> _datos;
  int? _metodoId;
  int? _estadoId;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
  }

  Future<_Datos> _cargar() async {
    final uid = Sesion.userId;
    final pedido = await PedidoService.obtener(uid, widget.orderId);
    final pago = await PagoService.obtener(uid, widget.orderId);
    final metodos = pago == null ? await LookupService.metodosPago() : <ItemCatalogo>[];
    final estados = (Sesion.esAdmin && pago != null) ? await LookupService.estadosPago() : <ItemCatalogo>[];
    return _Datos(pedido, pago, metodos, estados);
  }

  void _recargar() {
    setState(() {
      _datos = _cargar();
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

  @override
  Widget build(BuildContext context) {
    final uid = Sesion.userId;

    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${widget.orderId}')),
      body: FutureBuilder<_Datos>(
        future: _datos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final datos = snapshot.data!;
          final pedido = datos.pedido;
          final pago = datos.pago;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Chip(label: Text('Estado: ${pedido.estado}')),
              const SizedBox(height: 8),
              Text('Envío a: ${pedido.direccion.resumen}'),
              const Divider(height: 24),
              ...pedido.detalles.map(
                (d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d.variante.producto?.nombre ?? 'Variante #${d.variante.id}'),
                  subtitle: Text('${d.variante.descripcion} · x${d.cantidad}'),
                  trailing: Text(precio(d.precio * d.cantidad)),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 20)),
                  Text(
                    precio(pedido.total),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pago == null) ...[
                const Text('Este pedido todavía no tiene un pago.'),
                if (datos.metodos.isEmpty)
                  const Text('No hay métodos de pago configurados en el servidor.')
                else ...[
                  DropdownButton<int>(
                    value: _metodoId ?? datos.metodos.first.id,
                    isExpanded: true,
                    items: datos.metodos
                        .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _metodoId = v),
                  ),
                  ElevatedButton(
                    onPressed: () => _accion(() async {
                      await PagoService.crear(uid, widget.orderId, _metodoId ?? datos.metodos.first.id);
                    }),
                    child: const Text('Pagar'),
                  ),
                ],
              ] else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Método: ${pago.metodo}'),
                  subtitle: Text('Estado: ${pago.estado}'),
                  trailing: Text(precio(pago.total)),
                ),
                if (Sesion.esAdmin && pago.estado != 'Approved' && datos.estados.isNotEmpty) ...[
                  DropdownButton<int>(
                    value: _estadoId ?? datos.estados.first.id,
                    isExpanded: true,
                    items: datos.estados
                        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                        .toList(),
                    onChanged: (v) => setState(() => _estadoId = v),
                  ),
                  ElevatedButton(
                    onPressed: () => _accion(() async {
                      await PagoService.confirmar(
                          uid, widget.orderId, _estadoId ?? datos.estados.first.id);
                    }),
                    child: const Text('Actualizar estado del pago (admin)'),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
