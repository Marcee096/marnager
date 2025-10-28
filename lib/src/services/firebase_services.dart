import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ahorro.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';

class FirebaseServices {
  static final FirebaseServices instance = FirebaseServices._init();

  FirebaseServices._init();

  final String collectionGastos = 'gastos';
  final String collectionAhorros = 'ahorros';
  final String collectionIngresos = 'ingresos';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== MÉTODOS PARA INGRESOS ==========

  /// Obtener todos los ingresos
  Future<List<Ingreso>> getAllIngresos() async {
    final snapshot = await _db.collection(collectionIngresos).get();
    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener ingresos por mes y año
  Future<List<Ingreso>> getIngresosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection(collectionIngresos)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener ingresos por categoría
  Future<List<Ingreso>> getIngresosByCategoria(String categoria) async {
    final snapshot = await _db
        .collection(collectionIngresos)
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener un ingreso por ID
  Future<Ingreso?> getIngresoById(String id) async {
    final doc = await _db.collection(collectionIngresos).doc(id).get();
    if (!doc.exists) return null;
    return Ingreso.fromMap(doc.data()!, doc.id);
  }

  /// Insertar un nuevo ingreso
  Future<String> insertIngreso(Ingreso ingreso) async {
    final docRef =
        await _db.collection(collectionIngresos).add(ingreso.toMap());
    return docRef.id;
  }

  /// Actualizar un ingreso existente
  Future<void> updateIngreso(Ingreso ingreso) async {
    await _db
        .collection(collectionIngresos)
        .doc(ingreso.id)
        .update(ingreso.toMap());
  }

  /// Eliminar un ingreso por ID
  Future<void> deleteIngreso(String id) async {
    await _db.collection(collectionIngresos).doc(id).delete();
  }

  /// Obtener stream de ingresos en tiempo real
  Stream<List<Ingreso>> getIngresosStream() {
    return _db.collection(collectionIngresos).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Ingreso.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Calcular total de ingresos por mes
  Future<double> calcularTotalIngresosMes(int month, int year) async {
  final ingresos = await getIngresosByMonth(month, year);

  return ingresos.fold<double>(
    0.0,
    (sum, ingreso) => sum + ingreso.monto,
  );
}


  // ========== MÉTODOS PARA GASTOS ==========

  /// Obtener todos los gastos
  Future<List<Gasto>> getAllGastos() async {
    final snapshot = await _db.collection(collectionGastos).get();
    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener gastos por mes y año
  Future<List<Gasto>> getGastosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection(collectionGastos)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener gastos por categoría
  Future<List<Gasto>> getGastosByCategoria(String categoria) async {
    final snapshot = await _db
        .collection(collectionGastos)
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener un gasto por ID
  Future<Gasto?> getGastoById(String id) async {
    final doc = await _db.collection(collectionGastos).doc(id).get();
    if (!doc.exists) return null;
    return Gasto.fromMap(doc.data()!, doc.id);
  }

  /// Insertar un nuevo gasto
  Future<String> insertGasto(Gasto gasto) async {
    final docRef = await _db.collection(collectionGastos).add(gasto.toMap());
    return docRef.id;
  }

  /// Actualizar un gasto existente
  Future<void> updateGasto(Gasto gasto) async {
    await _db
        .collection(collectionGastos)
        .doc(gasto.id)
        .update(gasto.toMap());
  }

  /// Eliminar un gasto por ID
  Future<void> deleteGasto(String id) async {
    await _db.collection(collectionGastos).doc(id).delete();
  }

  /// Obtener stream de gastos en tiempo real
  Stream<List<Gasto>> getGastosStream() {
    return _db.collection(collectionGastos).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Gasto.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Calcular total de gastos por mes
  Future<double> calcularTotalGastosMes(int month, int year) async {
  final gastos = await getGastosByMonth(month, year);

  
  return gastos.fold<double>(
    0.0,
    (sum, gasto) => sum + gasto.monto,
  );
}


  // ========== MÉTODOS PARA AHORROS ==========

  /// Obtener todos los ahorros
  Future<List<Ahorro>> getAllAhorros() async {
    final snapshot = await _db.collection(collectionAhorros).get();
    return snapshot.docs
        .map((doc) => Ahorro.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener ahorros por mes y año
  Future<List<Ahorro>> getAhorrosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _db
        .collection(collectionAhorros)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Ahorro.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener ahorros por categoría
  Future<List<Ahorro>> getAhorrosByCategoria(String categoria) async {
    final snapshot = await _db
        .collection(collectionAhorros)
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) => Ahorro.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtener un ahorro por ID
  Future<Ahorro?> getAhorroById(String id) async {
    final doc = await _db.collection(collectionAhorros).doc(id).get();
    if (!doc.exists) return null;
    return Ahorro.fromMap(doc.data()!, doc.id);
  }

  /// Insertar un nuevo ahorro
  Future<String> insertAhorro(Ahorro ahorro) async {
    final docRef = await _db.collection(collectionAhorros).add(ahorro.toMap());
    return docRef.id;
  }

  /// Actualizar un ahorro existente
  Future<void> updateAhorro(Ahorro ahorro) async {
    await _db
        .collection(collectionAhorros)
        .doc(ahorro.id)
        .update(ahorro.toMap());
  }

  /// Eliminar un ahorro por ID
  Future<void> deleteAhorro(String id) async {
    await _db.collection(collectionAhorros).doc(id).delete();
  }

  /// Obtener stream de ahorros en tiempo real
  Stream<List<Ahorro>> getAhorrosStream() {
    return _db.collection(collectionAhorros).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Ahorro.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Calcular total de ahorros por mes
  Future<double> calcularTotalAhorrosMes(int month, int year) async {
  final ahorros = await getAhorrosByMonth(month, year);

  return ahorros.fold<double>(
    0.0,
    (sum, ahorro) => sum + ahorro.monto,
  );
}


  // ========== MÉTODOS COMBINADOS/REPORTES ==========

  /// Obtener resumen del mes (ingresos, gastos, ahorros)
  Future<Map<String, double>> getResumenMes(int month, int year) async {
    final ingresos = await calcularTotalIngresosMes(month, year);
    final gastos = await calcularTotalGastosMes(month, year);
    final ahorros = await calcularTotalAhorrosMes(month, year);

    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'ahorros': ahorros,
    };
  }

  /// Obtener datos agrupados por categoría para ingresos
  Future<Map<String, double>> getIngresosPorCategoria(
      int month, int year) async {
    final ingresos = await getIngresosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var ingreso in ingresos) {
      final valorActual = agrupado[ingreso.categoria] ?? 0.0;
      agrupado[ingreso.categoria] = valorActual + ingreso.monto;
    }

    return agrupado;
  }

  /// Obtener datos agrupados por categoría para gastos
  Future<Map<String, double>> getGastosPorCategoria(
      int month, int year) async {
    final gastos = await getGastosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var gasto in gastos) {
      final valorActual = agrupado[gasto.categoria] ?? 0.0;
      agrupado[gasto.categoria] = valorActual + gasto.monto;
    }

    return agrupado;
  }

  /// Obtener datos agrupados por categoría para ahorros
  Future<Map<String, double>> getAhorrosPorCategoria(
      int month, int year) async {
    final ahorros = await getAhorrosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var ahorro in ahorros) {
      final valorActual = agrupado[ahorro.categoria] ?? 0.0;
      agrupado[ahorro.categoria] = valorActual + ahorro.monto;
    }

    return agrupado;
  }

  /// Obtener subcategorías con montos para una categoría específica de ingresos
  Future<Map<String, double>> getSubcategoriasIngresos(
    String categoria,
    int month,
    int year,
  ) async {
    final ingresos = await getIngresosByMonth(month, year);
    final Map<String, double> subcategorias = {};

    for (var ingreso in ingresos) {
      if (ingreso.categoria == categoria) {
        final valorActual = subcategorias[ingreso.subcategoria] ?? 0.0;
        subcategorias[ingreso.subcategoria] = valorActual + ingreso.monto;
      }
    }

    return subcategorias;
  }

  /// Obtener subcategorías con montos para una categoría específica de gastos
  Future<Map<String, double>> getSubcategoriasGastos(
    String categoria,
    int month,
    int year,
  ) async {
    final gastos = await getGastosByMonth(month, year);
    final Map<String, double> subcategorias = {};

    for (var gasto in gastos) {
      if (gasto.categoria == categoria) {
        final valorActual = subcategorias[gasto.subcategoria] ?? 0.0;
        subcategorias[gasto.subcategoria] = valorActual + gasto.monto;
      }
    }

    return subcategorias;
  }

  /// Obtener subcategorías con montos para una categoría específica de ahorros
  Future<Map<String, double>> getSubcategoriasAhorros(
    String categoria,
    int month,
    int year,
  ) async {
    final ahorros = await getAhorrosByMonth(month, year);
    final Map<String, double> subcategorias = {};

    for (var ahorro in ahorros) {
      if (ahorro.categoria == categoria) {
        final valorActual = subcategorias[ahorro.subcategoria] ?? 0.0;
        subcategorias[ahorro.subcategoria] = valorActual + ahorro.monto;
      }
    }

    return subcategorias;
  }
}


