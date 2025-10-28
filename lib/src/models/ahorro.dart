import 'package:cloud_firestore/cloud_firestore.dart'; 

class Ahorro {
  final String id;
  final String categoria;
  final String subcategoria;
  final double monto;
  final DateTime fecha;

  Ahorro({
    required this.id,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
  });

  /// Convertir el ahorro a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'subcategoria': subcategoria,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  /// Crear una instancia de Ahorro desde un Map
  factory Ahorro.fromMap(Map<String, dynamic> map, String id) {
    return Ahorro(
      id: id,
      categoria: map['categoria'] ?? '',
      subcategoria: map['subcategoria'] ?? '',
      monto: (map['monto'] as num).toDouble(),
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Crear una copia del ahorro con algunos campos modificados
  Ahorro copyWith({
    String? id,
    String? categoria,
    String? subcategoria,
    double? monto,
    DateTime? fecha,
  }) {
    return Ahorro(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
    );
  }
}