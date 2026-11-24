import 'package:flutter/material.dart';

import '../services/catalogo_service.dart';
import '../services/sesion.dart';
import '../widgets/utilidades.dart';
import 'catalogo_admin_screen.dart';
import 'usuarios_screen.dart';

// Panel de administracion (admin / seller).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(String titulo, CatalogoService servicio, {bool conDescripcion = false}) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CatalogoAdminScreen(
            titulo: titulo,
            servicio: servicio,
            conDescripcion: conDescripcion,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () => abrir('Categorías', CatalogoService.categorias, conDescripcion: true),
          ),
          ListTile(
            leading: const Icon(Icons.sell),
            title: const Text('Marcas'),
            onTap: () => abrir('Marcas', CatalogoService.marcas),
          ),
          ListTile(
            leading: const Icon(Icons.checkroom),
            title: const Text('Tipos'),
            onTap: () => abrir('Tipos', CatalogoService.tipos),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Tallas'),
            onTap: () => abrir('Tallas', CatalogoService.tallas),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Colores'),
            onTap: () => abrir('Colores', CatalogoService.colores),
          ),
          if (Sesion.esAdmin)
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Usuarios y roles'),
              onTap: () => irA(context, const UsuariosScreen()),
            ),
        ],
      ),
    );
  }
}
