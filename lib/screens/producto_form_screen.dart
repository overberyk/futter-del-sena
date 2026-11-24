import 'package:flutter/material.dart';

import '../models/item_catalogo.dart';
import '../models/producto.dart';
import '../services/api_service.dart';
import '../services/catalogo_service.dart';
import '../services/producto_service.dart';
import '../widgets/utilidades.dart';

// Crea un producto nuevo o edita uno existente (solo admin / seller).
class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  List<ItemCatalogo> _categorias = [];
  List<ItemCatalogo> _marcas = [];
  List<ItemCatalogo> _tipos = [];
  int? _categoriaId;
  int? _marcaId;
  int? _tipoId;

  bool _cargando = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    if (p != null) {
      _nombreController.text = p.nombre;
      _descripcionController.text = p.descripcion ?? '';
      _precioController.text = p.precio.toString();
      _categoriaId = p.categoriaId;
      _marcaId = p.marcaId;
      _tipoId = p.tipoId;
    }
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    try {
      final r = await Future.wait([
        CatalogoService.categorias.listar(),
        CatalogoService.marcas.listar(),
        CatalogoService.tipos.listar(),
      ]);
      if (!mounted) return;
      setState(() {
        _categorias = r[0];
        _marcas = r[1];
        _tipos = r[2];
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _cargando = false);
      avisar(context, 'No se pudieron cargar los catálogos: ${mensajeError(error)}');
    }
  }

  Future<void> _guardar() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final descripcion = _descripcionController.text.trim();
    final body = <String, dynamic>{
      'name': _nombreController.text.trim(),
      'description': descripcion.isEmpty ? null : descripcion,
      'unitPrice': double.parse(_precioController.text.trim().replaceAll(',', '.')),
      'categoryId': _categoriaId,
      'brandId': _marcaId,
      'typeId': _tipoId,
    };

    setState(() => _loading = true);
    try {
      if (widget.producto == null) {
        await ProductoService.crear(body);
      } else {
        await ProductoService.editar(widget.producto!.id, body);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      avisar(context, mensajeError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _selector(
    String etiqueta,
    List<ItemCatalogo> items,
    int? valor,
    void Function(int?) onChanged, {
    bool opcional = false,
  }) {
    return DropdownButtonFormField<int?>(
      value: valor,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        if (opcional) const DropdownMenuItem<int?>(value: null, child: Text('— Ninguno —')),
        ...items.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.nombre))),
      ],
      onChanged: onChanged,
      validator: opcional ? null : (v) => v == null ? 'Elige una opción' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.producto == null ? 'Nuevo producto' : 'Editar producto')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
                    ),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                    ),
                    TextFormField(
                      controller: _precioController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Precio unitario'),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Ingresa un precio mayor a 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _selector('Categoría', _categorias, _categoriaId,
                        (v) => setState(() => _categoriaId = v)),
                    _selector('Marca', _marcas, _marcaId, (v) => setState(() => _marcaId = v),
                        opcional: true),
                    _selector('Tipo', _tipos, _tipoId, (v) => setState(() => _tipoId = v),
                        opcional: true),
                    const SizedBox(height: 24),
                    if (_loading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
