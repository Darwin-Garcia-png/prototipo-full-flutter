import '../services/api_service.dart';

class Producto {
  final String productoId;
  final String? codigoBarras;
  final String nombre;
  final String? descripcion;
  final String? categoriaId;
  final String? presentacionId;
  final List<String>? proveedoresId;
  final int cantidadDisponible;
  final double? precioPorUnidad;

  Producto({
    required this.productoId,
    this.codigoBarras,
    required this.nombre,
    this.descripcion,
    this.categoriaId,
    this.presentacionId,
    this.proveedoresId,
    required this.cantidadDisponible,
    this.precioPorUnidad,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      productoId: (json['productoId'] ?? json['id'] ?? '').toString(),
      codigoBarras: (json['codigoBarras'] ?? json['codigo_barras'] ?? '').toString(),
      nombre: (json['nombre'] ?? json['name'] ?? 'Sin nombre').toString(),
      descripcion: (json['descripcion'] ?? json['description'])?.toString(),
      categoriaId: (json['categoriaId'] ?? json['categoria_id'])?.toString(),
      presentacionId: (json['presentacionId'] ?? json['presentacion_id'])?.toString(),
      proveedoresId: (json['proveedoresId'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      cantidadDisponible: int.tryParse((json['cantidadDisponible'] ?? json['stock'] ?? '0').toString()) ?? 0,
      precioPorUnidad: ApiService.nuclearScan(json),
    );
  }
}