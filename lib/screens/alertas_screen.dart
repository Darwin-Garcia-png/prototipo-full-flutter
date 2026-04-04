import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notificaciones_controller.dart';
import '../controllers/lotes_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../theme/app_theme.dart';

class AlertasScreen extends StatelessWidget {
  const AlertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<NotificacionesController, LotesController, DashboardController>(
      builder: (context, notifCtrl, lotesCtrl, dashCtrl, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text('Centro de Alertas', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleLarge?.color)),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.done_all_rounded, size: 20),
                label: const Text('Marcar Todo como Leído'),
                onPressed: notifCtrl.markAllAsRead,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Header para Control de Notificaciones Push
              _buildPushControlHeader(context, notifCtrl),
              
              Expanded(
                child: notifCtrl.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifCtrl.notificaciones.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: notifCtrl.notificaciones.length,
                            itemBuilder: (ctx, i) => _buildAlertCard(context, notifCtrl.notificaciones[i], lotesCtrl, dashCtrl),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPushControlHeader(BuildContext context, NotificacionesController notifCtrl) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: notifCtrl.isPushEnabled 
            ? AppTheme.ayanamiBlue.withOpacity(0.05) 
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notifCtrl.isPushEnabled 
              ? AppTheme.ayanamiBlue.withOpacity(0.2) 
              : Colors.grey.withOpacity(0.2)
        ),
      ),
      child: Row(
        children: [
          Icon(
            notifCtrl.isPushEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
            color: notifCtrl.isPushEnabled ? AppTheme.ayanamiBlue : Colors.grey,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notificaciones Flotantes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  notifCtrl.isPushEnabled 
                      ? 'Activadas (sonarán cada 45s si hay pendientes)' 
                      : 'Desactivadas (solo historial)', 
                  style: const TextStyle(fontSize: 11, color: Colors.grey)
                ),
              ],
            ),
          ),
          Switch(
            value: notifCtrl.isPushEnabled,
            onChanged: notifCtrl.togglePush,
            activeColor: AppTheme.ayanamiBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Map<String, dynamic> n, LotesController lotesCtrl, DashboardController dashCtrl) {
    final tipo = n['tipo'] ?? 'aviso';
    final isUrgent = tipo == 'stock_bajo';
    final color = isUrgent ? AppTheme.reiPurple : AppTheme.ayanamiBlue;
    final msg = n['mensaje'] ?? 'Sin detalle';
    final fecha = n['fecha'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
            final match = RegExp(r'lote: (\w+)').firstMatch(msg);
            if (match != null) {
                final loteNombre = match.group(1);
                lotesCtrl.setExternalSearch(loteNombre!);
                dashCtrl.onItemTapped(3); // Gestión de Lotes
                // We keep the stack for now or just navigate
            }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(isUrgent ? Icons.inventory_2_rounded : Icons.event_busy_rounded, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isUrgent ? '¡ALERTA DE STOCK!' : 'AVISO DE VENCIMIENTO',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(fecha, style: TextStyle(fontSize: 10, color: AppTheme.darkSlate.withOpacity(0.8), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('Todo en orden por ahora', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
