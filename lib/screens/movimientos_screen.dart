import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/movimientos_controller.dart';
import '../theme/app_theme.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  final MovimientosController _controller = MovimientosController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registro de Movimientos', 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5, color: Theme.of(context).textTheme.titleLarge?.color)),
            const Text('Supervisa tu negocio en tiempo real', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2))
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.ayanamiBlue,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.ayanamiBlue, blurRadius: 6, spreadRadius: 2)]
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('Audit Sync', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.error != null
              ? _buildErrorState()
              : _buildList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.reiOrangeRed.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.reiOrangeRed.withOpacity(0.2))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_update_warning_rounded, color: AppTheme.reiOrangeRed, size: 70),
            const SizedBox(height: 24),
            Text(_controller.error!, style: const TextStyle(color: AppTheme.reiOrangeRed, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar Reconexión'),
              onPressed: () => _controller.init(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ayanamiBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_controller.movimientos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize_rounded, size: 100, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 24),
            const Text('El historial está impecable', style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Inicia operaciones para ver los movimientos aquí.', style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      itemCount: _controller.movimientos.length,
      itemBuilder: (context, index) {
        final item = _controller.movimientos[index];
        return _ActivityTimelineTile(
          item: item,
          isFirst: index == 0,
          isLast: index == _controller.movimientos.length - 1,
        );
      },
    );
  }
}

class _ActivityTimelineTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isFirst;
  final bool isLast;

  const _ActivityTimelineTile({required this.item, required this.isFirst, required this.isLast});

  @override
  State<_ActivityTimelineTile> createState() => _ActivityTimelineTileState();
}

class _ActivityTimelineTileState extends State<_ActivityTimelineTile> {
  bool _isHovered = false;

  void _showDetails(BuildContext context) {
    if (widget.item['payload'] == null || widget.item['payload'] is! Map) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                )
              ]
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getColor().withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(), color: _getColor(), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Inspección de Registro', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
                            Text('ID: ${widget.item['cambioId']?.toString().substring(0,8) ?? "N/A" }...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).textTheme.titleLarge?.color)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 32, endIndent: 32),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(32),
                    children: _buildPayloadCards(widget.item['payload'] as Map<String, dynamic>, context),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPayloadCards(Map<String, dynamic> payload, BuildContext context) {
    return payload.entries.map((e) {
      final key = _formatKey(e.key);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            _buildValueWidget(e.value, context),
          ],
        ),
      );
    }).toList();
  }

  String _formatKey(String key) {
    if (key.isEmpty) return key;
    final text = key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}');
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildValueWidget(dynamic value, BuildContext context) {
    if (value is Map) {
      return Text(value.toString(), style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500));
    }
    if (value is List) {
      if (value.isEmpty) return const Text('Sin registros', style: TextStyle(color: Colors.grey));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.map((e) {
          if (e is Map) {
            final nombre = e['nombre'] ?? e['producto'] ?? e['id'] ?? 'Elemento';
            final cant = e['cantidadDeUnidades'] ?? e['cantidad'] ?? '';
            final sub = e['subTotal'] ?? '';
            return Container(
              margin: const EdgeInsets.only(top: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(nombre.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  if (cant.toString().isNotEmpty) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('x$cant', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                  if (sub.toString().isNotEmpty) Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text('\$$sub', style: const TextStyle(color: AppTheme.greenMetal, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('• $e', style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
          );
        }).toList(),
      );
    }
    final text = value?.toString() ?? 'N/A';
    return Text(text, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w600));
  }

  Color _getColor() {
    final accion = widget.item['accion']?.toString().toLowerCase() ?? '';
    switch (accion) {
      case 'venta': return AppTheme.greenMetal;
      case 'crear': return AppTheme.ayanamiBlue;
      case 'eliminar': return AppTheme.reiOrangeRed;
      case 'modificar': return Colors.amber.shade700;
      default: return Colors.grey;
    }
  }

  IconData _getIcon() {
    final accion = widget.item['accion']?.toString().toLowerCase() ?? '';
    switch (accion) {
      case 'venta': return Icons.point_of_sale_rounded;
      case 'crear': return Icons.add_circle_rounded;
      case 'eliminar': return Icons.delete_rounded;
      case 'modificar': return Icons.edit_rounded;
      default: return Icons.info_outline;
    }
  }

  String _getVerb() {
    final accion = widget.item['accion']?.toString().toLowerCase() ?? '';
    switch (accion) {
      case 'venta': return 'completó una venta de';
      case 'crear': return 'registró un nuevo';
      case 'eliminar': return 'eliminó un registro de';
      case 'modificar': return 'actualizó información de';
      default: return 'realizó una acción en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    final verb = _getVerb();
    final entidad = widget.item['entidad']?.toString().toLowerCase() ?? '';
    final nombreUsuario = widget.item['nombreUsuario'] ?? 'Usuario Desconocido';
    final payload = widget.item['payload'] is Map ? widget.item['payload'] as Map : {};
    
    final createdAtStr = widget.item['created_at']?.toString() ?? '';
    String timeAgo = 'Justo ahora';
    String exactTime = '--:--';
    
    try {
       final dt = DateTime.parse(createdAtStr).toLocal();
       
       final diff = DateTime.now().difference(dt);
       if (diff.inSeconds < 60) timeAgo = 'Justo ahora';
       else if (diff.inMinutes < 60) timeAgo = 'Hace ${diff.inMinutes} min';
       else if (diff.inHours < 24) timeAgo = 'Hace ${diff.inHours} hrs';
       else timeAgo = 'Hace ${diff.inDays} días';
    } catch (_) {}

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(width: 2, height: 20, color: widget.isFirst ? Colors.transparent : Theme.of(context).dividerColor),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.5), width: 2)
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                Expanded(child: Container(width: 2, color: widget.isLast ? Colors.transparent : Theme.of(context).dividerColor)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Main Activity Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: () => _showDetails(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isHovered ? Theme.of(context).cardColor : Theme.of(context).cardColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isHovered ? color.withOpacity(0.5) : Theme.of(context).dividerColor.withOpacity(0.5),
                        width: 1.5
                      ),
                      boxShadow: [
                        if (_isHovered)
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                  child: const Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                                ),
                                const SizedBox(width: 8),
                                Text(nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).dividerColor)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(timeAgo, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            children: [
                              TextSpan(text: verb),
                              TextSpan(text: ' ${entidad.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (payload.isNotEmpty)
                           Container(
                             padding: const EdgeInsets.all(12),
                             decoration: BoxDecoration(
                               color: color.withOpacity(0.05),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(
                               children: [
                                 Icon(Icons.data_object_rounded, size: 16, color: color.withOpacity(0.8)),
                                 const SizedBox(width: 8),
                                 Expanded(
                                   child: Text(
                                     'ID: ${widget.item['cambioId']?.toString().substring(0,8) ?? "..."} • Clic para ver payload completo',
                                      style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                               ],
                             ),
                           )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
