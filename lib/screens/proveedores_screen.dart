import 'package:flutter/material.dart';
import '../controllers/proveedores_controller.dart';
import '../theme/app_theme.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final ProveedoresController _controller = ProveedoresController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? supplier}) async {
    final isEdit = supplier != null;
    final formKey = GlobalKey<FormState>();

    final nombre = TextEditingController(text: supplier?['nombre'] ?? '');
    final direccion = TextEditingController(text: supplier?['direccion'] ?? '');
    final telefono = TextEditingController(text: supplier?['telefono'] ?? '');
    final email = TextEditingController(text: supplier?['email'] ?? '');

    showDialog(
      context: context,
      builder: (diaCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardTheme.color,
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEdit ? 'Editar Proveedor' : 'Nuevo Proveedor',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                      IconButton(icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color), onPressed: () => Navigator.pop(diaCtx)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildField('Nombre de la Empresa *', nombre, Icons.business, req: true),
                  _buildField('Dirección', direccion, Icons.location_on),
                  _buildField('Teléfono', telefono, Icons.phone, keyboard: TextInputType.phone),
                  _buildField('Email', email, Icons.email, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(diaCtx), child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ayanamiBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          final data = {
                            'nombre': nombre.text.trim(),
                            'direccion': direccion.text.trim(),
                            'telefono': telefono.text.trim(),
                            'email': email.text.trim(),
                          };

                          bool success;
                          if (isEdit) {
                            success = await _controller.actualizarProveedor(supplier['proveedorId'], data);
                          } else {
                            _controller.nombreCtrl.text = data['nombre']!;
                            _controller.direccionCtrl.text = data['direccion']!;
                            _controller.telefonoCtrl.text = data['telefono']!;
                            _controller.emailCtrl.text = data['email']!;
                            success = await _controller.agregarProveedor();
                          }

                          if (mounted) {
                            Navigator.pop(diaCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? (isEdit ? 'Actualizado' : 'Agregado') : 'Error'),
                                backgroundColor: success ? AppTheme.greenMetal : AppTheme.reiOrangeRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Text(isEdit ? 'Guardar Cambios' : 'Registrar Proveedor', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool req = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: AppTheme.ayanamiBlue.withOpacity(0.7)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        validator: req ? (v) => v!.trim().isEmpty ? 'Requerido' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: _buildHeader(),
      ),
      body: Column(
        children: [
          Expanded(child: _buildSupplierGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Proveedores', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.displaySmall?.color)),
              const Text('Gestiona tus fuentes de suministro', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _controller.searchCtrl,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('Nuevo Proveedor', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ayanamiBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierGrid() {
    if (_controller.isLoading) return const Center(child: CircularProgressIndicator());
    if (_controller.error != null) return Center(child: Text(_controller.error!, style: const TextStyle(color: Colors.red)));
    
    final list = _controller.filteredProveedores;
    if (list.isEmpty) return const Center(child: Text('No se encontraron proveedores', style: TextStyle(fontSize: 18, color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 220,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => _buildSupplierCard(list[i]),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> p) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.ayanamiBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.business_rounded, color: AppTheme.ayanamiBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(p['nombre'] ?? 'Sin nombre',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                IconButton(icon: Icon(Icons.edit_note, color: Theme.of(context).textTheme.bodyLarge?.color), onPressed: () => _showAddEditDialog(supplier: p)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.reiOrangeRed),
                  onPressed: () => _confirmDelete(p),
                ),
              ],
            ),
            Divider(height: 32, color: Theme.of(context).dividerColor),
            _iconText(Icons.email_outlined, p['email'] ?? 'No especificado'),
            const SizedBox(height: 8),
            _iconText(Icons.phone_outlined, p['telefono'] ?? 'No especificado'),
            const SizedBox(height: 8),
            _iconText(Icons.location_on_outlined, p['direccion'] ?? 'No especificado', maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, 
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
            maxLines: maxLines, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text('Eliminar Proveedor', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color)),
        content: Text('¿Deseas eliminar a "${p['nombre']}"? Esta acción no se puede deshacer.', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.reiOrangeRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _controller.eliminarProveedor(p['proveedorId']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Proveedor eliminado' : 'Error al eliminar'),
            backgroundColor: success ? AppTheme.greenMetal : AppTheme.reiOrangeRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}