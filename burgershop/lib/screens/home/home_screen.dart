import 'package:flutter/material.dart';
import 'dart:async';
import '../historial/historial_screen.dart';
import '../menu/menu_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _imagenesBanner = const [
    "assets/imagenes/hamburguesa1.png",
    "assets/imagenes/hamburguesa2.png",
  ];

  int _indiceImagen = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _indiceImagen = (_indiceImagen + 1) % _imagenesBanner.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(context),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTarjetaMenuDestacada(context),
                    const SizedBox(height: 16),
                    _buildAccesosSecundarios(context),
                    const SizedBox(height: 28),
                    _buildTituloSeccion("Categorías populares"),
                    const SizedBox(height: 14),
                    _buildCategorias(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloSeccion(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ---------- Navegación ----------

  void _irAMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  void _irAPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PerfilScreen()),
    );
  }
  void _irAHistorial(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HistorialScreen(),
    ),
  );
}

  // ---------- Banner con imágenes rotando ----------

  Widget _buildBanner(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final altura = size.height * 0.36;

    return SizedBox(
      height: altura,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Image.asset(
              _imagenesBanner[_indiceImagen],
              key: ValueKey(_indiceImagen),
              fit: BoxFit.cover,
              width: double.infinity,
              height: altura,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black45, Colors.black38, Colors.black87],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(context),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "La mejor hamburguesa\npara hoy 🍔",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Descubre nuestras hamburguesas artesanales.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    _buildIndicadores(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadores() {
    return Row(
      children: List.generate(_imagenesBanner.length, (index) {
        final activo = index == _indiceImagen;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 6),
          width: activo ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: activo ? Colors.orange : Colors.white54,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _irAPerfil(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
          ),
        ),
        const Text(
          "BurgerRush",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Center(
                  child: Text("2", style: TextStyle(color: Colors.white, fontSize: 9)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Tarjeta grande destacada: "Ver menú" ----------
  // En vez de un ícono más del montón, la acción principal (ver el menú)
  // tiene su propia tarjeta ancha con gradiente, para que destaque sobre
  // las demás opciones secundarias.

  Widget _buildTarjetaMenuDestacada(BuildContext context) {
    return GestureDetector(
      onTap: () => _irAMenu(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A3D), Color(0xFFFF5F2E)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Explora el menú",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Hamburguesas, bebidas y más",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Accesos secundarios, más pequeños, debajo de la tarjeta principal ----------

  Widget _buildAccesosSecundarios(BuildContext context) {
    final accesos = [
      _Acceso(
        icono: Icons.shopping_cart_outlined,
        titulo: "Carrito",
        color: Colors.pinkAccent.shade200,
        onTap: () {
          // TODO: navegar a CarritoScreen
        },
      ),
      _Acceso(
        icono: Icons.receipt_long_outlined,
        titulo: "Historial",
        color: Colors.teal,
        onTap: () => _irAHistorial(context),
      ),
      _Acceso(
        icono: Icons.person_outline,
        titulo: "Perfil",
        color: Colors.indigo,
        onTap: () => _irAPerfil(context),
      ),
    ];

    return Row(
      children: accesos
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _buildAccesoSecundarioItem(item),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAccesoSecundarioItem(_Acceso item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(item.icono, color: item.color, size: 22),
            const SizedBox(height: 6),
            Text(
              item.titulo,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Categorías como tarjetas grandes con color completo ----------

  Widget _buildCategorias() {
    final categorias = [
      _Categoria(emoji: "🍔", nombre: "Burgers", color: const Color(0xFFFF8A3D)),
      _Categoria(emoji: "🍟", nombre: "Papas", color: const Color(0xFFFFC542)),
      _Categoria(emoji: "🥤", nombre: "Bebidas", color: const Color(0xFF4FC3F7)),
      _Categoria(emoji: "🧀", nombre: "Extras", color: const Color(0xFFFFD54F)),
      _Categoria(emoji: "🍗", nombre: "Pollo", color: const Color(0xFF8D6E63)),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categorias[index];
          return Container(
            width: 105,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cat.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cat.color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 30)),
                Text(
                  cat.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Acceso {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  _Acceso({
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });
}

class _Categoria {
  final String emoji;
  final String nombre;
  final Color color;

  _Categoria({required this.emoji, required this.nombre, required this.color});
}