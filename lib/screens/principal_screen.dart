import 'package:flutter/material.dart';

import '../models/item_catalogo.dart';
import '../models/producto.dart';
import '../models/variante.dart';
import '../services/api_service.dart';
import '../services/carrito_service.dart';
import '../services/catalogo_service.dart';
import '../services/producto_service.dart';
import '../services/sesion.dart';
import '../services/usuario_service.dart';
import '../widgets/producto_imagen.dart';
import '../widgets/utilidades.dart';
import 'admin_screen.dart';
import 'carrito_screen.dart';
import 'direcciones_screen.dart';
import 'editar_screen.dart';
import 'login_screen.dart';
import 'pedidos_screen.dart';
import 'producto_detalle_screen.dart';
import 'producto_form_screen.dart';
import 'registro_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  late Future<List<Producto>> _productos;
  final _busquedaController = TextEditingController();

  List<ItemCatalogo> _categorias = [];
  int? _categoriaId;
  String _busqueda = '';
  bool _cerrandoSesion = false;

  // Productos que ya se agregaron al carrito con el corazón.
  final Set<int> _enCarrito = {};

  @override
  void initState() {
    super.initState();
    _productos = ProductoService.listar();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    try {
      final categorias = await CatalogoService.categorias.listar();
      if (mounted) setState(() => _categorias = categorias);
    } catch (_) {
      // Si falla, el catálogo igual se muestra sin el filtro.
    }
  }

  void _cargarProductos() {
    setState(() {
      _productos = ProductoService.listar(categoryId: _categoriaId);
    });
  }

  void _elegirCategoria(int? id) {
    _categoriaId = id;
    _cargarProductos();
  }

  // Abre una pantalla que necesita sesión; si no hay, manda al login.
  void _abrir(Widget pantalla) {
    if (Sesion.haySesion) {
      irA(context, pantalla);
    } else {
      irA(context, const LoginScreen());
    }
  }

  Future<void> _cerrarSesion() async {
    setState(() => _cerrandoSesion = true);
    await UsuarioService.cerrarSesion();
    if (!mounted) return;
    irAyLimpiar(context, const LoginScreen());
  }

  Future<void> _abrirPerfil() async {
    final usuario = Sesion.usuario;
    if (usuario == null) {
      irA(context, const LoginScreen());
      return;
    }

    final cambio = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => EditarScreen(user: usuario)),
    );
    if (!mounted || cambio != true) return;

    try {
      await UsuarioService.cargarSesion();
    } catch (_) {
      // Si el usuario ya no existe (lo eliminó), cerramos la sesión.
      await UsuarioService.cerrarSesion();
      if (!mounted) return;
      irAyLimpiar(context, const LoginScreen());
    }
  }

  Future<void> _abrirDetalle(Producto producto) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => ProductoDetalleScreen(producto: producto)),
    );
    if (mounted) _cargarProductos();
  }

  Future<void> _nuevoProducto() async {
    final creado = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(builder: (_) => const ProductoFormScreen()),
    );
    if (creado == true && mounted) _cargarProductos();
  }

  // Corazón: agrega 1 unidad del producto al carrito.
  Future<void> _agregarAlCarrito(Producto producto) async {
    if (!Sesion.haySesion) {
      avisar(context, 'Inicia sesión para agregar al carrito');
      irA(context, const LoginScreen());
      return;
    }

    try {
      final todas = await VarianteService.porProducto(producto.id);
      final variantes = todas.where((v) => v.stock > 0).toList();
      if (!mounted) return;

      if (variantes.isEmpty) {
        avisar(context, 'Sin stock disponible por ahora');
        return;
      }

      // Si hay varias tallas/colores, el usuario elige una.
      Variante? elegida;
      if (variantes.length == 1) {
        elegida = variantes.first;
      } else {
        elegida = await showModalBottomSheet<Variante>(
          context: context,
          builder: (sheetContext) => ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Elige talla / color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              for (final v in variantes)
                ListTile(
                  title: Text(v.descripcion),
                  subtitle: Text('Stock ${v.stock}'),
                  onTap: () => Navigator.pop(sheetContext, v),
                ),
            ],
          ),
        );
      }
      if (elegida == null) return;

      await CarritoService.agregar(Sesion.userId, elegida.id, 1);
      if (!mounted) return;
      setState(() => _enCarrito.add(producto.id));
      avisar(context, 'Agregado al carrito');
    } catch (error) {
      if (mounted) avisar(context, mensajeError(error));
    }
  }

  // Nombre de la categoría de un producto.
  String _nombreCategoria(Producto p) {
    if (p.categoria != null) return p.categoria!;
    for (final c in _categorias) {
      if (c.id == p.categoriaId) return c.nombre;
    }
    return 'Sin categoría';
  }

  // Aplica el texto de la búsqueda.
  List<Producto> _filtrar(List<Producto> productos) {
    final texto = _busqueda.trim().toLowerCase();
    if (texto.isEmpty) return productos;

    return productos.where((p) {
      final contenido = '${p.nombre} ${p.descripcion ?? ''} ${p.marca ?? ''} '
              '${p.categoria ?? ''} ${p.tipo ?? ''}'
          .toLowerCase();
      return contenido.contains(texto);
    }).toList();
  }

  Widget _chipsCategorias() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todos'),
              selected: _categoriaId == null,
              onSelected: (_) => _elegirCategoria(null),
            ),
          ),
          for (final categoria in _categorias)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria.nombre),
                selected: _categoriaId == categoria.id,
                onSelected: (_) => _elegirCategoria(categoria.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tarjeta(Producto producto) {
    final enCarrito = _enCarrito.contains(producto.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _abrirDetalle(producto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto con el corazón encima
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF1B1D23),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductoImagen(productoId: producto.id),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.black54),
                        onPressed: () => _agregarAlCarrito(producto),
                        icon: Icon(
                          enCarrito ? Icons.favorite : Icons.favorite_border,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nombre, marca y precio
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [producto.marca, producto.categoria].whereType<String>().join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                    const Spacer(),
                    Text(
                      precio(producto.precio),
                      style: const TextStyle(
                        color: Color(0xFFFF5555),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catalogo() {
    return FutureBuilder<List<Producto>>(
      future: _productos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 55, color: Colors.redAccent),
                const SizedBox(height: 15),
                const Text('No se pudieron cargar los productos'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _cargarProductos,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final productos = _filtrar(snapshot.data ?? []);
        if (productos.isEmpty) {
          return const Center(child: Text('No encontramos productos'));
        }

        // Agrupamos los productos por categoría.
        final grupos = <String, List<Producto>>{};
        for (final p in productos) {
          final nombre = _nombreCategoria(p);
          if (!grupos.containsKey(nombre)) grupos[nombre] = [];
          grupos[nombre]!.add(p);
        }

        // Cuántas columnas caben según el ancho de la pantalla.
        final ancho = MediaQuery.of(context).size.width;
        int columnas = 2;
        if (ancho >= 1100) {
          columnas = 4;
        } else if (ancho >= 750) {
          columnas = 3;
        }

        // Una sección por categoría: título + cuadrícula de productos.
        final secciones = <Widget>[];
        grupos.forEach((categoria, lista) {
          if (_categoriaId == null) {
            secciones.add(Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                categoria,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ));
          }
          secciones.add(GridView.count(
            crossAxisCount: columnas,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: lista.map(_tarjeta).toList(),
          ));
        });

        return RefreshIndicator(
          onRefresh: () async {
            _cargarProductos();
            await _productos;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
            children: secciones,
          ),
        );
      },
    );
  }

  void _elegirMenu(String opcion) {
    if (opcion == 'perfil') _abrirPerfil();
    if (opcion == 'direcciones') _abrir(const DireccionesScreen());
    if (opcion == 'admin') _abrir(const AdminScreen());
    if (opcion == 'login') irA(context, const LoginScreen());
    if (opcion == 'registro') irA(context, const RegistroScreen());
    if (opcion == 'salir') _cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.storefront, color: Color(0xFFE53935)),
            SizedBox(width: 9),
            Text('Mi Tienda'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _abrir(const CarritoScreen()),
          ),
          if (Sesion.haySesion)
            IconButton(
              tooltip: 'Mis pedidos',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () => _abrir(const PedidosScreen()),
            ),
          PopupMenuButton<String>(
            enabled: !_cerrandoSesion,
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: _elegirMenu,
            itemBuilder: (_) => [
              if (Sesion.haySesion) ...[
                const PopupMenuItem(value: 'perfil', child: Text('Mi perfil')),
                const PopupMenuItem(value: 'direcciones', child: Text('Mis direcciones')),
                if (Sesion.esStaff)
                  const PopupMenuItem(value: 'admin', child: Text('Administración')),
                const PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
              ] else ...[
                const PopupMenuItem(value: 'login', child: Text('Iniciar sesión')),
                const PopupMenuItem(value: 'registro', child: Text('Crear cuenta')),
              ],
            ],
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _busquedaController,
                  onChanged: (valor) => setState(() => _busqueda = valor),
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _busqueda = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                _chipsCategorias(),
              ],
            ),
          ),
          Expanded(child: _catalogo()),
        ],
      ),
      floatingActionButton: Sesion.esStaff
          ? FloatingActionButton.extended(
              onPressed: _nuevoProducto,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo producto'),
            )
          : null,
    );
  }
}
