import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ==================== PALETA Y CONSTANTES ====================

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

// ==================== ADMIN SCREEN ====================

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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

// ==================== TAB 1: PRODUCTOS ====================

class _ProductosTab extends StatefulWidget {
  const _ProductosTab();

  @override
  State<_ProductosTab> createState() => _ProductosTabState();
}

class _ProductosTabState extends State<_ProductosTab> {
  String _busqueda = "";

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
            return nombre.contains(_busqueda.toLowerCase());
          }).toList();

          // Agrupar por categoría
          final Map<String, List<QueryDocumentSnapshot>> porCategoria = {};
          for (var doc in filtrados) {
            final data = doc.data() as Map<String, dynamic>;
            final categoria = (data['categoria'] ?? 'Sin categoría').toString();
            porCategoria.putIfAbsent(categoria, () => []).add(doc);
          }
          final categoriasOrdenadas = porCategoria.keys.toList()..sort();

          return Column(
            children: [
              _buildEncabezado(todos.length),
              _buildBuscador(),
              Expanded(
                child: filtrados.isEmpty
                    ? _buildVacio(todos.isEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: categoriasOrdenadas.length,
                        itemBuilder: (context, i) {
                          final categoria = categoriasOrdenadas[i];
                          final productos = porCategoria[categoria]!;
                          return _buildSeccionCategoria(categoria, productos);
                        },
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

  Widget _buildEncabezado(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        "$total producto${total == 1 ? '' : 's'} en el menú",
        style: const TextStyle(
          color: AppColors.textGrey,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _busqueda = v),
        decoration: InputDecoration(
          hintText: "Buscar producto...",
          prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
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
              sinProductosNunca
                  ? "Aún no hay productos"
                  : "No se encontraron productos",
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
                  : "Prueba con otro término de búsqueda.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionCategoria(
    String categoria,
    List<QueryDocumentSnapshot> productos,
  ) {
    final color = kColorCategoria[categoria] ?? AppColors.textGrey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                categoria,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "(${productos.length})",
                style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
        ),
        ...productos.map((doc) => _buildProductoCard(doc)),
      ],
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 56,
                height: 56,
                color: color.withOpacity(0.12),
                child: imagenUrl.isNotEmpty
                    ? Image.network(
                        imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.fastfood, color: color),
                      )
                    : Icon(Icons.fastfood, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['nombre'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textGrey),
              onPressed: () => _abrirFormulario(context, id: id, data: data),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _confirmarEliminar(context, id),
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
              await FirebaseFirestore.instance
                  .collection('productos')
                  .doc(id)
                  .delete();
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
    final precioCtrl =
        TextEditingController(text: data?['precio']?.toString() ?? '');
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
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                          decoration:
                              _inputDecoration("Precio").copyWith(prefixText: "\$ "),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
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
                    items: kCategorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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

                              final ref = FirebaseFirestore.instance
                                  .collection('productos');
                              if (id == null) {
                                await ref.add(producto);
                              } else {
                                await ref.doc(id).update(producto);
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                                _mostrarSnack(
                                  context,
                                  id == null
                                      ? "Producto agregado"
                                      : "Cambios guardados",
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
                          : Text(
                              id == null ? "Agregar producto" : "Guardar cambios",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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

// ==================== TAB 2: PEDIDOS (HISTORIAL) ====================

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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.textGrey.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text(
                  "Aún no hay pedidos registrados",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        final Map<String, List<QueryDocumentSnapshot>> pedidosPorDia = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final Timestamp? ts = data['fecha'];
          final fecha = ts != null ? ts.toDate() : DateTime.now();
          final claveDia = DateFormat('EEEE dd/MM/yyyy', 'es').format(fecha);
          pedidosPorDia.putIfAbsent(claveDia, () => []).add(doc);
        }
        final dias = pedidosPorDia.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: dias.length,
          itemBuilder: (context, i) {
            final dia = dias[i];
            final pedidosDelDia = pedidosPorDia[dia]!;
            final totalDia = pedidosDelDia.fold<double>(
              0,
              (sum, doc) =>
                  sum + ((doc.data() as Map)['total'] ?? 0).toDouble(),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    dia[0].toUpperCase() + dia.substring(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  subtitle: Text(
                    "${pedidosDelDia.length} pedido(s) • \$${totalDia.toStringAsFixed(2)}",
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: pedidosDelDia
                      .map((doc) => _buildPedidoTile(doc))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPedidoTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final cliente = data['correoCliente'] ?? 'Cliente';
    final total = (data['total'] ?? 0).toDouble();
    final estado = data['estado'] ?? 'pendiente';
    final List productos = data['productos'] ?? [];
    final Timestamp? ts = data['fecha'];
    final hora = ts != null ? DateFormat('hh:mm a').format(ts.toDate()) : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _colorEstado(estado),
          radius: 18,
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
        title: Text(cliente,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text("$hora • \$${total.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        children: [
          ...productos.map((p) => ListTile(
                dense: true,
                title: Text("${p['cantidad']}x ${p['nombre']}",
                    style: const TextStyle(fontSize: 13)),
                trailing: Text("\$${p['precio']}",
                    style: const TextStyle(fontSize: 13)),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Estado: ", style: TextStyle(fontSize: 12)),
                DropdownButton<String>(
                  value: estado,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(
                        value: 'preparacion', child: Text('En preparación')),
                    DropdownMenuItem(value: 'listo', child: Text('Listo')),
                    DropdownMenuItem(value: 'entregado', child: Text('Entregado')),
                  ],
                  onChanged: (nuevoEstado) {
                    if (nuevoEstado == null) return;
                    FirebaseFirestore.instance
                        .collection('pedidos')
                        .doc(doc.id)
                        .update({'estado': nuevoEstado});
                  },
                ),
              ],
            ),
          ),
        ],
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