import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<String> loginGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleUser =
        await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Inicio cancelado");
    }


    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;


    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );


    UserCredential resultado =
        await _auth.signInWithCredential(credential);


    User usuario = resultado.user!;


    DocumentReference ref =
        _db.collection("usuarios").doc(usuario.uid);


    DocumentSnapshot datos = await ref.get();


    if (!datos.exists) {

      await ref.set({

        "nombre": usuario.displayName ?? "",

        "email": usuario.email,

        "rol": "cliente",

      });


      return "cliente";
    }


    Map<String,dynamic> usuarioData =
        datos.data() as Map<String,dynamic>;


    return usuarioData["rol"];

  }

}