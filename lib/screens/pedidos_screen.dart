import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/pedido_service.dart';
import '../services/sesion.dart';
import '../widgets/utilidades.dart';
import 'pedido_detalle_screen.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<Pedido>> _pedidos;

  @override
  void initState() {
    super.initState();
    _pedidos = PedidoService.listar(Sesion.userId);
  }

  void _recargar() {
    setState(() {
      _pedidos = PedidoService.listar(Sesion.userId);
    });
  }

  Future<void> _abrir(Pedido pedido) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => PedidoDetalleScreen(orderId: pedido.id)),
    );
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }

          final data = (snapshot.data ?? const <Pedido>[]).reversed.toList();
          if (data.isEmpty) {
            return const Center(child: Text('Aún no tienes pedidos'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final p = data[i];
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('Pedido #${p.id}'),
                subtitle: Text('${p.estado} · ${p.detalles.length} artículo(s)'),
                trailing: Text(
                  precio(p.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _abrir(p),
              );
            },
          );
        },
      ),
    );
  }
}
