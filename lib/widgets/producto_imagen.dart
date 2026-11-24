import 'package:flutter/material.dart';

class ProductoImagen extends StatelessWidget {
  final int productoId;
  final BoxFit fit;
  final double iconSize;

  const ProductoImagen({
    super.key,
    required this.productoId,
    this.fit = BoxFit.cover,
    this.iconSize = 65,
  });

  Widget _vacio() => Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: iconSize,
          color: const Color(0xFF777B89),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final base = 'lib/assets/images/productos/$productoId';
    return Image.asset(
      '$base.jpg',
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Image.asset(
        '$base.png',
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _vacio(),
      ),
    );
  }
}
