import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../login/login_screen.dart';


class AppColors {
  static const primary = Color(0xFFE8590C);
  static const primaryLight = Color(0xFFFFF0E6);
  static const background = Color(0xFFF6F6F6);
  static const textDark = Color(0xFF2D2D2D);
  static const textGrey = Color(0xFF8A8A8A);
  static const success = Color(0xFF2E7D32);
  static const danger = Color(0xFFD32F2F);
}

const List<String> kCategorias = [
  "Hamburguesas",
  "Bebidas",
  "Postres",
  "Acompañamientos",
];

const Map<String, Color> kColorCategoria = {
  "Hamburguesas": Color(0xFFE8590C),
  "Bebidas": Color(0xFF1976D2),
  "Postres": Color(0xFFAD1457),
  "Acompañamientos": Color(0xFF2E7D32),
};


class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // Cerrar sesión: confirma, cierra sesión y redirige al login
  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cerrar sesión"),
        content: const Text("¿Seguro que deseas cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            "BURGUERSHOP",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          actions: [
            IconButton(
              tooltip: "Cerrar sesión",
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _cerrarSesion(context),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(icon: Icon(Icons.fastfood_outlined), text: "Productos"),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: "Pedidos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProductosTab(),
            _PedidosTab(),
          ],
        ),
      ),
    );
  }
}


class _ProductosTab extends StatefulWidget {
  const _ProductosTab();

