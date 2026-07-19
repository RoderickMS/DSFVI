import 'package:burgershop/screens/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

// ==================== PALETA (misma que Admin) ====================

class _AppColors {
  static const primary = Color(0xFFE8590C);
  static const primaryLight = Color(0xFFFFF0E6);
  static const background = Color(0xFFF6F6F6);
  static const textDark = Color(0xFF2D2D2D);
  static const textGrey = Color(0xFF8A8A8A);
  static const success = Color(0xFF2E7D32);
  static const danger = Color(0xFFD32F2F);
}

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
      backgroundColor: _AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: _AppColors.primaryLight,
        elevation: 0,
        foregroundColor: _AppColors.primary,
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
            ? const Center(
                child: CircularProgressIndicator(color: _AppColors.primary),
              )
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
                        color: _AppColors.textDark,
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
                        color: _AppColors.textDark,
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
            backgroundColor: _AppColors.primaryLight,
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: _AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _usuario["nombre"]!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _usuario["email"]!,
            style: const TextStyle(fontSize: 14, color: _AppColors.textGrey),
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
      leading: Icon(icono, color: _AppColors.primary),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 13, color: _AppColors.textGrey),
      ),
      subtitle: Text(
        valor,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _AppColors.textDark,
        ),
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
              onTap: () => _abrirEditarPerfil(context),
            ),
            const Divider(height: 1),
            _buildOpcionTile(
              icono: Icons.receipt_long_outlined,
              titulo: "Mis pedidos",
              onTap: () => _abrirMisPedidos(context),
            ),
            const Divider(height: 1),
            _buildOpcionTile(
              icono: Icons.help_outline,
              titulo: "Ayuda",
              onTap: () => _abrirAyuda(context),
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
      leading: Icon(icono, color: _AppColors.textDark),
      title: Text(
        titulo,
        style: const TextStyle(fontSize: 15, color: _AppColors.textDark),
      ),
      trailing: const Icon(Icons.chevron_right, color: _AppColors.textGrey),
      onTap: onTap,
    );
  }

  // -----------------------------------------------------------------
  // Editar perfil: modal con los campos nombre y teléfono. Guarda en
  // Firestore (colección "usuarios") y actualiza el displayName en
  // FirebaseAuth. Al cerrar, recarga los datos mostrados en pantalla.
  // -----------------------------------------------------------------
  void _abrirEditarPerfil(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nombreCtrl = TextEditingController(text: _usuario["nombre"]);
    final telefonoCtrl = TextEditingController(
      text: _usuario["telefono"] == "No registrado" ? "" : _usuario["telefono"],
    );
    bool guardando = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    "Editar perfil",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: _inputDecoration("Nombre"),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: telefonoCtrl,
                    decoration: _inputDecoration("Teléfono"),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: guardando
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => guardando = true);

                              final nuevoNombre = nombreCtrl.text.trim();
                              final nuevoTelefono = telefonoCtrl.text.trim();

                              try {
                                await FirebaseFirestore.instance
                                    .collection("usuarios")
                                    .doc(user.uid)
                                    .set({
                                  "nombre": nuevoNombre,
                                  "telefono": nuevoTelefono,
                                }, SetOptions(merge: true));

                                await user.updateDisplayName(nuevoNombre);
                              } catch (e) {
                                setModalState(() => guardando = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("No se pudo guardar: $e"),
                                      backgroundColor: _AppColors.danger,
                                    ),
                                  );
                                }
                                return;
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              await _cargarDatosUsuario();
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Perfil actualizado"),
                                    backgroundColor: _AppColors.success,
                                  ),
                                );
                              }
                            },
                      child: guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Guardar cambios",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _AppColors.primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // -----------------------------------------------------------------
  // Mis pedidos: modal con la lista de pedidos reales del usuario,
  // consultados en Firestore ("pedidos" filtrado por su correo).
  // -----------------------------------------------------------------
  void _abrirMisPedidos(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mis pedidos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: email == null
                    ? const Center(
                        child: Text(
                          "No se pudo identificar tu cuenta.",
                          style: TextStyle(color: _AppColors.textGrey),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('pedidos')
                            .where('correoCliente', isEqualTo: email)
                            .orderBy('fecha', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: _AppColors.primary,
                              ),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 56,
                                    color: _AppColors.textGrey.withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Aún no tienes pedidos",
                                    style: TextStyle(color: _AppColors.textGrey),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: docs.length,
                            itemBuilder: (context, i) =>
                                _buildPedidoCard(docs[i]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPedidoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final total = (data['total'] ?? 0).toDouble();
    final estado = (data['estado'] ?? 'pendiente').toString();
    final List productos = data['productos'] ?? [];
    final Timestamp? ts = data['fecha'];
    final fechaTexto =
        ts != null ? DateFormat('dd/MM/yyyy • hh:mm a').format(ts.toDate()) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fechaTexto,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorEstado(estado).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _textoEstado(estado),
                  style: TextStyle(
                    color: _colorEstado(estado),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...productos.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${p['cantidad']}x ${p['nombre']}",
                      style: const TextStyle(fontSize: 13.5, color: _AppColors.textDark),
                    ),
                  ),
                  Text(
                    "\$${p['precio']}",
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // Ayuda: modal con indicaciones básicas de cómo usar la app,
  // organizadas como preguntas expandibles (FAQ).
  // -----------------------------------------------------------------
  void _abrirAyuda(BuildContext context) {
    final secciones = [
      {
        "icono": Icons.restaurant_menu,
        "titulo": "¿Cómo veo el menú?",
        "texto":
            "Desde la pantalla principal toca \"Ver menú\". Ahí puedes buscar "
            "por nombre o filtrar por categoría (Hamburguesas, Bebidas, "
            "Postres) tocando los chips en la parte superior.",
      },
      {
        "icono": Icons.add_shopping_cart_outlined,
        "titulo": "¿Cómo agrego productos al carrito?",
        "texto":
            "Toca el botón \"+\" naranja dentro de la tarjeta del producto "
            "que quieras. Puedes seguir agregando distintos productos antes "
            "de pagar; todos se guardan en tu carrito.",
      },
      {
        "icono": Icons.payment_outlined,
        "titulo": "¿Cómo realizo mi pedido?",
        "texto":
            "Abre el carrito con el ícono de la parte superior del menú, "
            "revisa tus productos y toca \"Pagar\" para completar tu pedido.",
      },
      {
        "icono": Icons.local_shipping_outlined,
        "titulo": "¿Cómo sé en qué va mi pedido?",
        "texto":
            "En \"Mi perfil\" > \"Mis pedidos\" puedes ver el estado de cada "
            "uno: Pendiente, Preparando, Listo o Entregado. Se actualiza en "
            "tiempo real conforme el restaurante lo va preparando.",
      },
      {
        "icono": Icons.person_outline,
        "titulo": "¿Cómo edito mis datos?",
        "texto":
            "En \"Mi perfil\" > \"Editar perfil\" puedes actualizar tu "
            "nombre y teléfono. Tu correo no se puede cambiar porque es el "
            "que usas para iniciar sesión.",
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ayuda",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Guía rápida para usar BurgerShop",
                  style: TextStyle(fontSize: 13, color: _AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: secciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = secciones[i];
                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ExpansionTile(
                          leading: Icon(
                            s["icono"] as IconData,
                            color: _AppColors.primary,
                          ),
                          title: Text(
                            s["titulo"] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _AppColors.textDark,
                            ),
                          ),
                          childrenPadding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          expandedCrossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              s["texto"] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _AppColors.textGrey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'preparacion':
        return _AppColors.primary;
      case 'listo':
        return Colors.blue;
      case 'entregado':
        return _AppColors.success;
      default:
        return _AppColors.textGrey;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'preparacion':
        return 'PREPARANDO';
      case 'listo':
        return 'LISTO';
      case 'entregado':
        return 'ENTREGADO';
      default:
        return 'PENDIENTE';
    }
  }

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: TextStyle(color: _AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        icon: const Icon(Icons.logout, color: _AppColors.danger),
        label: const Text(
          "Cerrar sesión",
          style: TextStyle(color: _AppColors.danger, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _AppColors.danger),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}