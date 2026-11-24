import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/usuario_service.dart';

class EditarScreen extends StatefulWidget {
  final Usuario user;

  const EditarScreen({super.key, required this.user});

  @override
  State<EditarScreen> createState() => _EditarScreenState();
}

class _EditarScreenState extends State<EditarScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombres);
    _apellidoController = TextEditingController(text: widget.user.apellidos);
    _correoController = TextEditingController(text: widget.user.correo);
    _telefonoController = TextEditingController(
      text: widget.user.telefono ?? '',
    );
  }

  Future<void> _editar() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await UsuarioService.editar(widget.user.id, {
        'firstName': _nombreController.text.trim(),
        'lastName': _apellidoController.text.trim(),
        'email': _correoController.text.trim(),
        'phone': _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo actualizar: ${mensajeError(error)}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _eliminar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Quieres eliminar a ${widget.user.nombres}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    try {
      await UsuarioService.eliminar(widget.user.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: ${mensajeError(error)}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar usuario'),
        actions: [
          IconButton(
            tooltip: 'Eliminar usuario',
            onPressed: _loading ? null : _eliminar,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Ingresa los nombres'
                    : null,
              ),
              TextFormField(
                controller: _apellidoController,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Ingresa los apellidos'
                    : null,
              ),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Ingresa el correo';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                maxLength: 45,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editar,
                    child: const Text('Guardar cambios'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
