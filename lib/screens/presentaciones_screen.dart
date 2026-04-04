import 'package:flutter/material.dart';
import '../controllers/presentaciones_controller.dart';
import '../theme/app_theme.dart';

class PresentacionesScreen extends StatefulWidget {
  const PresentacionesScreen({super.key});

  @override
  State<PresentacionesScreen> createState() => _PresentacionesScreenState();
}

class _PresentacionesScreenState extends State<PresentacionesScreen> {
  final PresentacionesController _controller = PresentacionesController();

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

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nueva Presentación',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
                    IconButton(icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color), onPressed: () => Navigator.pop(diaCtx)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField('Nombre *', _controller.nombreCtrl, Icons.local_pharmacy, req: true),
                _buildField('Descripción', _controller.descripcionCtrl, Icons.description, maxLines: 3),
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
                        final success = await _controller.agregarPresentacion();
                        if (mounted) {
                          Navigator.pop(diaCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Presentación registrada' : 'Error al registrar'),
                              backgroundColor: success ? AppTheme.greenMetal : AppTheme.reiOrangeRed,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Registrar Presentación', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool req = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: AppTheme.ayanamiBlue.withOpacity(0.7)),
          alignLabelWithHint: maxLines > 1,
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
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCategoryGrid(),
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Presentaciones', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.displaySmall?.color)),
              const Text('Formatos, empaques y envases', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_box_rounded),
            label: const Text('Nueva Presentación', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ayanamiBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_controller.error != null) {
      return Center(child: Text(_controller.error!, style: const TextStyle(color: Colors.red)));
    }
    
    if (_controller.presentaciones.isEmpty) {
      return const Center(child: Text('No hay presentaciones registradas', style: TextStyle(fontSize: 18, color: Colors.grey)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisExtent: 160,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: _controller.presentaciones.length,
      itemBuilder: (context, i) {
        final cat = _controller.presentaciones[i];
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.ayanamiBlue.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.local_pharmacy_rounded, color: AppTheme.ayanamiBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(cat['nombre'] ?? 'Sin nombre',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  cat['descripcion']?.isEmpty ?? true ? 'Sin descripción provista' : cat['descripcion'],
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}