  @override
  State<_ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends State<_ProductosTab> {
  String _busqueda = "";
  String? _categoriaFiltro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .orderBy('nombre')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final todos = snapshot.data!.docs;

          final filtrados = todos.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final nombre = (data['nombre'] ?? '').toString().toLowerCase();
            final categoria = (data['categoria'] ?? '').toString();
            final coincideNombre = nombre.contains(_busqueda.toLowerCase());
            final coincideCategoria =
                _categoriaFiltro == null || categoria == _categoriaFiltro;
            return coincideNombre && coincideCategoria;
          }).toList();

          return Column(
            children: [
              _buildBuscador(),
              _buildFiltroCategorias(),
              const SizedBox(height: 4),
              Expanded(
                child: filtrados.isEmpty
                    ? _buildVacio(todos.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: filtrados.length,
                        itemBuilder: (context, i) => _buildProductoCard(filtrados[i]),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text("Agregar producto"),
        onPressed: () => _abrirFormulario(context),
      ),
    );
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _busqueda = v),
        decoration: InputDecoration(
          hintText: "Buscar producto...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textGrey, size: 18),
                  onPressed: () => setState(() => _busqueda = ""),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  //categoría
  Widget _buildFiltroCategorias() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chipCategoria("Todas", null, AppColors.textDark),
          ...kCategorias.map(
            (c) => _chipCategoria(c, c, kColorCategoria[c] ?? AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria(String label, String? valor, Color color) {
    final seleccionado = _categoriaFiltro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: seleccionado,
        onSelected: (_) => setState(() => _categoriaFiltro = valor),
        selectedColor: color.withOpacity(0.15),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: seleccionado ? color : AppColors.textGrey,
          fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
          fontSize: 12.5,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: seleccionado ? color : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildVacio(bool sinProductosNunca) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sinProductosNunca ? Icons.fastfood_outlined : Icons.search_off,
              size: 64,
              color: AppColors.textGrey.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              sinProductosNunca ? "Aún no hay productos" : "No se encontraron productos",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              sinProductosNunca
                  ? "Toca \"Agregar producto\" para crear el primero."
                  : "Prueba con otro término o categoría.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final disponible = data['disponible'] ?? true;
    final imagenUrl = (data['imagenUrl'] ?? '').toString();
    final categoria = (data['categoria'] ?? '').toString();
    final color = kColorCategoria[categoria] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 64,
                height: 64,
                color: color.withOpacity(0.12),
                child: imagenUrl.isNotEmpty
                    ? Image.network(
                        imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.fastfood, color: color),
                      )
                    : Icon(Icons.fastfood, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['nombre'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Switch(
                        activeColor: AppColors.primary,
                        value: disponible,
                        onChanged: (v) {
                          FirebaseFirestore.instance
                              .collection('productos')
                              .doc(id)
                              .update({'disponible': v});
                          _mostrarSnack(
                            context,
                            v ? "Producto marcado disponible" : "Producto marcado agotado",
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.textGrey),
                        onSelected: (opcion) {
                          if (opcion == 'editar') {
                            _abrirFormulario(context, id: id, data: data);
                          } else if (opcion == 'eliminar') {
                            _confirmarEliminar(context, id);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'editar',
                            child: Row(children: [
                              Icon(Icons.edit_outlined, size: 18, color: AppColors.textGrey),
                              SizedBox(width: 8),
                              Text("Editar"),
                            ]),
                          ),
                          PopupMenuItem(
                            value: 'eliminar',
                            child: Row(children: [
                              Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                              SizedBox(width: 8),
                              Text("Eliminar", style: TextStyle(color: AppColors.danger)),
                            ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoria.isEmpty ? "Sin categoría" : categoria,
                          style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "\$${(data['precio'] ?? 0).toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (!disponible) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "AGOTADO",
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSnack(BuildContext context, String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Eliminar producto"),
        content: const Text("¿Seguro que deseas eliminar este producto? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('productos').doc(id).delete();
              if (context.mounted) {
                Navigator.pop(context);
                _mostrarSnack(context, "Producto eliminado");
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) {
    final nombreCtrl = TextEditingController(text: data?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: data?['descripcion'] ?? '');
    final precioCtrl = TextEditingController(text: data?['precio']?.toString() ?? '');
    final imagenCtrl = TextEditingController(text: data?['imagenUrl'] ?? '');
    String categoriaSeleccionada = data?['categoria'] ?? kCategorias.first;
    bool disponible = data?['disponible'] ?? true;
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
                  Text(
                    id == null ? "Nuevo producto" : "Editar producto",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: _inputDecoration("Nombre"),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Requerido" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: _inputDecoration("Descripción"),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: precioCtrl,
                          decoration: _inputDecoration("Precio").copyWith(prefixText: "\$ "),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return "Requerido";
                            if (double.tryParse(v) == null) return "Inválido";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: _inputDecoration("Categoría"),
                    items: kCategorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() => categoriaSeleccionada = v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imagenCtrl,
                    decoration: _inputDecoration("URL de imagen (opcional)"),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    value: disponible,
                    onChanged: (v) => setModalState(() => disponible = v),
                    title: const Text("Disponible en el menú"),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: guardando
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              setModalState(() => guardando = true);

                              final producto = {
                                'nombre': nombreCtrl.text.trim(),
                                'descripcion': descCtrl.text.trim(),
                                'precio': double.parse(precioCtrl.text),
                                'categoria': categoriaSeleccionada,
                                'imagenUrl': imagenCtrl.text.trim(),
                                'disponible': disponible,
                              };

                              final ref = FirebaseFirestore.instance.collection('productos');
                              if (id == null) {
                                await ref.add(producto);
                              } else {
                                await ref.doc(id).update(producto);
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                                _mostrarSnack(
                                  context,
                                  id == null ? "Producto agregado" : "Cambios guardados",
                                );
                              }
                            },
                      child: guardando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              id == null ? "Agregar producto" : "Guardar cambios",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

//historial de pedidos

class _PedidosTab extends StatelessWidget {
  const _PedidosTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pedidos')
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textGrey.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text(
                  "Aún no hay pedidos registrados",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: docs.length,
          itemBuilder: (context, i) => _buildPedidoCard(context, docs[i]),
        );
      },
    );
  }

  // Tarjeta de pedido individual
  Widget _buildPedidoCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final cliente = (data['correoCliente'] ?? 'Cliente').toString();
    final total = (data['total'] ?? 0).toDouble();
    final estado = data['estado'] ?? 'pendiente';
    final Timestamp? ts = data['fecha'];
    final hora = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '';
    final inicial = cliente.isNotEmpty ? cliente[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => _abrirDetallePedido(context, doc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _colorEstado(estado),
              radius: 18,
              child: Text(inicial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text("$hora • \$${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _colorEstado(estado).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _textoEstado(estado),
                style: TextStyle(color: _colorEstado(estado), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textGrey, size: 20),
          ],
        ),
      ),
    );
  }

  // Detalle del pedido
  void _abrirDetallePedido(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final cliente = (data['correoCliente'] ?? 'Cliente').toString();
    final total = (data['total'] ?? 0).toDouble();
    final List productos = data['productos'] ?? [];
    final Timestamp? ts = data['fecha'];
    final hora = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '';
    String estadoActual = data['estado'] ?? 'pendiente';

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _colorEstado(estadoActual),
                    radius: 20,
                    child: Text(
                      cliente.isNotEmpty ? cliente[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(hora, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text("Productos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Divider(),
              ...productos.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text("${p['cantidad']}x ${p['nombre']}", style: const TextStyle(fontSize: 13.5))),
                        Text("\$${p['precio']}", style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("\$${total.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 18),
              const Text("Actualizar estado", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: estadoActual,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'preparacion', child: Text('En preparación')),
                    DropdownMenuItem(value: 'listo', child: Text('Listo')),
                    DropdownMenuItem(value: 'entregado', child: Text('Entregado')),
                  ],
                  onChanged: (nuevoEstado) {
                    if (nuevoEstado == null) return;
                    setModalState(() => estadoActual = nuevoEstado);
                    FirebaseFirestore.instance
                        .collection('pedidos')
                        .doc(doc.id)
                        .update({'estado': nuevoEstado,
                        'estadoPago': 'pagado'});
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
        return Colors.orange;
      case 'listo':
        return Colors.blue;
      case 'entregado':
        return AppColors.success;
      default:
        return AppColors.textGrey;
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
}