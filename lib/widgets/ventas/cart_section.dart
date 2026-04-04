import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../controllers/ventas_controller.dart';
import 'receipt_dialog.dart';

class CartSection extends StatelessWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VentasController>();
    
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(-5, 0))
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, controller),
          Expanded(child: _buildItemsList(context, controller)),
          _buildSummarySection(context, controller),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VentasController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [AppTheme.ayanamiBlue, Color(0xFF5A9BD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text('Pedido Actual',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Text('${controller.carrito.length} Items',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, VentasController controller) {
    if (controller.carrito.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_shopping_cart_outlined,
                size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Carrito vacío',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: controller.carrito.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final id = controller.carrito.keys.elementAt(index);
        final qty = controller.carrito[id]!;
        final prod = controller.cacheProductos[id]!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prod.nombre,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color),
                        maxLines: 1),
                    Text('\$${prod.precioPorUnidad?.toStringAsFixed(2)} c/u',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: [
                  _qtyBtn(context, Icons.remove, () => controller.quitarDeCarrito(id)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('$qty',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Theme.of(context).textTheme.titleLarge?.color)),
                  ),
                  _qtyBtn(context, Icons.add, () => controller.agregarAlCarrito(prod)),
                ],
              ),
              const SizedBox(width: 12),
              Text('\$${((prod.precioPorUnidad ?? 0) * qty).toStringAsFixed(2)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: AppTheme.reiOrangeRed),
                label: const Text('Borrar',
                    style: TextStyle(color: AppTheme.reiOrangeRed)),
                onPressed: () => controller.eliminarDelCarrito(id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(BuildContext context, IconData icon, VoidCallback onPressed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: IconButton(
          icon: Icon(icon,
              size: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: onPressed,
          padding: EdgeInsets.zero),
    );
  }

  Widget _buildSummarySection(BuildContext context, VentasController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a Pagar',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text('\$${controller.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.ayanamiBlue)),
            ],
          ),
          const SizedBox(height: 24),
          if (controller.mensaje != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(controller.mensaje!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF166534), fontWeight: FontWeight.bold)),
            ),
          SizedBox(
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: controller.carrito.isEmpty || controller.isLoading
                  ? null
                  : () async {
                      final result = await controller.registrarVenta();
                      if (result != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (ctx) => ReceiptDialog(sale: result['data']),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.greenMetal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: controller.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('FINALIZAR VENTA',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
