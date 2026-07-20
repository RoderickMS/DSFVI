import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:burgershop/providers/cart_provider.dart';
import 'package:burgershop/screens/payment/yappy_screen.dart';
import 'package:burgershop/services/order_service.dart';


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String metodo = "Yappy";
  final OrderService orderService = OrderService();


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
          "Método de pago",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Seleccione un método de pago",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildOpcionMetodo(
              value: "Efectivo",
              titulo: "Efectivo",
              emoji: "💵",
              colorAcento: Colors.green.shade600,
            ),

            const SizedBox(height: 12),

            _buildOpcionMetodo(
              value: "Tarjeta",
              titulo: "Tarjeta",
              emoji: "💳",
              colorAcento: Colors.blue.shade600,
            ),

            const SizedBox(height: 12),

            _buildOpcionMetodo(
              value: "Yappy",
              titulo: "Yappy",
              emoji: "💜",
              colorAcento: const Color(0xFF6F2DBD),
            ),

            const Spacer(),

            _buildResumenTotal(cart),

            const SizedBox(height: 20),

            _buildBotonContinuar(context, cart),
          ],
        ),
      ),
    );
  }

  //Tarjeta seleccionable de cada método

  Widget _buildOpcionMetodo({
    required String value,
    required String titulo,
    required String emoji,
    required Color colorAcento,
  }) {
    final seleccionado = metodo == value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: seleccionado ? colorAcento : Colors.black12,
          width: seleccionado ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: metodo,
        onChanged: (nuevoValor) {
          setState(() {
            metodo = nuevoValor.toString();
          });
        },
        activeColor: colorAcento,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorAcento.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  //Resumen del total

Widget _buildResumenTotal(CartProvider cart) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
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
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Subtotal"),
            Text("B/. ${cart.subtotal.toStringAsFixed(2)}"),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("ITBMS (7%)"),
            Text("B/. ${cart.itbms.toStringAsFixed(2)}"),
          ],
        ),

        const Divider(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total a pagar",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "B/. ${cart.totalConItbms.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildBotonContinuar(BuildContext context, CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {

          if (metodo == "Yappy") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const YappyScreen(),
              ),
            );
          }


          if (metodo == "Efectivo") {

            try {

              await orderService.crearPedido(
                productos: cart.items,
                metodoPago: metodo,
              );


              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Pedido creado correctamente"),
                ),
              );


            } catch (e) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: $e"),
                ),
              );

            }

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
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}