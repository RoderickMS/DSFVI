import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burgershop/services/auth_service.dart';
import 'package:burgershop/screens/admin/admin_screen.dart';
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
  final AuthService authService = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // LÓGICA — sin cambios respecto a tu versión original.
  // =========================================================

  Future<void> iniciarSesion() async {
    setState(() {
      _cargando = true;
    });

    try {
      // Iniciar sesión con Firebase Authentication
      UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? usuario = credencial.user;

      if (usuario == null) {
        return;
      }

      // Obtener información del usuario desde Firestore
      DocumentSnapshot datosUsuario =
          await FirebaseFirestore.instance.collection("usuarios").doc(usuario.uid).get();

      if (!datosUsuario.exists) {
        throw Exception("No existe información del usuario");
      }

      // Obtener rol del usuario
      String rol = datosUsuario["rol"];

      if (!mounted) return;

      // Redirección según el rol
      if (rol == "administrador") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminScreen()),
        );
      } else if (rol == "cliente") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rol de usuario inválido")),
        );
      }
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
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> iniciarGoogle() async {
    try {
      String rol = await authService.loginGoogle();

      if (!mounted) return;

      if (rol == "administrador") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // =========================================================
  // DISEÑO
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE9D9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En pantallas anchas (tablet/computadora) limitamos el ancho
            // del formulario completo, para que el logo no se estire de
            // borde a borde y se vea pequeño con mucho espacio vacío.
            final anchoPantalla = constraints.maxWidth;
            final anchoMaximo = anchoPantalla > 600 ? 480.0 : anchoPantalla;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: anchoMaximo),
                  child: Column(
                    children: [
                      _buildEncabezado(),
                      _buildTarjetaFormulario(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Encabezado con logo: se mantiene igual (fondo desenfocado + logo
  // nítido encima), solo se extrajo a su propio método.
  // ---------------------------------------------------------------
  Widget _buildEncabezado() {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Capa 1: la misma imagen de fondo, recortada (cover) y
          // desenfocada. El recorte no se nota porque el blur difumina
          // los bordes — funciona en cualquier proporción de pantalla
          // sin dejar espacios vacíos.
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Image.asset(
              "assets/imagenes/logo.png",
              fit: BoxFit.cover,
            ),
          ),

          // Oscurece un poco el fondo desenfocado para que el logo
          // nítido de encima resalte con más contraste.
          Container(color: Colors.black.withOpacity(0.35)),

          // Capa 2: el logo real, completo y nítido, sin recortar
          // ningún texto.
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                "assets/imagenes/logo.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Tarjeta blanca del formulario: antes el fondo del formulario era
  // del mismo color que el Scaffold (0xFFFFE9D9), así que no había
  // ningún contraste entre "página" y "tarjeta". Ahora es blanca, con
  // esquinas redondeadas arriba y una sombra sutil hacia arriba, para
  // que se sienta como una tarjeta elevada sobre el fondo durazno.
  // ---------------------------------------------------------------
  Widget _buildTarjetaFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "¡Bienvenido de nuevo!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
          ),
          const SizedBox(height: 6),
          Text(
            "Inicia sesión para continuar",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),
          _buildCampoEmail(),
          const SizedBox(height: 16),
          _buildCampoPassword(),
          const SizedBox(height: 26),
          _buildBotonIniciarSesion(),
          const SizedBox(height: 20),
          _buildDivisorOr(),
          const SizedBox(height: 20),
          _buildBotonGoogle(),
          const SizedBox(height: 22),
          _buildCrearCuenta(),
        ],
      ),
    );
  }

  Widget _buildCampoEmail() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F3F0),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 1.6),
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
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _ocultarPassword = !_ocultarPassword;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFFF7F3F0),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildBotonIniciarSesion() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _cargando ? null : iniciarSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _cargando
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                "Iniciar sesión",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildDivisorOr() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text("o continúa con", style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  Widget _buildBotonGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: iniciarGoogle,
        icon: const Text("G", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        label: const Text(
          "Continuar con Google",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildCrearCuenta() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("¿No tienes cuenta?", style: TextStyle(color: Colors.grey.shade600)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text(
              "Crear cuenta",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }
}