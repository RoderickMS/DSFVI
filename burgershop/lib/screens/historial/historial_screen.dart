import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final usuario = FirebaseAuth.instance.currentUser;


    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text("Usuario no autenticado"),
        ),
      );
    }


    return Scaffold(

      backgroundColor: const Color(0xFFFFF8F2),

      appBar: AppBar(
        title: const Text("Historial de pedidos"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),


      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("pedidos")
            .where(
              "usuarioId",
              isEqualTo: usuario.uid,
            )
            .snapshots(),


        builder: (context, snapshot) {


          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){

            return const Center(
              child: Text(
                "No tienes pedidos todavía 🍔",
                style: TextStyle(
                  fontSize:18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );

          }



          final pedidos = snapshot.data!.docs;



          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: pedidos.length,


            itemBuilder: (context,index){


              final pedido = pedidos[index];


              return Card(

                child: ListTile(

                  leading: const Icon(
                    Icons.receipt_long,
                    color: Colors.teal,
                  ),


                  title: Text(
                    "Pedido #${pedido.id.substring(0,6)}",
                  ),


                  subtitle: Text(
                    "Total: \$${pedido['total']}",
                  ),


                  trailing: Text(
                    pedido['estado'] ?? "Pendiente",
                  ),

                ),

              );


            },

          );

        },

      ),

    );

  }

}