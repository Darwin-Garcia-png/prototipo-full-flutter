import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AlertasController extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://farmabook.onrender.com'));
  final _storage = const FlutterSecureStorage();

  List<dynamic> alertsStock = [];
  List<dynamic> alertsVencimiento = [];
  List<dynamic> notifications = [];
  bool isLoading = true;
  String? error;

  Future<void> init() async {
    await cargarAlertas();
  }

  Future<void> cargarAlertas() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'jwt_token');
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // 1. Stock (Backend endpoint)
      final stockRes = await _dio.get('/inventory/alerts/stock');
      alertsStock = stockRes.data['data'] ?? [];

      // 2. Expiry (Backend endpoint)
      final vencRes = await _dio.get('/inventory/alerts/expiry');
      alertsVencimiento = vencRes.data['data'] ?? [];

      // 3. Fallback: Local Filtering to ensure nothing is missed
      final allProdsRes = await _dio.get('/inventory/products?limit=1000');
      final allProds = allProdsRes.data['data'] as List? ?? [];
      
      // Merge products with stock <= 5 if not already in alertsStock
      final criticalLocal = allProds.where((p) {
        final stock = p['cantidadDisponible'] as num? ?? 0;
        return stock <= 5;
      }).toList();

      for (var p in criticalLocal) {
        if (!alertsStock.any((a) => a['productoId'] == p['productoId'])) {
          alertsStock.add(p);
        }
      }

      // Notificaciones Generales
      final notifRes = await _dio.get('/notifications');
      notifications = notifRes.data['data'] ?? [];

    } catch (e) {
      debugPrint("Error loading alerts: $e");
      error = "Error al conectar con el servidor";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
