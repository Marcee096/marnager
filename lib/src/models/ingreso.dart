import 'package:cloud_firestore/cloud_firestore.dart'; 

class Ingreso {
  final String id;
  final String categoria;
  final String subcategoria;
  final double monto;
  final DateTime fecha;
  final String? detalle; // Campo opcional para detalles

  Ingreso({
    required this.id,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
    this.detalle,
  });

  /// Convertir el ingreso a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'subcategoria': subcategoria,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      if (detalle != null && detalle!.isNotEmpty) 'detalle': detalle,
    };
  }

  /// Crear una instancia de Ingreso desde un Map
  factory Ingreso.fromMap(Map<String, dynamic> map, String id) {
    // Firebase almacena números como 'num', que puede ser int o double
    final montoValue = map['monto'];
    final double montoDouble;
    
    if (montoValue is int) {
      montoDouble = montoValue.toDouble();
    } else if (montoValue is double) {
      montoDouble = montoValue;
    } else {
      montoDouble = 0.0;
    }

    return Ingreso(
      id: id,
      categoria: map['categoria'] as String? ?? '',
      subcategoria: map['subcategoria'] as String? ?? '',
      monto: montoDouble,
      fecha: (map['fecha'] as Timestamp).toDate(),
      detalle: map['detalle'] as String?, 
    );
  }

  /// Crear una copia del ingreso con algunos campos modificados
  Ingreso copyWith({
    String? id,
    String? categoria,
    String? subcategoria,
    double? monto,
    DateTime? fecha,
    String? detalle,
  }) {
    return Ingreso(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      detalle: detalle ?? this.detalle,
    );
  }
}