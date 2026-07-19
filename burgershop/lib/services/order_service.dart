import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> crearPedido({
    required List<CartItem> productos,
    required String metodoPago,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception("Usuario no autenticado");
    }

    double subtotal = 0;

    for (final item in productos) {
      subtotal += item.subtotal;
    }

    final itbms = subtotal * 0.07;
    final total = subtotal + itbms;

    final pedidoRef = await _db.collection("pedidos").add({
      "usuarioId": usuario.uid,
      "correoCliente": usuario.email,
      "fecha": FieldValue.serverTimestamp(),
      "metodoPago": metodoPago,
      "estadoPago": "Pendiente",
      "estadoPedido": "Pendiente",
      "subtotal": subtotal,
      "itbms": itbms,
      "total": total,
    });

    for (final item in productos) {
      await pedidoRef.collection("productos").add({
        "productoId": item.id,
        "nombre": item.nombre,
        "descripcion": item.descripcion,
        "categoria": item.categoria,
        "precio": item.precio,
        "cantidad": item.cantidad,
        "subtotal": item.subtotal,
        "imagenUrl": item.imagenUrl,
      });
    }

    return pedidoRef.id;
  }
}