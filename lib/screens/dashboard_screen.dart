import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/dashboard_controller.dart';
import '../theme/app_theme.dart';
import 'inicio_screen.dart';
import 'almacen_screen.dart';
import 'proveedores_screen.dart';
import 'estadisticas_screen.dart';
import 'ventas_screen.dart';
import 'alertas_screen.dart';
import 'lotes_screen.dart';
import 'movimientos_screen.dart';
import 'categorias_screen.dart';
import 'presentaciones_screen.dart';
import 'usuarios_screen.dart';
import '../controllers/notificaciones_controller.dart';
import 'dart:ui';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardController _controller;
  late NotificacionesController _notifController;

  final List<Widget> _screens = const [
    InicioScreen(), // 0
    AlmacenScreen(), // 1
    VentasScreen(), // 2 - Punto de Venta
    LotesScreen(), // 3 - Gestión de Lotes
    EstadisticasScreen(), // 4 - Análisis
    AlertasScreen(), // 5 - Centro de Alertas
    MovimientosScreen(), // 6
    CategoriasScreen(), // 7
    PresentacionesScreen(), // 8
    ProveedoresScreen(), // 9
    UsuariosScreen(), // 10
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = Provider.of<DashboardController>(context);
    _notifController = Provider.of<NotificacionesController>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _buildSimpleBrandTitle(context),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, 
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        elevation: 0,
        actions: [
          _buildNotificationBell(),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 24),
            tooltip: 'Configuración',
            onPressed: () => context.push('/configuracion'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).cardTheme.color, 
        child: Column(
          children: [
            _buildDrawerHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.dashboard_rounded, 'Panel Inicio', 0),
                  _buildDrawerItem(Icons.inventory_2_rounded, 'Inventario Global', 1),
                  _buildDrawerItem(Icons.point_of_sale_rounded, 'Punto de Venta', 2),
                  _buildDrawerItem(Icons.layers_outlined, 'Gestión de Lotes', 3),
                  _buildDrawerItem(Icons.analytics_rounded, 'Estadísticas', 4),
                  _buildDrawerItem(Icons.warning_amber_rounded, 'Centro de Alertas', 5),
                  _buildDrawerItem(Icons.history_rounded, 'Movimientos Hoy', 6),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Divider(height: 1),
                  ),

                  // Grupo Plegable de Catálogos
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.auto_stories_rounded, color: Colors.grey, size: 22),
                      title: const Text('Catálogos y Base', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      childrenPadding: const EdgeInsets.only(left: 12),
                      children: [
                        _buildDrawerItem(Icons.category_rounded, 'Categorías', 7),
                        _buildDrawerItem(Icons.medication_liquid_rounded, 'Presentaciones', 8),
                        _buildDrawerItem(Icons.local_shipping_rounded, 'Proveedores', 9),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildLogoutItem(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _screens[_controller.selectedIndex],
    );
  }

  Widget _buildSimpleBrandTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.local_pharmacy_rounded, color: AppTheme.ayanamiBlue, size: 24),
        const SizedBox(width: 12),
        Text(
          'FarmaBook POS',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.ayanamiBlue,
        gradient: isDark ? null : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6DABE4), Color(0xFF2A4365)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Icon(Icons.local_pharmacy_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('FarmaBook',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _controller.selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.black54;
    Color iconColor = Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7) ?? Colors.black54;

    if (isSelected) {
      textColor = isDark ? Colors.white : AppTheme.ayanamiBlue;
      iconColor = isDark ? Colors.white : AppTheme.ayanamiBlue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: AppTheme.ayanamiBlue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title,
          style: TextStyle(color: textColor, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
        ),
        onTap: () {
          _controller.onItemTapped(index);
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLogoutItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: const Icon(Icons.logout_rounded, color: AppTheme.reiOrangeRed, size: 22),
        title: const Text('Cerrar Sesión',
          style: TextStyle(color: AppTheme.reiOrangeRed, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          Navigator.pop(context);
          await _controller.logout();
          if (mounted) context.go('/login');
        },
      ),
    );
  }

  Widget _buildNotificationBell() {
    return _PremiumNotificationBell(
      count: _notifController.unreadCount,
      onTap: () {
        _notifController.markAllAsRead();
        context.push('/alertas');
      },
    );
  }
}

class _PremiumNotificationBell extends StatefulWidget {
  final int count;
  final VoidCallback onTap;

  const _PremiumNotificationBell({required this.count, required this.onTap});

  @override
  State<_PremiumNotificationBell> createState() => _PremiumNotificationBellState();
}

class _PremiumNotificationBellState extends State<_PremiumNotificationBell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    widget.count > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_outlined,
                    size: 28,
                    color: widget.count > 0 ? AppTheme.reiPurple : AppTheme.darkSlate,
                  ),
                ),
                if (widget.count > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.reiPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.reiPurple.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${widget.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
