import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addProduct(CartItem producto) {
    final index = _items.indexWhere((item) => item.id == producto.id);

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(producto);
    }

    notifyListeners();
  }

  void removeProduct(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void aumentarCantidad(String id) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  void disminuirCantidad(String id) {
    final index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  double get total {
    return _items.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}