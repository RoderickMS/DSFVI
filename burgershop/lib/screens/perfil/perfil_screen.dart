import 'package:burgershop/screens/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Pantalla de Perfil. Se llega aquí desde Home (ícono de perfil o tarjeta).
// Carga los datos reales del usuario autenticado: primero desde
// FirebaseAuth (correo, nombre si lo tiene) y luego completa/actualiza con
// el documento del usuario guardado en Firestore, colección "usuarios".
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _cargando = true;
  Map<String, String> _usuario = {
    "nombre": "",
    "email": "",
    "telefono": "",
  };

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No hay sesión iniciada; deja los campos vacíos y detiene la carga.
      setState(() => _cargando = false);
      return;
    }

    // Datos base que siempre vienen de FirebaseAuth.
    String nombre = user.displayName ?? "";
    String email = user.email ?? "";
    String telefono = user.phoneNumber ?? "";

    try {
      // Se completa/actualiza con el documento del usuario en Firestore,
      // por si ahí se guardó el nombre o teléfono al registrarse.
      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nombre = (data["nombre"] as String?)?.trim().isNotEmpty == true
            ? data["nombre"]
            : nombre;
        telefono = (data["telefono"] as String?)?.trim().isNotEmpty == true
            ? data["telefono"]
            : telefono;
      }
    } catch (_) {
      // Si falla la consulta a Firestore, seguimos con lo que ya tenemos
      // de FirebaseAuth en vez de romper la pantalla.
    }

    if (!mounted) return;
    setState(() {
      _usuario = {
        "nombre": nombre.isNotEmpty ? nombre : "Usuario",
        "email": email.isNotEmpty ? email : "Sin correo registrado",
        "telefono": telefono.isNotEmpty ? telefono : "No registrado",
      };
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: "Volver",
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            }
            // Si no hay a dónde regresar (se abrió como pantalla raíz),
            // simplemente no hacemos nada; evita depender de rutas
            // nombradas que tu app aún no tiene configuradas.
          },
        ),
        title: const Text(
          "Mi perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEncabezado(),
                    const SizedBox(height: 30),
                    const Text(
                      "Información de la cuenta",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(),
                    const SizedBox(height: 25),
                    const Text(
                      "Opciones",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOpciones(context),
                    const SizedBox(height: 25),
                    _buildBotonCerrarSesion(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEncabezado() {
    final inicial = _usuario["nombre"]!.isNotEmpty
        ? _usuario["nombre"]!.substring(0, 1).toUpperCase()
        : "?";

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _usuario["nombre"]!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _usuario["email"]!,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildInfoTile(
              icono: Icons.person_outline,
              titulo: "Nombre",
              valor: _usuario["nombre"]!,
            ),
            const Divider(height: 1),
            _buildInfoTile(
              icono: Icons.email_outlined,
              titulo: "Correo",
              valor: _usuario["email"]!,
            ),
            const Divider(height: 1),
            _buildInfoTile(
              icono: Icons.phone_outlined,
              titulo: "Teléfono",
              valor: _usuario["telefono"]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return ListTile(
      leading: Icon(icono, color: Colors.orange),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOpciones(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildOpcionTile(
              icono: Icons.edit_outlined,
              titulo: "Editar perfil",
              onTap: () {
                // TODO: navegar a pantalla de edición de perfil
              },
            ),
            const Divider(height: 1),
            _buildOpcionTile(
              icono: Icons.location_on_outlined,
              titulo: "Mis direcciones",
              onTap: () {
                // TODO: navegar a pantalla de direcciones guardadas
              },
            ),
            const Divider(height: 1),
            _buildOpcionTile(
              icono: Icons.receipt_long_outlined,
              titulo: "Mis pedidos",
              onTap: () {
                // TODO: navegar a HistorialScreen
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionTile({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icono, color: Colors.black54),
      title: Text(titulo, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cerrar sesión"),
        content: const Text("¿Seguro que quieres cerrar tu sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      // Limpia todo el historial de navegación para que el usuario no
      // pueda "regresar" a pantallas protegidas con el botón atrás.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo cerrar sesión: $e")),
      );
    }
  }

  Widget _buildBotonCerrarSesion(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _confirmarCerrarSesion(context),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          "Cerrar sesión",
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}