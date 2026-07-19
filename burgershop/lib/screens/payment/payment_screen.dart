import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burgershop/providers/cart_provider.dart';
import 'package:burgershop/screens/payment/yappy_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String metodo = "Yappy";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Método de pago"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Seleccione un método de pago",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            RadioListTile(
              value: "Efectivo",
              groupValue: metodo,
              title: const Text("Efectivo"),
              onChanged: (value) {
                setState(() {
                  metodo = value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Tarjeta",
              groupValue: metodo,
              title: const Text("Tarjeta"),
              onChanged: (value) {
                setState(() {
                  metodo = value.toString();
                });
              },
            ),

            RadioListTile(
              value: "Yappy",
              groupValue: metodo,
              title: const Text("Yappy"),
              onChanged: (value) {
                setState(() {
                  metodo = value.toString();
                });
              },
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "B/. ${cart.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {

                  if (metodo == "Yappy") {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const YappyScreen(),
                      ),
                    );

                  }

                  if (metodo == "Efectivo") {

                    // Después guardaremos el pedido aquí

                  }

                  if (metodo == "Tarjeta") {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Próximamente"),
                      ),
                    );

                  }

                },
                child: const Text(
                  "Continuar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}