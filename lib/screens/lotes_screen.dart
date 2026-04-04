import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/almacen_controller.dart';
import '../controllers/lotes_controller.dart';
import '../theme/app_theme.dart';
import '../utils/inventory_dialogs.dart';

class LotesScreen extends StatefulWidget {
  const LotesScreen({super.key});

  @override
  State<LotesScreen> createState() => _LotesScreenState();
}

class _LotesScreenState extends State<LotesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lotesCtrl = Provider.of<LotesController>(context, listen: false);
      if (lotesCtrl.externalSearchQuery.isNotEmpty) {
        setState(() {
          _searchQuery = lotesCtrl.externalSearchQuery;
          _searchCtrl.text = _searchQuery;
        });
        lotesCtrl.clearExternalSearch();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AlmacenController, LotesController>(
      builder: (context, almacenCtrl, lotesCtrl, child) {
        final filteredBySearch = lotesCtrl.allBatches.where((b) {
          final query = _searchQuery.toLowerCase();
          final prodNom = (b['productoNombre'] ?? '').toString().toLowerCase();
          final batchNom = (b['nombreLote'] ?? '').toString().toLowerCase();
          return prodNom.contains(query) || batchNom.contains(query);
        }).toList();

        List<Map<String, dynamic>> finalDisplayBatches = filteredBySearch;
        
        if (lotesCtrl.sortByExpiry) {
           finalDisplayBatches = filteredBySearch.where((b) {
             final d = DateTime.tryParse(b['fechaDeVencimiento'] ?? b['fechaVencimiento'] ?? '');
             if (d == null) return false;
             return d.isBefore(DateTime.now().add(const Duration(days: 60)));
           }).toList();

           finalDisplayBatches.sort((a, b) {
            final dateA = DateTime.tryParse(a['fechaDeVencimiento'] ?? a['fechaVencimiento'] ?? '9999-12-31');
            final dateB = DateTime.tryParse(b['fechaDeVencimiento'] ?? b['fechaVencimiento'] ?? '9999-12-31');
            return dateA?.compareTo(dateB ?? DateTime(9999)) ?? 0;
          });
        } else if (lotesCtrl.sortByLowStock) {
           finalDisplayBatches = filteredBySearch.where((b) {
             final stock = int.tryParse(b['cantidadDisponible'].toString()) ?? 0;
             return stock < 30;
           }).toList();
           
           finalDisplayBatches.sort((a, b) {
             final stockA = int.tryParse(a['cantidadDisponible'].toString()) ?? 0;
             final stockB = int.tryParse(b['cantidadDisponible'].toString()) ?? 0;
             return stockA.compareTo(stockB);
           });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text('Gestión Global de Lotes', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.darkSlate
              )
            ),
          ),
          body: Column(
            children: [
              _buildSearchBar(context),
              _buildFilterRow(lotesCtrl),
              Expanded(
                child: lotesCtrl.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : finalDisplayBatches.isEmpty
                    ? _buildEmptyState(lotesCtrl.sortByExpiry || lotesCtrl.sortByLowStock)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: finalDisplayBatches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (ctx, i) => _buildBatchCard(finalDisplayBatches[i], almacenCtrl, lotesCtrl),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Buscar por producto o lote...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.ayanamiBlue),
          filled: true,
          fillColor: Theme.of(context).cardTheme.color,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterRow(LotesController lotesCtrl) {
    final int nearCount = lotesCtrl.allBatches.where((l) {
      final d = DateTime.tryParse(l['fechaDeVencimiento'] ?? l['fechaVencimiento'] ?? '');
      return d != null && d.isBefore(DateTime.now().add(const Duration(days: 60)));
    }).length;

    final int lowStockCount = lotesCtrl.allBatches.where((l) {
      final stock = int.tryParse(l['cantidadDisponible'].toString()) ?? 0;
      return stock < 30;
    }).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip(
            icon: Icons.timer_outlined, 
            label: 'Vencimiento ($nearCount)', 
            selected: lotesCtrl.sortByExpiry, 
            color: AppTheme.ayanamiBlue,
            onTap: () => lotesCtrl.toggleExpiryFilter(),
          ),
          const SizedBox(width: 12),
          _buildFilterChip(
            icon: Icons.inventory_2_outlined, 
            label: 'Bajo Stock ($lowStockCount)', 
            selected: lotesCtrl.sortByLowStock, 
            color: AppTheme.reiPurple,
            onTap: () => lotesCtrl.toggleLowStockFilter(),
          ),
          const Spacer(),
          Text('${lotesCtrl.allBatches.length} lotes', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon, 
    required String label, 
    required bool selected, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16, color: selected ? Colors.white : color),
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? Colors.white : color)),
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : color.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.3))),
        elevation: 0,
      ),
      onPressed: onTap,
    );
  }

  Widget _buildBatchCard(Map<String, dynamic> b, AlmacenController almacenCtrl, LotesController lotesCtrl) {
    final expDate = DateTime.tryParse(b['fechaDeVencimiento']?.toString() ?? b['fechaVencimiento']?.toString() ?? '');
    final isNear = expDate != null && expDate.isBefore(DateTime.now().add(const Duration(days: 60)));
    final isExpired = expDate != null && expDate.isBefore(DateTime.now());
    final stock = int.tryParse(b['cantidadDisponible'].toString()) ?? 0;
    final isLow = stock < 30;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: isExpired ? AppTheme.reiOrangeRed.withOpacity(0.3) : (isLow ? AppTheme.reiPurple.withOpacity(0.3) : (isNear ? Colors.orange.withOpacity(0.3) : Colors.transparent)), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: (isLow ? AppTheme.reiPurple : AppTheme.ayanamiBlue).withOpacity(0.05),
              child: Row(
                children: [
                  Icon(Icons.medication_outlined, size: 16, color: isLow ? AppTheme.reiPurple : AppTheme.ayanamiBlue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b['productoNombre'] ?? 'Desconocido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isLow ? AppTheme.reiPurple : AppTheme.ayanamiBlue), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text('#${(b['loteId']?.toString() ?? 'N/A').substring(0, 6)}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['nombreLote'] ?? 'Lote Principal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(isExpired ? Icons.error_outline : Icons.event_available, size: 14, color: isExpired ? AppTheme.reiOrangeRed : isNear ? Colors.orange : Colors.grey),
                            const SizedBox(width: 6),
                            Text(expDate == null ? 'Sin fecha' : 'Vence: ${expDate.day}/${expDate.month}/${expDate.year}', style: TextStyle(fontSize: 12, fontWeight: (isNear || isExpired) ? FontWeight.bold : FontWeight.normal, color: isExpired ? AppTheme.reiOrangeRed : isNear ? Colors.orange : Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$stock uds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isLow ? AppTheme.reiPurple : AppTheme.greenMetal)),
                      Text('\$${(double.tryParse((b['costoCompra'] ?? b['costoDeCompra'] ?? '0').toString()) ?? 0.0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  _buildActions(b, almacenCtrl, lotesCtrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> b, AlmacenController almacenCtrl, LotesController lotesCtrl) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit_note, color: AppTheme.ayanamiBlue), onPressed: () => InventoryDialogs.showAddEditProduct(context, almacenCtrl, lotesCtrl, prod: b['originalProduct'], prefillBatch: b)),
        IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: AppTheme.reiOrangeRed), onPressed: () => _confirmDelete(b, lotesCtrl, almacenCtrl)),
      ],
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> b, LotesController lotesCtrl, AlmacenController almacenCtrl) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: Text('¿Deseas eliminar el lote "${b['nombreLote']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.reiOrangeRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      await lotesCtrl.deleteBatch(b['loteId'].toString());
      almacenCtrl.fetchProducts(isRefresh: true);
    }
  }

  Widget _buildEmptyState(bool isFiltered) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isFiltered ? Icons.filter_alt_off_outlined : Icons.layers_clear_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(isFiltered ? 'No se encontraron lotes con ese filtro' : 'No se encontraron lotes', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
