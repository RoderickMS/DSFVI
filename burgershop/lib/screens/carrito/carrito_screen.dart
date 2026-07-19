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
      appBar: AppBar(
        title: const Text("Mi Carrito"),
        backgroundColor: Colors.orange,
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                "Tu carrito está vacío",
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: item.imagenUrl.isNotEmpty
                              ? Image.network(
                                  item.imagenUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood),

                          title: Text(item.nombre),

                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "\$${item.precio.toStringAsFixed(2)}"),
                              Text(
                                  "Cantidad: ${item.cantidad}"),
                            ],
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  cart.disminuirCantidad(item.id);
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  cart.aumentarCantidad(item.id);
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  cart.removeProduct(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.black12,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${cart.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            "Proceder al pago",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}