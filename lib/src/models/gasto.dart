import 'package:cloud_firestore/cloud_firestore.dart'; 

class Gasto {
  final String id;
  final String categoria;
  final String subcategoria;
  final double monto;
  final DateTime fecha;

  Gasto({
    required this.id,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
  });

  /// Convertir el gasto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'subcategoria': subcategoria,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  /// Crear una instancia de Gasto desde un Map
  factory Gasto.fromMap(Map<String, dynamic> map, String id) {
    return Gasto(
      id: id,
      categoria: map['categoria'] ?? '',
      subcategoria: map['subcategoria'] ?? '',
      monto: (map['monto'] as num).toDouble(),
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Crear una copia del gasto con algunos campos modificados
  Gasto copyWith({
    String? id,
    String? categoria,
    String? subcategoria,
    double? monto,
    DateTime? fecha,
  }) {
    return Gasto(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
    );
  }
}