import 'package:flutter/material.dart';
import 'package:burgershop/screens/register/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Text(
                "🍔",
                style: TextStyle(fontSize: 80),
              ),

              const SizedBox(height: 15),

              const Text(
                "BurgerShop",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "¡Bienvenido de nuevo!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

            const SizedBox(height: 40),

            TextField(
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {

                },
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {

                },
                icon: const Icon(Icons.login),
                label: const Text(
                  "Continuar con Google",
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "¿No tienes cuenta?",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

  ],
),            
            ],
          ),
        ),
      ),
    );
  }
}