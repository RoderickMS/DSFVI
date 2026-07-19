import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:burgershop/screens/carrito/carrito_screen.dart';
import 'package:provider/provider.dart';
import 'package:burgershop/models/cart_item.dart';
import 'package:burgershop/providers/cart_provider.dart';



class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _categoriaSeleccionada = "Todas";




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildCategorias(),
            const SizedBox(height: 10),
            Expanded(child: _buildContenido()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87,
          ),
          const Text(
            "Nuestro Menú",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  // Las categorías también pueden salir de Firestore (colección /categorias).
  // Por ahora dejamos una lista fija + "Todas".
  Widget _buildCategorias() {
    final categorias = ["Todas", "Hamburguesas", "Bebidas", "Postres"];

    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final seleccionada = categoria == _categoriaSeleccionada;

          return ChoiceChip(
            label: Text(categoria),
            selected: seleccionada,
            selectedColor: Colors.orange,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: seleccionada ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.orange.shade200),
            ),
            onSelected: (_) {
              setState(() => _categoriaSeleccionada = categoria);
            },
          );
        },
      ),
    );
  }

  Widget _buildContenido() {
    // Solo trae productos disponibles - el switch que maneja el admin
    Query query = FirebaseFirestore.instance
        .collection('productos')
        .where('disponible', isEqualTo: true);

    // Si hay categoría seleccionada distinta de "Todas", filtramos también
    if (_categoriaSeleccionada != "Todas") {
      query = query.where('categoria', isEqualTo: _categoriaSeleccionada);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("🍔", style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 15),
                  const Text(
                    "Aún no hay productos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "El menú estará disponible muy pronto.\nVuelve más tarde para ver nuestras hamburguesas.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final doc = docs[index];

            final data = doc.data() as Map<String, dynamic>;

            return _buildProductoCard(data, doc.id);
          },
        );
      },
    );
  }

  Widget _buildProductoCard(
  Map<String, dynamic> producto,
  String productoId,
) {
    final nombre = producto['nombre'] ?? '';
    final precio = (producto['precio'] ?? 0).toDouble();
    final imagenUrl = producto['imagenUrl'] ?? '';

    return GestureDetector(
      onTap: () {
        // TODO: navegar al detalle del producto
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: imagenUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imagenUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imagenUrl.isEmpty
                    ? const Center(
                        child: Text("🍔", style: TextStyle(fontSize: 40)),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${precio.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addProduct(
                              CartItem(
                                id: productoId,
                                nombre: producto['nombre'] ?? '',
                                descripcion: producto['descripcion'] ?? '',
                                categoria: producto['categoria'] ?? '',
                                imagenUrl: producto['imagenUrl'] ?? '',
                                precio: (producto['precio'] ?? 0).toDouble(),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${producto['nombre']} agregado al carrito"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}