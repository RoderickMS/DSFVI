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


  Future<void> registrarUsuario() async {

    try {

      // Crear usuario en Firebase Authentication
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
            "fechaRegistro": Timestamp.now(),

          });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario creado correctamente"),
        ),
      );


      Navigator.pop(context);


    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );

    }

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.orange.shade50,

      appBar: AppBar(
        title: const Text("Crear cuenta"),
        backgroundColor: Colors.orange,
      ),


      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [


            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),


            const SizedBox(height: 15),


            TextField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: "Correo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),


            const SizedBox(height: 15),


            TextField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: "Teléfono",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),


            const SizedBox(height: 15),


            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
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
                ),


                onPressed: registrarUsuario,


                child: const Text(
                  "Registrarse",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

              ),
            )

          ],
        ),

      ),

    );

  }

}