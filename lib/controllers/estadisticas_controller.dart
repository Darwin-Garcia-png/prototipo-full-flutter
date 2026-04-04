import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class EstadisticasController extends ChangeNotifier {
  // Use shared Dio from ApiService to ensure JWT and baseUrl are correct
  final Dio _dio = ApiService.dio;

  bool isLoading = false;
  String? error;

  // KPIs
  double ingresosHoy = 0;
  double ingresosMes = 0;
  int ventasHoy = 0;
  int ventasMes = 0;
  double egresosMes = 0;
  double balanceMes = 0;

  // Rankings
  List<dynamic> topProductosHoy = [];
  List<dynamic> topProductosMes = [];
  List<dynamic> topProductosGlobal = [];

  // Chart Data
  List<Map<String, dynamic>> dailyTrend = [];
  Map<String, double> categoryData = {};

  Future<void> init() async {
    await cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Ensure JWT is in headers via the shared ApiService
      await ApiService.setAuthHeader();

      // Parallel fetch for ALL analytics endpoints (KPIs + Top Products)
      final results = await Future.wait([
        _dio.get('/analytics/revenues/today'),
        _dio.get('/analytics/revenues/month'),
        _dio.get('/analytics/sales/today'),
        _dio.get('/analytics/sales/month'),
        _dio.get('/analytics/expenses'),
        _dio.get('/analytics/balance'),
        _dio.get('/analytics/products/top', queryParameters: {'limit': 5, 'period': 'today'}),
        _dio.get('/analytics/products/top', queryParameters: {'limit': 5, 'period': 'month'}),
        _dio.get('/analytics/products/top', queryParameters: {'limit': 5, 'period': 'all'}),
      ]);

      // Extract data safely
      ingresosHoy = double.tryParse(results[0].data['data']?['ingresosDiarios']?.toString() ?? '0') ?? 0;
      ingresosMes = double.tryParse(results[1].data['data']?['ingresosMensuales']?.toString() ?? '0') ?? 0;
      ventasHoy = (results[2].data['data']?['ventasDelDia'] as num? ?? 0).toInt();
      ventasMes = (results[3].data['data']?['ventasMensuales'] as num? ?? 0).toInt();
      egresosMes = double.tryParse(results[4].data['data']?['egresosMensuales']?.toString() ?? '0') ?? 0;
      balanceMes = double.tryParse(results[5].data['data']?['balanceMensual']?.toString() ?? '0') ?? 0;

      topProductosHoy = results[6].data['data'] as List? ?? [];
      topProductosMes = results[7].data['data'] as List? ?? [];
      topProductosGlobal = results[8].data['data'] as List? ?? [];

      // Process advanced analytics (charts)
      await _processAdvancedAnalytics();
    } catch (e) {
      debugPrint("Error loading stats: $e");
      error = "No se pudieron cargar las estadísticas completamente.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _processAdvancedAnalytics() async {
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final lastDay = DateTime(now.year, now.month + 1, 0);
      final formatter = DateFormat('yyyy-MM-dd');

      // Fetch sales with date filter - IMPORTANT: Backend requires BOTH page and limit
      final salesRes = await _dio.get('/sales', queryParameters: {
        'fechaInicio': formatter.format(firstDay),
        'fechaFin': formatter.format(lastDay),
        'page': 1,
        'limit': 2000, // Large enough to get a month of data
      });
      final List salesList = salesRes.data['data'] ?? [];
      debugPrint("Advanced Stats: Fetched ${salesList.length} sales");

      // Fetch products and categories - IMPORTANT: Backend requires BOTH page and limit
      final prodsRes = await _dio.get('/inventory/products', queryParameters: {'page': 1, 'limit': 2000});
      final catsRes = await _dio.get('/inventory/categories', queryParameters: {'page': 1, 'limit': 500});
      
      final Map<String, String> prodToCatId = {};
      final Map<String, String> catIdToName = {};

      for (var p in (prodsRes.data['data'] ?? [])) {
        final pid = (p['productoId'] ?? p['id'] ?? '').toString();
        final cid = (p['categoriaId'] ?? p['idCategoria'] ?? '').toString();
        if (pid.isNotEmpty) prodToCatId[pid] = cid;
      }

      for (var c in (catsRes.data['data'] ?? [])) {
        final cid = (c['categoriaId'] ?? c['id'] ?? '').toString();
        final name = (c['nombre'] ?? 'Sin Categoria').toString();
        if (cid.isNotEmpty) catIdToName[cid] = name;
      }

      final Map<int, double> trendMap = {};
      final Map<String, double> catMap = {};

      for (var s in salesList) {
        try {
          final dateData = s['fechaDeVenta'] ?? s['fecha'];
          if (dateData == null) continue;
          
          DateTime? date;
          if (dateData is DateTime) {
            date = dateData;
          } else {
            // Flexible parsing (handle SQL space vs ISO T)
            String dateStr = dateData.toString().replaceAll(' ', 'T');
            date = DateTime.tryParse(dateStr);
          }
          
          if (date == null) continue;
          if (date.month != now.month) continue; // Safety check

          final day = date.day;
          final total = double.tryParse(s['total']?.toString() ?? '0') ?? 0;
          trendMap[day] = (trendMap[day] ?? 0) + total;

          final items = s['productosVendidos'] as List? ?? [];
          for (var item in items) {
             final pid = (item['productoId'] ?? item['id'] ?? '').toString();
             final subTotal = double.tryParse(item['subTotal']?.toString() ?? '0') ?? 0;
             final cid = prodToCatId[pid];
             if (cid != null) {
               final cName = catIdToName[cid] ?? 'Otros';
               catMap[cName] = (catMap[cName] ?? 0) + subTotal;
             }
          }
        } catch (itemError) {
          debugPrint("Error processing individual sale: $itemError");
        }
      }

      dailyTrend = List.generate(31, (index) {
        final day = index + 1;
        return {'day': day, 'total': trendMap[day] ?? 0.0};
      });

      categoryData = catMap;
      debugPrint("Advanced Stats: Trend map has ${trendMap.length} points, Categories have ${catMap.length} segments");

    } catch (e) {
      debugPrint("Fatal error in advanced analytics: $e");
      // Don't show total error if only charts fail
      error = "Error al procesar gráficas: $e"; // Keep this error for advanced analytics
    }
  }
}
