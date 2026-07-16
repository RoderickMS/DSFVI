import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:burgershop/screens/home/home_screen.dart';
import 'package:burgershop/screens/register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    setState(() => _cargando = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case "user-not-found":
          mensaje = "No existe un usuario con este correo";
          break;
        case "wrong-password":
          mensaje = "La contraseña es incorrecta";
          break;
        case "invalid-email":
          mensaje = "Correo inválido";
          break;
        case "invalid-credential":
          mensaje = "Correo o contraseña incorrectos";
          break;
        default:
          mensaje = e.message ?? "Error desconocido";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color naranja suave para el fondo de la tarjeta inferior.
    const Color fondoSuave = Color(0xFFFFE9D9);

    return Scaffold(
      backgroundColor: fondoSuave,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final anchoDisponible = constraints.maxWidth;

          // En pantallas grandes (tablet/desktop) limitamos el ancho de la
          // tarjeta para que no se vea estirada, y la centramos.
          final anchoTarjeta =
              anchoDisponible > 600 ? 480.0 : anchoDisponible;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: anchoTarjeta),
                child: Column(
                  children: [
                    _buildEncabezado(context),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: fondoSuave,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "¡Bienvenido de nuevo!",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Inicia sesión para seguir pidiendo",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 30),
                            _buildCampoEmail(),
                            const SizedBox(height: 18),
                            _buildCampoPassword(),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: recuperación de contraseña
                                },
                                child: const Text(
                                  "¿Olvidaste tu contraseña?",
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildBotonIniciarSesion(),
                            const SizedBox(height: 18),
                            _buildDivisorOo(),
                            const SizedBox(height: 18),
                            _buildBotonGoogle(),
                            const SizedBox(height: 24),
                            _buildLinkCrearCuenta(context),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------- Encabezado: la imagen cubre todo el espacio naranja ----------

  Widget _buildEncabezado(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Altura relativa a la pantalla, con límites para que no se vea
    // demasiado alta en tablet/desktop ni demasiado baja en celulares chicos.
    double alturaEncabezado = size.height * 0.34;
    if (alturaEncabezado < 220) alturaEncabezado = 220;
    if (alturaEncabezado > 340) alturaEncabezado = 340;

    return SizedBox(
      width: double.infinity,
      height: alturaEncabezado,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // La imagen ahora ocupa TODO el espacio naranja de arriba.
          // Ajusta la ruta si tu logo/imagen está en otra carpeta.
          Image.asset(
            "assets/imagenes/logo.png",
            fit: BoxFit.cover,
          ),
          // Degradado sutil sobre la imagen para que el texto se lea bien
          // y para que la transición hacia la tarjeta blanca sea suave.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black45,
                ],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          // Título superpuesto sobre la imagen.
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Text(
              "BurgerRush",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Campos de texto ----------

  Widget _buildCampoEmail() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCampoPassword() {
    return TextField(
      controller: passwordController,
      obscureText: _ocultarPassword,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() => _ocultarPassword = !_ocultarPassword);
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------- Botones ----------

  Widget _buildBotonIniciarSesion() {
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
        onPressed: _cargando ? null : iniciarSesion,
        child: _cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                "Iniciar sesión",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDivisorOo() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("o", style: TextStyle(color: Colors.grey.shade500)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildBotonGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: Google Sign-In
        },
        icon: const Icon(Icons.login),
        label: const Text(
          "Continuar con Google",
          style: TextStyle(fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCrearCuenta(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¿No tienes cuenta?",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text(
              "Crear cuenta",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }
}