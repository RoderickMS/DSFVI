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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final anchoPantalla = constraints.maxWidth;
          final esTablet = anchoPantalla > 700;
          final esEscritorio = anchoPantalla > 1100;

          final anchoContenido = esEscritorio
              ? 1000.0
              : esTablet
                  ? 780.0
                  : anchoPantalla;

          final columnasCategorias = esEscritorio
              ? 5
              : esTablet
                  ? 5
                  : 3;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBanner(context),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8F2),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: esTablet ? 32 : 20,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: anchoContenido),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            esTablet

                                ? IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _buildTarjetaMenuDestacada(context),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: _buildBarraHistorial(context, vertical: true),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildTarjetaMenuDestacada(context),
                                      const SizedBox(height: 14),
                                      _buildBarraHistorial(context),
                                    ],
                                  ),
                            const SizedBox(height: 28),
                            _buildTituloSeccion("Categorías populares"),
                            const SizedBox(height: 14),
                            _buildCategorias(columnasCategorias),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
      MaterialPageRoute(builder: (context) => const HistorialScreen()),
    );
  }


  Widget _buildBanner(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final altura = size.height * 0.36;

    return SizedBox(
      height: altura,
      width: double.infinity,
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
          "BurgerShop",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 42),
      ],
    );
  }


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
                mainAxisSize: MainAxisSize.min,
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


  Widget _buildBarraHistorial(BuildContext context, {bool vertical = false}) {
    if (vertical) {
      return GestureDetector(
        onTap: () => _irAHistorial(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_outlined, color: Colors.teal, size: 20),
              ),
              const SizedBox(height: 14),
              const Text(
                "Historial de pedidos",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Ver pedidos",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _irAHistorial(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_outlined, color: Colors.teal, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Historial de pedidos",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }


  Widget _buildCategorias(int columnas) {
    final categorias = [
      _Categoria(emoji: "🍔", nombre: "Burgers", color: const Color(0xFFFF8A3D)),
      _Categoria(emoji: "🍟", nombre: "Papas", color: const Color(0xFFFFC542)),
      _Categoria(emoji: "🥤", nombre: "Bebidas", color: const Color(0xFF4FC3F7)),
      _Categoria(emoji: "🧀", nombre: "Extras", color: const Color(0xFFFFD54F)),
      _Categoria(emoji: "🍗", nombre: "Pollo", color: const Color(0xFF8D6E63)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categorias.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final cat = categorias[index];
        return Container(
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
              Text(cat.emoji, style: const TextStyle(fontSize: 28)),
              Text(
                cat.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Categoria {
  final String emoji;
  final String nombre;
  final Color color;

  _Categoria({required this.emoji, required this.nombre, required this.color});
}