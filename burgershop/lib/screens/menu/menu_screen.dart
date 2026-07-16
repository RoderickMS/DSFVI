import 'package:flutter/material.dart';

// Versión sin datos de ejemplo — así se ve el Menú cuando todavía
// no hay productos cargados por el admin (o antes de conectar Firestore).
//
// TODO: cuando conectes Firestore, reemplaza _categorias (lista fija)
// y _productos (lista vacía) por streams reales de las colecciones
// /categorias y /productos. Cuando el admin agregue productos, esta
// misma pantalla los mostrará automáticamente sin más cambios de UI.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _categoriaSeleccionada = "Todas";

  final List<String> _categorias = [
    "Todas",
    "Hamburguesas",
    "Bebidas",
    "Postres",
  ];

  // Sin productos todavía — el admin aún no ha agregado ninguno.
  final List<Map<String, dynamic>> _productos = [];

  List<Map<String, dynamic>> get _productosFiltrados {
    if (_categoriaSeleccionada == "Todas") return _productos;
    return _productos
        .where((p) => p["categoria"] == _categoriaSeleccionada)
        .toList();
  }

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                "Nuestro Menú",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              // TODO: navegar al carrito
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
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

  // Estado vacío: se muestra mientras el admin no ha agregado productos.
  Widget _buildContenido() {
    final productos = _productosFiltrados;

    if (productos.isEmpty) {
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

    // Cuando ya existan productos (agregados por el admin), se mostrarán
    // aquí en un grid, igual que en la versión anterior con datos de ejemplo.
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      itemCount: productos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final producto = productos[index];
        return _buildProductoCard(producto);
      },
    );
  }

  Widget _buildProductoCard(Map<String, dynamic> producto) {
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
                ),
                child: const Center(
                  child: Text("🍔", style: TextStyle(fontSize: 40)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto["nombre"],
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
                        "\$${producto["precio"].toStringAsFixed(2)}",
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
                            // TODO: agregar producto al carrito
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