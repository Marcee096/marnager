import 'package:cloud_firestore/cloud_firestore.dart'; 

class Gasto {
  final String id;
  final String categoria;
  final String subcategoria;
  final double monto;
  final DateTime fecha;
  final String? detalle; // Campo opcional para detalles
  final String? cuenta; // Campo opcional para cuenta de pago

  Gasto({
    required this.id,
    required this.categoria,
    required this.subcategoria,
    required this.monto,
    required this.fecha,
    this.detalle,
    this.cuenta,
  });

  /// Convertir el gasto a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria,
      'subcategoria': subcategoria,
      'monto': monto,
      'fecha': Timestamp.fromDate(fecha),
      if (detalle != null && detalle!.isNotEmpty) 'detalle': detalle,
      if (cuenta != null && cuenta!.isNotEmpty) 'cuenta': cuenta,
    };
  }

  /// Crear una instancia de Gasto desde un Map
  factory Gasto.fromMap(Map<String, dynamic> map, String id) {
    final montoValue = map['monto'];
    final double montoDouble;
    
    if (montoValue is int) {
      montoDouble = montoValue.toDouble();
    } else if (montoValue is double) {
      montoDouble = montoValue;
    } else {
      montoDouble = 0.0;
    }

    return Gasto(
      id: id,
      categoria: map['categoria'] as String? ?? '',
      subcategoria: map['subcategoria'] as String? ?? '',
      monto: montoDouble,
      fecha: (map['fecha'] as Timestamp).toDate(),
      detalle: map['detalle'] as String?,
      cuenta: map['cuenta'] as String?,
    );
  }

  /// Crear una copia del gasto con algunos campos modificados
  Gasto copyWith({
    String? id,
    String? categoria,
    String? subcategoria,
    double? monto,
    DateTime? fecha,
    String? detalle,
    String? cuenta,
  }) {
    return Gasto(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      subcategoria: subcategoria ?? this.subcategoria,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      detalle: detalle ?? this.detalle,
      cuenta: cuenta ?? this.cuenta,
    );
  }
}