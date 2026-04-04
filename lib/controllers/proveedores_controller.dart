import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProveedoresController extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://farmabook.onrender.com'));
  final _storage = const FlutterSecureStorage();

  List<dynamic> proveedores = [];
  bool isLoading = true;
  String? error;

  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController direccionCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  List<dynamic> get filteredProveedores {
    final query = searchCtrl.text.toLowerCase();
    if (query.isEmpty) return proveedores;
    return proveedores.where((p) {
      final name = (p['nombre'] ?? '').toString().toLowerCase();
      final mail = (p['email'] ?? '').toString().toLowerCase();
      return name.contains(query) || mail.contains(query);
    }).toList();
  }

  Future<void> init() async {
    searchCtrl.addListener(notifyListeners);
    await cargarProveedores();
  }

  Future<void> cargarProveedores() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'jwt_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final res = await _dio.get('/inventory/suppliers');
      proveedores = res.data['data'] ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> agregarProveedor() async {
    if (nombreCtrl.text.trim().isEmpty) return false;

    try {
      final token = await _storage.read(key: 'jwt_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      await _dio.post('/inventory/suppliers', data: {
        'nombre': nombreCtrl.text.trim(),
        'direccion': direccionCtrl.text.trim(),
        'telefono': telefonoCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
      });

      limpiarForm();
      await cargarProveedores();
      return true;
    } catch (e) {
      debugPrint("Error adding supplier: $e");
      return false;
    }
  }

  Future<bool> actualizarProveedor(String id, Map<String, dynamic> data) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.put('/inventory/suppliers/$id', data: data);
      await cargarProveedores();
      return true;
    } catch (e) {
      debugPrint("Error updating supplier: $e");
      return false;
    }
  }

  Future<bool> eliminarProveedor(String id) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      await _dio.delete('/inventory/suppliers/$id');
      await cargarProveedores();
      return true;
    } catch (e) {
      debugPrint("Error deleting supplier: $e");
      return false;
    }
  }

  void limpiarForm() {
    nombreCtrl.clear();
    direccionCtrl.clear();
    telefonoCtrl.clear();
    emailCtrl.clear();
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    direccionCtrl.dispose();
    telefonoCtrl.dispose();
    emailCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }
}
