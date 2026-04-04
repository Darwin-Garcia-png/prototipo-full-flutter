import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/almacen_controller.dart';
import '../../controllers/lotes_controller.dart';
import '../../utils/inventory_dialogs.dart';

class BatchDetailsModal extends StatelessWidget {
  final Map<String, dynamic> p;
  final List lotes;
  final AlmacenController controller;
  final LotesController lotesCtrl;

  const BatchDetailsModal({
    super.key,
    required this.p,
    required this.lotes,
    required this.controller,
    required this.lotesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                    backgroundColor: AppTheme.ayanamiBlue.withOpacity(0.1),
                    child: const Icon(Icons.layers_outlined,
                        color: AppTheme.ayanamiBlue)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lotes de ${p['nombre']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${lotes.length} lotes registrados',
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.ayanamiBlue),
                  onPressed: () {
                    Navigator.pop(context);
                    InventoryDialogs.showAddEditProduct(
                        context, controller, lotesCtrl,
                        prod: p, isNewBatchOnly: true);
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: lotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (itemCtx, i) {
                final l = lotes[i];
                final expDate = DateTime.tryParse(
                    l['fechaDeVencimiento']?.toString() ??
                        l['fechaVencimiento']?.toString() ??
                        '');
                final isNear = expDate != null &&
                    expDate.isBefore(
                        DateTime.now().add(const Duration(days: 60)));

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isNear
                            ? Colors.orange.withOpacity(0.3)
                            : Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l['nombreLote'] ?? 'Sin Nombre',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.event_available,
                                    size: 12,
                                    color:
                                        isNear ? Colors.orange : Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    expDate != null
                                        ? '${expDate.day}/${expDate.month}/${expDate.year}'
                                        : 'Sin fecha',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isNear
                                            ? Colors.orange
                                            : Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${l['cantidadDisponible']} uds',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.ayanamiBlue)),
                          Text(
                              '\$${(double.tryParse((l['costoCompra'] ?? l['costoDeCompra'] ?? '0').toString()) ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_note,
                            color: AppTheme.ayanamiBlue),
                        onPressed: () {
                          Navigator.pop(context);
                          InventoryDialogs.showAddEditProduct(
                              context, controller, lotesCtrl,
                              prod: p, prefillBatch: l);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_outlined,
                            color: AppTheme.reiOrangeRed),
                        onPressed: () => _confirmarBorradoLote(
                            context, l, lotesCtrl, controller),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarBorradoLote(BuildContext context, dynamic batch,
      LotesController lotesCtrl, AlmacenController controller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: Text('¿Deseas eliminar el lote "${batch['nombreLote']}"?'),
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
      await lotesCtrl.deleteBatch(batch['loteId'].toString());
      controller.fetchProducts(isRefresh: true);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
