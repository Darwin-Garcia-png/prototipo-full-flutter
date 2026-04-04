import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../controllers/ventas_controller.dart';
import '../widgets/ventas/cart_section.dart';
import '../widgets/ventas/sales_results_grid.dart';
import '../widgets/ventas/sales_search_section.dart';
import '../widgets/ventas/receipt_dialog.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentasController _controller = VentasController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VentasController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('FarmaPOS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Theme.of(context).textTheme.titleLarge?.color)),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            Consumer<VentasController>(
              builder: (context, controller, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.error!), backgroundColor: Colors.red),
                    );
                    controller.clearMessage();
                  }
                });

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                      onPressed: () => controller.cargarHistorialVentas(),
                      tooltip: 'Refrescar Historial',
                    ),
                    if (controller.carrito.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: Icon(Icons.delete_sweep_rounded,
                              color: Theme.of(context).textTheme.bodyLarge?.color),
                          onPressed: controller.vaciarCarrito,
                          tooltip: 'Vaciar carrito',
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
            ),
            child: Consumer<VentasController>(
              builder: (context, controller, child) {
                return Column(
                  children: [
                    if (controller.vistaActual == VentasView.search) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SalesSearchSection(),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: SalesResultsGrid(),
                        ),
                      ),
                    ] else if (controller.vistaActual == VentasView.history) ...[
                      _buildHeader(context, 'Ventas Registradas', Icons.list_alt),
                      Expanded(child: _buildSalesHistoryList(context, controller)),
                    ] else if (controller.vistaActual == VentasView.receipts) ...[
                      _buildHeader(context, 'Archivo de Recibos', Icons.receipt_long),
                      Expanded(child: _buildReceiptsCardsList(context, controller)),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
        const Expanded(
          flex: 4,
          child: CartSection(),
        ),
        _buildSidebar(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.ayanamiBlue, size: 28),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).textTheme.titleLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Consumer<VentasController>(
      builder: (context, controller, child) {
        return Container(
          width: 110,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A1A1A)
                : const Color(0xFF2A4365),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(-2, 0))
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _navButton(
                icon: Icons.search,
                label: 'Vender',
                isSelected: controller.vistaActual == VentasView.search,
                onTap: () => controller.setVista(VentasView.search),
              ),
              _navButton(
                icon: Icons.history,
                label: 'Historial',
                isSelected: controller.vistaActual == VentasView.history,
                onTap: () => controller.setVista(VentasView.history),
              ),
              _navButton(
                icon: Icons.receipt_long_rounded,
                label: 'Recibos',
                isSelected: controller.vistaActual == VentasView.receipts,
                onTap: () => controller.setVista(VentasView.receipts),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('FarmaBook v1.0',
                    style: TextStyle(color: Colors.white24, fontSize: 10)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.ayanamiBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesHistoryList(BuildContext context, VentasController controller) {
    if (controller.isLoadingHistorial) return const Center(child: CircularProgressIndicator());
    if (controller.ventasHistorial.isEmpty) return const Center(child: Text('No hay ventas registradas', style: TextStyle(color: Colors.grey)));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.ventasHistorial.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, index) {
        final sale = controller.ventasHistorial[index];
        return ListTile(
          onTap: () => _showReceipt(context, sale),
          leading: CircleAvatar(
              backgroundColor: AppTheme.ayanamiBlue.withOpacity(0.1),
              child: const Icon(Icons.shopping_cart, color: AppTheme.ayanamiBlue)),
          title: Text('Venta #${sale['ventaId']}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          subtitle: Text(
              '${_formatDate(_getSafeDate(sale))} ${_formatTime(_getSafeDate(sale))}',
              style: const TextStyle(color: Colors.grey)),
          trailing: Text('\$${sale['total']}',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.greenMetal)),
        );
      },
    );
  }

  Widget _buildReceiptsCardsList(BuildContext context, VentasController controller) {
    if (controller.isLoadingHistorial) return const Center(child: CircularProgressIndicator());
    if (controller.ventasHistorial.isEmpty) return const Center(child: Text('No hay recibos disponibles', style: TextStyle(color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.ventasHistorial.length,
      itemBuilder: (context, index) {
        final sale = controller.ventasHistorial[index];
        return InkWell(
          onTap: () => _showReceipt(context, sale),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.receipt, color: AppTheme.ayanamiBlue, size: 20),
                    Text('\$${sale['total']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.greenMetal)),
                  ],
                ),
                const Spacer(),
                Text('Factura #${sale['ventaId']}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 4),
                Text(_formatDate(_getSafeDate(sale)),
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReceipt(BuildContext context, Map<String, dynamic> sale) {
    showDialog(context: context, builder: (ctx) => ReceiptDialog(sale: sale));
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr.toString()).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      try {
        final s = dateStr.toString();
        if (s.contains('T')) return s.split('T')[0];
        return s.split(' ')[0];
      } catch (__) { return 'N/A'; }
    }
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr.toString()).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      try {
        final s = dateStr.toString();
        if (s.contains('T')) return s.split('T')[1].substring(0, 5);
        if (s.contains(' ')) return s.split(' ')[1].substring(0, 5);
      } catch (__) { return 'N/A'; }
    }
    return 'N/A';
  }

  String _getSafeDate(Map<String, dynamic> json) {
    if (json.isEmpty) return DateTime.now().toIso8601String();
    
    // Lista de posibles nombres de campos de fecha
    final fields = ['fechaDeVenta', 'fechaVenta', 'fecha_venta', 'fecha', 'createdAt', 'created_at', 'date', 'updatedAt'];
    
    for(var f in fields) {
       if(json[f] != null && json[f].toString().isNotEmpty) {
           return json[f].toString();
       }
    }
    
    // Búsqueda profunda en niveles anidados (útil si la venta envuelve la fecha dentro de otro nodo)
    for (var value in json.values) {
      if (value is Map<String, dynamic>) {
        for (var f in fields) {
          if (value[f] != null && value[f].toString().isNotEmpty) {
            return value[f].toString();
          }
        }
      }
    }
    
    // Si realmente el backend no entrega fecha, lo marcamos para que lo sepas identificar visualmente
    return "2000-01-01T00:00:00Z"; 
  }
}
