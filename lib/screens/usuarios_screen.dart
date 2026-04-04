import 'package:flutter/material.dart';
import '../controllers/usuarios_controller.dart';
import '../theme/app_theme.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuariosController _controller = UsuariosController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.fetchAll();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
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
            Text('Gestión de Personal',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Theme.of(context).textTheme.titleLarge?.color)),
            const Text('Administra usuarios, cajeros y permisos',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: ElevatedButton.icon(
              onPressed: () => _showAddEditUserDialog(),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Nuevo Usuario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ayanamiBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildUserList(),
          
          // Maintenance Overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.4),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withOpacity(0.05), BlendMode.softLight),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30)],
                      border: Border.all(color: AppTheme.ayanamiBlue.withOpacity(0.2), width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The funny Rei Image
                        Image.network(
                          '/construccion.png',
                          height: 250,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.engineering_rounded, size: 100, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        const Text('ESTAMOS CONSTRUYENDO ESTO', 
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.darkSlate, letterSpacing: -1)),
                        const SizedBox(height: 12),
                        const Text('El servidor de roles tiene problemas técnicos para entenderse conmigo.', 
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.reiOrangeRed.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppTheme.reiOrangeRed, size: 18),
                              SizedBox(width: 8),
                              Text('Mantenimiento en curso', style: TextStyle(color: AppTheme.reiOrangeRed, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_controller.usuarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.ayanamiBlue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded,
                  size: 80, color: AppTheme.ayanamiBlue.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            const Text('Sin miembros en el equipo',
                style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('Comienza agregando a tu primer empleado',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 32),
          const Text('LISTADO DE STAFF', 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey, letterSpacing: 2)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _controller.usuarios.length,
              itemBuilder: (context, index) {
                final user = _controller.usuarios[index];
                final bool activo = user['activo'] ?? true;
                final String rolName = user['Rol']?['nombre'] ?? 'Personal';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ],
                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            color: activo ? Colors.greenAccent : Colors.redAccent,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppTheme.ayanamiBlue.withOpacity(0.1),
                                    child: Text((user['nombre'] ?? user['username'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(color: AppTheme.ayanamiBlue, fontWeight: FontWeight.w900, fontSize: 22)),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(user['nombre'] ?? user['username'] ?? 'Usuario',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.shield_outlined, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(rolName, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                                            const SizedBox(width: 12),
                                            const Text('•', style: TextStyle(color: Colors.grey)),
                                            const SizedBox(width: 12),
                                            Text(activo ? 'Activo' : 'Inactivo', 
                                              style: TextStyle(color: activo ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w800)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildUserActions(user),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statCard('Total Personal', _controller.usuarios.length.toString(), Icons.people_rounded, AppTheme.ayanamiBlue),
        const SizedBox(width: 20),
        _statCard('Roles Activos', _controller.roles.length.toString(), Icons.admin_panel_settings_rounded, Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUserActions(Map<String, dynamic> user) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_rounded, color: AppTheme.ayanamiBlue),
          onPressed: () => _showAddEditUserDialog(user: user),
          tooltip: 'Editar información',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.reiOrangeRed),
          onPressed: () => _confirmDelete(user),
          tooltip: 'Desactivar usuario',
        ),
      ],
    );
  }

  void _showAddEditUserDialog({Map<String, dynamic>? user}) {
    final isEdit = user != null;
    final nombreCtrl = TextEditingController(text: user?['nombre'] ?? user?['username']);
    final realNameCtrl = TextEditingController(text: user?['nombreCompleto'] ?? user?['nombre']);
    final passCtrl = TextEditingController();
    bool showPass = false;
    String? selectedRol = user?['rolId'] ?? user?['roleId'] ?? user?['rol']?.toString();
    if (selectedRol == null && _controller.roles.isNotEmpty) {
      selectedRol = _controller.roles.first['rolId']?.toString();
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87.withOpacity(0.8),
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB), // Softer Gray instead of Pure White
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40)],
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogHeader(isEdit),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATOS DEL EMPLEADO', 
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                          const SizedBox(height: 20),
                          _premiumField('Nombre Completo', 'Ej: Juan Pérez', realNameCtrl, Icons.badge_outlined),
                          const SizedBox(height: 12),
                          const Text('CREDENCIALES DE ACCESO', 
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                          const SizedBox(height: 20),
                          _premiumField('Username', 'Para el inicio de sesión', nombreCtrl, Icons.alternate_email_rounded),
                          
                          // Password Field with Toggle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: passCtrl,
                                obscureText: !showPass,
                                decoration: InputDecoration(
                                  hintText: isEdit ? 'Dejar en blanco para no cambiar' : 'Mínimo 8 caracteres',
                                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.ayanamiBlue),
                                  suffixIcon: IconButton(
                                    icon: Icon(showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: Colors.grey),
                                    onPressed: () => setDialogState(() => showPass = !showPass),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.05),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.all(20),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                          const SizedBox(height: 8),
                          const Text('AUTORIZACIÓN DE RANGO', 
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          _buildRoleSelector(selectedRol, (v) => setDialogState(() => selectedRol = v)),
                        ],
                      ),
                    ),
                  ),
                  _dialogActions(context, isEdit, nombreCtrl, realNameCtrl, passCtrl, selectedRol, user),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _dialogHeader(bool isEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.ayanamiBlue.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Icon(isEdit ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded, color: AppTheme.ayanamiBlue, size: 32),
          const SizedBox(width: 16),
          Text(isEdit ? 'Refinar Perfil' : 'Añadir al Equipo', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _premiumField(String label, String hint, TextEditingController ctrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4A5568))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.ayanamiBlue),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRoleSelector(String? selected, Function(String) onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _controller.roles.map((r) {
        final isSelected = r['rolId'] == selected;
        final name = r['nombre'].toString().toLowerCase();
        IconData roleIcon = Icons.badge_outlined;
        if (name.contains('admin')) roleIcon = Icons.admin_panel_settings_rounded;
        if (name.contains('cajer')) roleIcon = Icons.point_of_sale_rounded;
        if (name.contains('dueño')) roleIcon = Icons.stars_rounded;

        return GestureDetector(
          onTap: () => onSelect(r['rolId']),
          child: Container(
            width: 130,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.ayanamiBlue : AppTheme.ayanamiBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? AppTheme.ayanamiBlue : Colors.transparent, width: 2),
            ),
            child: Column(
              children: [
                Icon(roleIcon, color: isSelected ? Colors.white : AppTheme.ayanamiBlue, size: 28),
                const SizedBox(height: 8),
                Text(r['nombre'], 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: isSelected ? Colors.white : AppTheme.ayanamiBlue
                  ),
                textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dialogActions(BuildContext context, bool isEdit, TextEditingController n, TextEditingController rn, TextEditingController p, String? r, Map<String, dynamic>? u) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                if (n.text.isEmpty || (!isEdit && p.text.isEmpty) || r == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revisa los campos obligatorios')));
                  return;
                }
                // CLEAN PAYLOAD: Removing all keys that the server explicitly marked as 'not allowed'
                // The server expects 'username' and 'password' as required.
                // Based on previous logs, 'nombre' and 'rolId' are strictly FORBIDDEN in the POST body.
                final data = {
                  'username': n.text.trim(),
                  'password': p.text,
                  'roleId': r, // Assuming roleId is the correct allowed key for the role UUID
                };
                try {
                  if (isEdit) {
                    await _controller.updateUser(u!['usuarioId'], data);
                  } else {
                    await _controller.createUser(data);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Operación realizada con éxito!')));
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aviso: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ayanamiBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(isEdit ? 'GUARDAR USUARIO' : 'REGISTRAR EMPLEADO', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Desactivar miembro?'),
        content: Text('${user['nombre'] ?? user['username']} perderá el acceso al sistema inmediatamente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await _controller.deleteUser(user['usuarioId']);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }
}
