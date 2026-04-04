import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class LotesController extends ChangeNotifier {
  final _dio = ApiService.dio;

  List<Map<String, dynamic>> allBatches = [];
  bool isLoading = false;
  bool sortByExpiry = false; // Near-expiry filter toggle
  bool sortByLowStock = false; // Low stock filter toggle
  String? error;
  String externalSearchQuery = '';

  void setExternalSearch(String query) {
    externalSearchQuery = query;
    notifyListeners();
  }

  void clearExternalSearch() {
    externalSearchQuery = '';
    notifyListeners();
  }

  Future<void> init() async {
    await fetchAllBatches();
  }

  Future<void> fetchAllBatches() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await ApiService.setAuthHeader();

      final response = await _dio.get('/inventory/products?page=1&limit=1000');
      final products = response.data['data'] as List? ?? [];
      List<Map<String, dynamic>> tempBatches = [];
      const int chunkSize = 20;

      for (int i = 0; i < products.length; i += chunkSize) {
        final end = (i + chunkSize < products.length) ? i + chunkSize : products.length;
        final chunkProducts = products.sublist(i, end);

        final chunkResults = await Future.wait(chunkProducts.map((p) async {
          final pId = p['productoId']?.toString();
          if (pId == null) return [];
          try {
            final bRes = await _dio.get('/inventory/products/$pId/batches');
            final bList = bRes.data['data'] as List? ?? [];
            return bList.map((b) => {
              ...Map<String, dynamic>.from(b),
              'productoNombre': p['nombre'],
              'productoCodigo': p['codigoBarras'],
              'originalProduct': p,
            }).toList();
          } catch (_) {
            return [];
          }
        }));

        for (var r in chunkResults) {
          tempBatches.addAll(r as List<Map<String, dynamic>>);
        }
      }

      allBatches = tempBatches;
    } catch (e) {
      error = "Error al cargar lotes: $e";
      debugPrint(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleExpiryFilter() {
    sortByExpiry = !sortByExpiry;
    sortByLowStock = false; // Disable other filter
    notifyListeners();
  }

  void toggleLowStockFilter() {
    sortByLowStock = !sortByLowStock;
    sortByExpiry = false; // Disable other filter
    notifyListeners();
  }

  Future<Response> createBatch(Map<String, dynamic> data) async {
    await ApiService.setAuthHeader();
    try {
      final res = await _dio.post('/inventory/batches', data: data);
      await fetchAllBatches();
      return res;
    } catch (e) {
      debugPrint("Error creating batch: $e");
      rethrow;
    }
  }

  Future<Response> updateBatch(String id, Map<String, dynamic> data) async {
    await ApiService.setAuthHeader();
    try {
      final res = await _dio.patch('/inventory/batches/$id', data: data);
      await fetchAllBatches();
      return res;
    } catch (e) {
      debugPrint("Error updating batch: $e");
      rethrow;
    }
  }

  Future<void> deleteBatch(String id) async {
    await ApiService.setAuthHeader();
    try {
      await _dio.delete('/inventory/batches/$id');
      await fetchAllBatches();
    } catch (e) {
      debugPrint("Error deleting batch: $e");
      rethrow;
    }
  }
}
