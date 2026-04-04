import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/almacen_controller.dart';
import '../../controllers/lotes_controller.dart';
import '../../utils/inventory_dialogs.dart';
import 'batch_details_modal.dart';

class ProductCard extends StatelessWidget {
  final dynamic p;
  final AlmacenController controller;
  final LotesController lotesCtrl;

  const ProductCard({
    super.key,
    required this.p,
    required this.controller,
    required this.lotesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final int stock = p['cantidadDisponible'] ?? 0;
    final bool lowStock = stock < 30;
    final List lotes = p['lotes'] is List ? p['lotes'] : [];
    final String? imageUrl = p['imagenUrl'] ?? p['imagen'] ?? p['secure_url'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (lotes.length > 1) {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (ctx) => BatchDetailsModal(
                  p: Map<String, dynamic>.from(p),
                  lotes: lotes,
                  controller: controller,
                  lotesCtrl: lotesCtrl,
                ),
              );
            } else {
              InventoryDialogs.showAddEditProduct(
                  context, controller, lotesCtrl,
                  prod: Map<String, dynamic>.from(p));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: lowStock
                          ? [
                              AppTheme.reiDarkRed.withOpacity(0.15),
                              AppTheme.reiOrangeRed.withOpacity(0.05)
                            ]
                          : [
                              AppTheme.ayanamiBlue.withOpacity(0.15),
                              AppTheme.ayanamiBlue.withOpacity(0.05)
                            ],
                    ),
                  ),
                  child: Center(
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildIconPlaceholder(lowStock),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          )
                        : _buildIconPlaceholder(lowStock),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['nombre'] ?? 'Sin nombre',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Ref: ${p['codigoBarras'] ?? 'N/A'}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Stock',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text('$stock',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: lowStock
                                          ? AppTheme.reiOrangeRed
                                          : AppTheme.greenMetal)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Precio',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              Text(
                                '\$${_getSafePrice(p)}',
                                style: const TextStyle(
                                    color: AppTheme.ayanamiBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildProductActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder(bool lowStock) {
    return Icon(
      Icons.medication_liquid_rounded,
      size: 60,
      color: lowStock ? AppTheme.reiOrangeRed : AppTheme.ayanamiBlue,
    );
  }

  Widget _buildProductActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
              icon: Icon(Icons.edit,
                  size: 18,
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              label: Text('Editar',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              onPressed: () => InventoryDialogs.showAddEditProduct(
                  context, controller, lotesCtrl,
                  prod: p)),
          TextButton.icon(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppTheme.reiOrangeRed),
              label: const Text('Borrar',
                  style: TextStyle(color: AppTheme.reiOrangeRed)),
              onPressed: () => _confirmarBorrado(context)),
        ],
      ),
    );
  }

  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Eliminar "${p['nombre']}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.reiOrangeRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteProduct(p['productoId']);
    }
  }

  String _getSafePrice(dynamic p) {
    if (p == null) return "0.00";
    final List<String> fields = [
      'precioVenta',
      'precio_venta',
      'precioPorUnidad',
      'pvp',
      'precio_unidad',
      'precioUnidad',
      'precio',
      'costoCompra',
      'precioCompra'
    ];
    for (var f in fields) {
      final val = p[f];
      if (val != null) {
        final pVal = double.tryParse(val.toString()) ?? 0.0;
        if (pVal > 0) return pVal.toStringAsFixed(2);
      }
    }
    return "0.00";
  }
}
