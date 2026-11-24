import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/catalogo_service.dart';
import '../services/usuario_service.dart';
import '../widgets/utilidades.dart';
import 'editar_screen.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late Future<List<Usuario>> _usuarios;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _usuarios = UsuarioService.getUsuarios();
  }

  void _recargar() {
    setState(() {
      _usuarios = UsuarioService.getUsuarios();
    });
  }

  Future<void> _cerrarSesion() async {
    setState(() => _loggingOut = true);
    try {
      await UsuarioService.cerrarSesion();
      if (!mounted) return;
      irAyLimpiar(context, const LoginScreen());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cerrar sesión: ${mensajeError(error)}')),
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _abrirRegistro() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const RegistroScreen()),
    );
    if (created == true && mounted) _recargar();
  }

  Future<void> _cambiarRol(Usuario usuario) async {
    try {
      final roles = await LookupService.roles();
      if (!mounted) return;
      final nuevoRolId = await showDialog<int>(
        context: context,
        builder: (_) => SimpleDialog(
          title: Text('Rol de ${usuario.nombres}'),
          children: roles
              .map((r) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, r.id),
                    child: Text(r.nombre),
                  ))
              .toList(),
        ),
      );
      if (nuevoRolId == null) return;
      await UsuarioService.cambiarRol(usuario.id, nuevoRolId);
      if (mounted) _recargar();
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  Future<void> _editarUsuario(Usuario usuario) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => EditarScreen(user: usuario),
      ),
    );
    if (changed == true && mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios (pulsación larga = cambiar rol)'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _loggingOut ? null : _cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _usuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No se pudieron cargar los usuarios.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _recargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? const <Usuario>[];
          if (data.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _recargar();
              await _usuarios;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (_, index) {
                final usuario = data[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('${usuario.nombres} ${usuario.apellidos}'),
                  subtitle: Text(usuario.correo),
                  trailing: Text(usuario.rol),
                  onTap: () => _editarUsuario(usuario),
                  onLongPress: () => _cambiarRol(usuario),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirRegistro,
        tooltip: 'Registrar usuario',
        child: const Icon(Icons.add),
      ),
    );
  }
}
