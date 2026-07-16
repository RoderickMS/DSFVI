import 'package:flutter/material.dart';

// Pantalla de Perfil. Se llega aquí desde Home (ícono de perfil o tarjeta).
// TODO: reemplazar los datos de _usuario por los reales de Firebase Auth
// y del documento del usuario en Firestore (/usuarios).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Datos de ejemplo — misma forma que tu colección /usuarios
  final Map<String, String> _usuario = const {
    "nombre": "Kevin Rodríguez",
    "email": "kevin@email.com",
    "telefono": "+507 6000-0000",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Mi perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.orange.shade100,
            child: Text(
              _usuario["nombre"]!.substring(0, 1).toUpperCase(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildBotonCerrarSesion(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: cerrar sesión con FirebaseAuth.instance.signOut()
          // y navegar de vuelta a LoginScreen, limpiando el stack:
          // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
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