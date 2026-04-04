import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReceiptDialog extends StatelessWidget {
  final Map<String, dynamic> sale;

  const ReceiptDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.greenMetal, size: 60),
              const SizedBox(height: 16),
              Text('FarmaBook',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.titleLarge?.color)),
              const Text('RECIBO DE VENTA',
                  style: TextStyle(
                      letterSpacing: 2, fontSize: 12, color: Colors.grey)),
              Divider(
                  height: 40,
                  thickness: 1,
                  color: Theme.of(context).dividerColor),
              _receiptRow(context, 'ID Venta:', '#${sale['ventaId']}'),
              _receiptRow(context, 'Fecha:', _formatDate(_getSafeDate(sale))),
              _receiptRow(context, 'Hora:', _formatTime(_getSafeDate(sale))),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('PRODUCTOS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color:
                            Theme.of(context).textTheme.titleLarge?.color)),
              ),
              const SizedBox(height: 12),
              ...((sale['productosVendidos'] as List<dynamic>?) ??
                      (sale['detalles'] as List<dynamic>?) ??
                      (sale['items'] as List<dynamic>?) ??
                      [])
                  .map((det) {
                final Map<String, dynamic> d = det as Map<String, dynamic>;
                final String nombre = d['nombre'] ??
                    d['producto']?['nombre'] ??
                    d['nombreProducto'] ??
                    d['productoNombre'] ??
                    'Producto';
                final String pres =
                    d['presentacion'] ?? d['producto']?['presentacion'] ?? '';
                final int qty = d['cantidadDeUnidades'] ?? d['cantidad'] ?? 1;
                final double price = double.tryParse(
                        d['subTotal']?.toString() ??
                            d['precioTotal']?.toString() ??
                            d['subtotal']?.toString() ??
                            '0') ??
                    0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${qty}x $nombre ${pres.isNotEmpty ? "($pres)" : ""}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color)),
                    ],
                  ),
                );
              }),
              Divider(
                  height: 40,
                  thickness: 2,
                  color: Theme.of(context).dividerColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color:
                              Theme.of(context).textTheme.titleLarge?.color)),
                  Text(
                      '\$${(double.tryParse(sale['total']?.toString() ?? '0') ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppTheme.greenMetal)),
                ],
              ),
              const SizedBox(height: 40),
              const Text('¡Gracias por su compra!',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ayanamiBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CERRAR'),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _receiptRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  String _getSafeDate(Map<String, dynamic> json) {
    if (json.isEmpty) return DateTime.now().toIso8601String();
    final fields = ['fechaDeVenta', 'fechaVenta', 'fecha_venta', 'fecha', 'createdAt', 'created_at', 'date', 'updatedAt'];
    for(var f in fields) {
       if(json[f] != null && json[f].toString().isNotEmpty) {
           return json[f].toString();
       }
    }
    return DateTime.now().toIso8601String();
  }
}
