import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildBanner(context),

                  const SizedBox(height: 25),

                  _buildCategorias(),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGrid(context, constraints.maxWidth),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: size.height * 0.42,
          child: Image.asset(
            "assets/imagenes/banner_burger.jpg",
            fit: BoxFit.cover,
          ),
        ),

        Container(
          height: size.height * 0.42,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black87,
                Colors.black54,
                Colors.transparent,
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              SizedBox(height: size.height * 0.08),

              const Text(
                "La mejor hamburguesa\npara hoy 🍔",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Descubre nuestras hamburguesas artesanales.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  // Navigator.pushNamed(context, '/menu');
                },
                child: const Text(
                  "Ver menú",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),

        const Text(
          "BurgerRush",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),

            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCategorias() {
    final categorias = [
      "🍔",
      "🍟",
      "🥤",
      "🧀",
      "🍗",
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          return Container(
            width: 75,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                )
              ],
            ),
            child: Center(
              child: Text(
                categorias[index],
                style: const TextStyle(fontSize: 32),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, double width) {
    int columnas = 2;

    if (width > 1000) {
      columnas = 4;
    } else if (width > 700) {
      columnas = 3;
    }

    final opciones = [
      _Acceso(
        icono: Icons.restaurant_menu,
        titulo: "Menú",
        subtitulo: "Ver hamburguesas",
        color: Colors.orange,
      ),
      _Acceso(
        icono: Icons.shopping_cart,
        titulo: "Carrito",
        subtitulo: "Tus pedidos",
        color: Colors.deepOrange,
      ),
      _Acceso(
        icono: Icons.receipt_long,
        titulo: "Historial",
        subtitulo: "Pedidos anteriores",
        color: Colors.brown,
      ),
      _Acceso(
        icono: Icons.person,
        titulo: "Perfil",
        subtitulo: "Tu cuenta",
        color: Colors.grey,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: opciones.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = opciones[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: item.color.withOpacity(0.15),
                child: Icon(
                  item.icono,
                  color: item.color,
                  size: 30,
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item.subtitulo,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _Acceso {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;

  _Acceso({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
  });
}