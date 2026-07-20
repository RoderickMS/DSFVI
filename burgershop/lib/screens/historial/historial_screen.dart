import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColors {
  static const background = Color(0xFFFFF8F2);
  static const primary = Color(0xFFFF7A00);
  static const primaryDark = Color(0xFFE65100);
  static const textDark = Color(0xFF1C1C1E);
  static const textGrey = Color(0xFF8E8E93);
  static const cardShadow = Color(0x14000000);
}

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case "completado":
      case "entregado":
        return const Color(0xFF2E7D32);
      case "en proceso":
      case "preparando":
        return AppColors.primary;
      case "cancelado":
        return const Color(0xFFE53935);
      default:
        return AppColors.textGrey; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text(
                "Usuario no autenticado",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Historial de pedidos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pedidos")
            .where(
              "usuarioId",
              isEqualTo: usuario.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Text("🍔", style: TextStyle(fontSize: 44)),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "No tienes pedidos todavía",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Cuando hagas tu primer pedido\naparecerá aquí",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500, height: 1.4),
                  ),
                ],
              ),
            );
          }

          final pedidos = snapshot.data!.docs;

          return LayoutBuilder(
            builder: (context, constraints) {
              final anchoAmplio = constraints.maxWidth > 700;
              final columnas = constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 700
                      ? 2
                      : 1;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: anchoAmplio ? 1000 : double.infinity),
                  child: columnas == 1
                      ? ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pedidos.length,
                          itemBuilder: (context, index) {
                            return _PedidoCard(
                              pedido: pedidos[index],
                              colorEstado: _colorEstado,
                            );
                          },
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: pedidos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columnas,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 3.4,
                          ),
                          itemBuilder: (context, index) {
                            return _PedidoCard(
                              pedido: pedidos[index],
                              colorEstado: _colorEstado,
                            );
                          },
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final QueryDocumentSnapshot pedido;
  final Color Function(String estado) colorEstado;

  const _PedidoCard({required this.pedido, required this.colorEstado});

  @override
  Widget build(BuildContext context) {
    final data = pedido.data() as Map<String, dynamic>? ?? {};

    final String estado = (data['estado'] as String?) ?? "Pendiente";
    final color = colorEstado(estado);
    final total = data['total'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pedido #${pedido.id.substring(0, 6)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total: \$$total",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              estado,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}