import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/config_controller.dart';
import '../providers/theme_provider.dart';
import '../controllers/dashboard_controller.dart';
import '../theme/app_theme.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final ConfigController _controller = ConfigController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.cargarPreferencias();
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

  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _controller.pharmacyName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Nombre de Farmacia'),
        content: TextField(
          controller: ctrl,
          decoration:
              const InputDecoration(hintText: 'Ej. FarmaSalud Principal'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ayanamiBlue,
                foregroundColor: Colors.white),
            onPressed: () {
              _controller.cambiarNombreFarmacia(ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _handleThemeToggle(bool isDark) {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDark);
    _controller.cambiarTema(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final dashController = Provider.of<DashboardController>(context, listen: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.titleLarge?.color),
          tooltip: 'Volver al Dashboard',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ajustes del Sistema',
            style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 32),

                      // ADMINISTRACIÓN DE PERSONAL
                      _buildSettingsGroup(
                        title: 'Gestión de Equipo',
                        children: [
                          ListTile(
                            leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.people_alt_rounded, color: Colors.orange, size: 24)),
                            title: const Text('Personal y Roles', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Gestiona usuarios, permisos y accesos al sistema'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                                dashController.onItemTapped(10); // UsuariosScreen
                                Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      _buildSettingsGroup(
                        title: 'Experiencia y Preferencias',
                        children: [
                          _buildSwitchTile(
                              'Modo Oscuro (Dark Mode)',
                              'Adaptación visual premium estilo consola Rei (Black Plugsuit)',
                              Icons.dark_mode_rounded,
                              isDark,
                              _handleThemeToggle),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: AppTheme.ayanamiBlue.withOpacity(0.15),
            child: const Icon(Icons.storefront_rounded,
                size: 46, color: AppTheme.ayanamiBlue),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_controller.pharmacyName,
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color)),
                    const SizedBox(width: 8),
                    IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 22, color: Colors.grey),
                        tooltip: 'Cambiar Nombre',
                        onPressed: _showEditNameDialog),
                  ],
                ),
                Text('Administrador de Sistema · ${_controller.userEmail}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.6),
                        fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.ayanamiBlue.withOpacity(0.8),
                letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 24,
                      color: Theme.of(context).dividerColor.withOpacity(0.5)),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon,
      bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppTheme.ayanamiBlue.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.ayanamiBlue, size: 24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              style: TextStyle(
                color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6))),
        ),
        value: value,
        activeColor: AppTheme.ayanamiBlue,
        onChanged: onChanged,
      ),
    );
  }
}
