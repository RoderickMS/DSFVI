import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burgershop/providers/cart_provider.dart';
import 'package:burgershop/services/order_service.dart';


class YappyScreen extends StatelessWidget {
  const YappyScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pago con Yappy"),
        backgroundColor: Colors.orange,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          children: [

            const SizedBox(height: 20),

            const Text(
              "Escanee el código QR",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: 250,
              height: 250,
              color: Colors.grey.shade300,
              child: const Center(
                child: Text(
                  "QR",
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Número Yappy",
              style: TextStyle(fontSize: 18),
            ),

            const Text(
              "6000-1234",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),

                onPressed: () async {

                  final cart = Provider.of<CartProvider>(
                    context,
                    listen: false,
                  );

                  try {

                    final pedidoId = await OrderService().crearPedido(
                      productos: cart.items,
                      metodoPago: "Yappy",
                    );

                    cart.clearCart();

                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AlertDialog(

                        title: const Text("Pedido realizado"),

                        content: Text(
                          "Su pedido fue registrado correctamente.\n\n"
                          "Número de pedido:\n$pedidoId",
                        ),

                        actions: [

                          TextButton(
                            onPressed: () {

                              Navigator.pop(context);

                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );

                            },
                            child: const Text("Aceptar"),
                          )

                        ],

                      ),
                    );

                  } catch (e) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                      ),
                    );

                  }

                },

                child: const Text(
                  "Ya realicé el pago",
                ),

              ),
            )

          ],
        ),
      ),

    );

  }

}