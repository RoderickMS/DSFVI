class CartItem {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String imagenUrl;
  final double precio;
  int cantidad;

  CartItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.imagenUrl,
    required this.precio,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;
}