import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final telefonoController = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;

  // En vez de un solo formulario largo, dividimos el registro en 2 pasos.
  int _pasoActual = 0;
  static const int _totalPasos = 2;

  Future<void> registrarUsuario() async {
    setState(() => _cargando = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Guardar información adicional en Firestore
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .set({
        "nombre": nombreController.text.trim(),
        "correo": correoController.text.trim(),
        "telefono": telefonoController.text.trim(),
        "rol": "cliente",
        "fechaRegistro": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado correctamente")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  // Al presionar "atrás": si estás en el paso 2, regresa al paso 1 en vez de
  // salir de la pantalla. Solo en el paso 1 realmente sale del registro.
  void _irAtras() {
    if (_pasoActual > 0) {
      setState(() => _pasoActual--);
    } else {
      Navigator.pop(context);
    }
  }

  void _irSiguiente() {
    if (nombreController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa tu nombre y teléfono para continuar")),
      );
      return;
    }
    setState(() => _pasoActual = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildBarraSuperior(),
            _buildIndicadorPasos(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnim = Tween<Offset>(
                      begin: const Offset(0.15, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return SlideTransition(
                      position: offsetAnim,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _pasoActual == 0
                      ? _buildPasoUno(key: const ValueKey("paso1"))
                      : _buildPasoDos(key: const ValueKey("paso2")),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBarraSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: _irAtras,
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const Spacer(),
          Text(
            "Paso ${_pasoActual + 1} de $_totalPasos",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicadorPasos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: List.generate(_totalPasos, (index) {
          final completado = index <= _pasoActual;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: index == _totalPasos - 1 ? 0 : 8),
              decoration: BoxDecoration(
                color: completado ? Colors.deepOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  //datos personales

  Widget _buildPasoUno({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("👋", style: TextStyle(fontSize: 46)),
        const SizedBox(height: 16),
        const Text(
          "Cuéntanos de ti",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Solo necesitamos un par de datos para empezar.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildCampoSubrayado(
          controller: nombreController,
          label: "Nombre completo",
          icono: Icons.person_outline,
        ),
        const SizedBox(height: 22),
        _buildCampoSubrayado(
          controller: telefonoController,
          label: "Teléfono",
          icono: Icons.phone_outlined,
          teclado: TextInputType.phone,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _irSiguiente,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Continuar",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //datos de acceso

  Widget _buildPasoDos({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("🔐", style: TextStyle(fontSize: 46)),
        const SizedBox(height: 16),
        const Text(
          "Crea tu acceso",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Con esto vas a iniciar sesión la próxima vez.",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildCampoSubrayado(
          controller: correoController,
          label: "Correo electrónico",
          icono: Icons.email_outlined,
          teclado: TextInputType.emailAddress,
        ),
        const SizedBox(height: 22),
        _buildCampoPasswordSubrayado(),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _cargando ? null : registrarUsuario,
            child: _cargando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    "Crear cuenta",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              "¿Ya tienes cuenta? Inicia sesión",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }


  Widget _buildCampoSubrayado({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: Colors.deepOrange),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }

  Widget _buildCampoPasswordSubrayado() {
    return TextField(
      controller: passwordController,
      obscureText: _ocultarPassword,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepOrange),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() => _ocultarPassword = !_ocultarPassword);
          },
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange, width: 2),
        ),
      ),
    );
  }
}