import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/usuario_service.dart';
import '../widgets/utilidades.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _registrar() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await UsuarioService.registrar({
        'firstName': _nombreController.text.trim(),
        'lastName': _apellidoController.text.trim(),
        'email': _correoController.text.trim(),
        'password': _passwordController.text,
      });
      if (!mounted) return;
      avisar(context, 'Cuenta creada correctamente');
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: ${mensajeError(error)}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Ingresa tus nombres'
                    : null,
              ),
              TextFormField(
                controller: _apellidoController,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Ingresa tus apellidos'
                    : null,
              ),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Ingresa tu correo';
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(email)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                maxLength: 72,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  helperText: 'Mínimo 8 caracteres',
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8 || value.length > 72) {
                    return 'Usa entre 8 y 72 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_loading)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registrar,
                    child: const Text('Registrarme'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
