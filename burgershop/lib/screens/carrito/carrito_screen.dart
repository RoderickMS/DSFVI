import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burgershop/providers/cart_provider.dart';
import 'package:burgershop/screens/payment/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Mi carrito",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cart.items.isEmpty
          ? _buildCarritoVacio()
          : _buildListaConItems(context, cart),
      bottomNavigationBar:
          cart.items.isEmpty ? null : _buildResumenYBoton(context, cart),
    );
  }

  // ---------- Estado vacío ----------

  Widget _buildCarritoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🛒", style: TextStyle(fontSize: 60)),
            const SizedBox(height: 15),
            const Text(
              "Tu carrito está vacío",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Agrega productos desde el menú para verlos aquí.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Lista de productos ----------

  Widget _buildListaConItems(BuildContext context, CartProvider cart) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildItemCard(cart, item);
      },
    );
  }

  Widget _buildItemCard(CartProvider cart, dynamic item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagenProducto(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeProduct(item.id),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade300,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${item.precio.toStringAsFixed(2)} c/u",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                _buildControlCantidad(cart, item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagenProducto(dynamic item) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        image: item.imagenUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(item.imagenUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: item.imagenUrl.isEmpty
          ? const Center(child: Text("🍔", style: TextStyle(fontSize: 26)))
          : null,
    );
  }

  // Botones +/- para ajustar cantidad, misma lógica que ya tenías.
  Widget _buildControlCantidad(CartProvider cart, dynamic item) {
    return Row(
      children: [
        _buildBotonCantidad(
          icono: Icons.remove,
          onTap: () => cart.disminuirCantidad(item.id),
        ),
        SizedBox(
          width: 32,
          child: Text(
            "${item.cantidad}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        _buildBotonCantidad(
          icono: Icons.add,
          onTap: () => cart.aumentarCantidad(item.id),
        ),
      ],
    );
  }

  Widget _buildBotonCantidad({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, size: 16, color: Colors.orange),
      ),
    );
  }

  // ---------- Resumen y botón de pago ----------

  Widget _buildResumenYBoton(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "\$${cart.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentScreen(),
                  ),
                );
              },
              child: const Text(
                "Proceder al pago",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}