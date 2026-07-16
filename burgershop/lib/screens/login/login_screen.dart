import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:burgershop/services/auth_service.dart';
import 'package:burgershop/screens/admin/admin_screen.dart';
import 'package:burgershop/screens/home/home_screen.dart';
import 'package:burgershop/screens/register/register_screen.dart';
import 'package:burgershop/screens/admin/admin_screen.dart';


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






  Future<void> iniciarSesion() async {


    setState(() {

      _cargando = true;

    });




    try {



      // Iniciar sesión con Firebase Authentication

      UserCredential credencial =

      await FirebaseAuth.instance.signInWithEmailAndPassword(

        email: emailController.text.trim(),

        password: passwordController.text.trim(),

      );





      User? usuario = credencial.user;



      if(usuario == null){

        return;

      }






      // Obtener información del usuario desde Firestore

      DocumentSnapshot datosUsuario =

      await FirebaseFirestore.instance

          .collection("usuarios")

          .doc(usuario.uid)

          .get();





      if(!datosUsuario.exists){


        throw Exception(

          "No existe información del usuario"

        );


      }





      // Obtener rol del usuario

      String rol = datosUsuario["rol"];






      if(!mounted) return;







      // Redirección según el rol


      if(rol == "administrador"){



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context)=> const AdminScreen(),

          ),

        );



      }



      else if(rol == "cliente"){



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context)=> const HomeScreen(),

          ),

        );



      }



      else {



        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text(

              "Rol de usuario inválido"

            ),

          ),

        );

      }






    }





    on FirebaseAuthException catch(e){



      String mensaje;





      switch(e.code){



        case "user-not-found":

          mensaje="No existe un usuario con este correo";

          break;




        case "wrong-password":

          mensaje="La contraseña es incorrecta";

          break;




        case "invalid-email":

          mensaje="Correo inválido";

          break;




        case "invalid-credential":

          mensaje="Correo o contraseña incorrectos";

          break;




        default:

          mensaje=e.message ?? "Error desconocido";


      }







      if(!mounted) return;



      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(mensaje),

        ),

      );



    }




    catch(e){



      if(!mounted) return;



      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            e.toString()

          ),

        ),

      );


    }





    finally{


      if(mounted){


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
          MaterialPageRoute(
            builder: (_) => const AdminScreen(),
          ),
        );


      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );

      }


    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    }

  }



  @override
  Widget build(BuildContext context) {



    return Scaffold(


      backgroundColor: const Color(0xFFFFE9D9),



      body: SafeArea(


        child: SingleChildScrollView(


          child: Column(


            children: [





              SizedBox(


                height: 280,


                width: double.infinity,



                child: Stack(


                  fit: StackFit.expand,



                  children: [



                    Image.asset(

                      "assets/imagenes/logo.png",

                      fit: BoxFit.cover,

                    ),




                    Container(

                      decoration: const BoxDecoration(

                        gradient: LinearGradient(

                          begin: Alignment.topCenter,

                          end: Alignment.bottomCenter,

                          colors: [

                            Colors.transparent,

                            Colors.black45,

                          ],

                        ),

                      ),

                    ),





                    const Positioned(

                      bottom:25,

                      left:0,

                      right:0,


                      child:Text(

                        "BurgerRush",

                        textAlign:TextAlign.center,

                        style:TextStyle(

                          color:Colors.white,

                          fontSize:30,

                          fontWeight:FontWeight.bold,

                        ),

                      ),

                    )



                  ],

                ),

              ),






              Container(


                padding:const EdgeInsets.all(28),


                decoration:const BoxDecoration(


                  color:Color(0xFFFFE9D9),


                  borderRadius:BorderRadius.vertical(

                    top:Radius.circular(30),

                  ),

                ),




                child:Column(


                  crossAxisAlignment:CrossAxisAlignment.start,



                  children:[





                    const Text(

                      "¡Bienvenido de nuevo!",


                      style:TextStyle(

                        fontSize:24,

                        fontWeight:FontWeight.bold,

                      ),

                    ),




                    const SizedBox(height:30),






                    TextField(


                      controller:emailController,


                      keyboardType:TextInputType.emailAddress,



                      decoration:InputDecoration(


                        labelText:"Correo electrónico",


                        prefixIcon:

                        const Icon(Icons.email_outlined),



                        filled:true,


                        fillColor:Colors.white,



                        border:OutlineInputBorder(

                          borderRadius:BorderRadius.circular(14),

                          borderSide:BorderSide.none,

                        ),

                      ),

                    ),






                    const SizedBox(height:18),






                    TextField(


                      controller:passwordController,


                      obscureText:_ocultarPassword,



                      decoration:InputDecoration(


                        labelText:"Contraseña",


                        prefixIcon:

                        const Icon(Icons.lock_outline),




                        suffixIcon:IconButton(


                          icon:Icon(

                            _ocultarPassword

                            ? Icons.visibility_off

                            : Icons.visibility,

                          ),



                          onPressed:(){


                            setState((){


                              _ocultarPassword=

                              !_ocultarPassword;


                            });


                          },

                        ),





                        filled:true,


                        fillColor:Colors.white,



                        border:OutlineInputBorder(


                          borderRadius:

                          BorderRadius.circular(14),


                          borderSide:BorderSide.none,


                        ),

                      ),

                    ),







                    const SizedBox(height:25),





                    SizedBox(


                      width:double.infinity,


                      height:52,



                      child:ElevatedButton(


                        onPressed:

                        _cargando

                        ? null

                        : iniciarSesion,



                        style:ElevatedButton.styleFrom(


                          backgroundColor:

                          Colors.deepOrange,



                          shape:

                          RoundedRectangleBorder(


                            borderRadius:

                            BorderRadius.circular(14),


                          ),


                        ),




                        child:_cargando


                        ? const CircularProgressIndicator(

                          color:Colors.white,

                        )



                        :const Text(

                          "Iniciar sesión",


                          style:TextStyle(

                            color:Colors.white,

                            fontSize:17,

                            fontWeight:

                            FontWeight.bold,

                          ),

                        ),

                      ),

                    ),






                    const SizedBox(height:20),



                    const SizedBox(height:20),


                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: OutlinedButton.icon(

                        onPressed: iniciarGoogle,

                        icon: const Icon(
                          Icons.login,
                        ),

                        label: const Text(
                          "Continuar con Google",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(

                          foregroundColor: Colors.black87,

                          side: const BorderSide(
                            color: Colors.orange,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),

                        ),

                      ),

                    ),


                    const SizedBox(height:20),





                    Center(


                      child:Row(


                        mainAxisAlignment:

                        MainAxisAlignment.center,



                        children:[



                          const Text(

                            "¿No tienes cuenta?",

                          ),




                          TextButton(


                            onPressed:(){


                              Navigator.push(


                                context,


                                MaterialPageRoute(


                                  builder:(context)=>

                                  const RegisterScreen(),


                                ),

                              );


                            },


                            child:const Text(

                              "Crear cuenta",

                              style:TextStyle(

                                fontWeight:

                                FontWeight.bold,

                                color:

                                Colors.deepOrange,

                              ),

                            ),

                          )


                        ],

                      ),

                    )





                  ],


                ),


              )



            ],


          ),

        ),

      ),

    );


  }


}