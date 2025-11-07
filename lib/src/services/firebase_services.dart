import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ahorro.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';

class FirebaseServices {
  static final FirebaseServices instance = FirebaseServices._init();

  FirebaseServices._init();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener el UID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  // Obtener referencia a la subcolección de ingresos del usuario actual
  CollectionReference _getUserIngresosCollection() {
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _db.collection('usuarios').doc(currentUserId).collection('ingresos');
  }

  // Obtener referencia a la subcolección de gastos del usuario actual
  CollectionReference _getUserGastosCollection() {
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _db.collection('usuarios').doc(currentUserId).collection('gastos');
  }

  // Obtener referencia a la subcolección de ahorros del usuario actual
  CollectionReference _getUserAhorrosCollection() {
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _db.collection('usuarios').doc(currentUserId).collection('ahorros');
  }

  // ========== MÉTODOS PARA INGRESOS ==========

  /// Obtener todos los ingresos del usuario actual
  Future<List<Ingreso>> getAllIngresos() async {
    final snapshot = await _getUserIngresosCollection().get();
    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Obtener ingresos por mes y año del usuario actual
  Future<List<Ingreso>> getIngresosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserIngresosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Obtener ingresos por categoría del usuario actual
  Future<List<Ingreso>> getIngresosByCategoria(String categoria) async {
    final snapshot = await _getUserIngresosCollection()
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) => Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Obtener un ingreso por ID del usuario actual
  Future<Ingreso?> getIngresoById(String id) async {
    final doc = await _getUserIngresosCollection().doc(id).get();
    if (!doc.exists) return null;
    return Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Insertar un nuevo ingreso para el usuario actual
  Future<String> insertIngreso(Ingreso ingreso) async {
    final docRef = await _getUserIngresosCollection().add(ingreso.toMap());
    return docRef.id;
  }

  /// Actualizar un ingreso existente del usuario actual
  Future<void> updateIngreso(Ingreso ingreso) async {
    await _getUserIngresosCollection()
        .doc(ingreso.id)
        .update(ingreso.toMap());
  }

  /// Eliminar un ingreso por ID del usuario actual
  Future<void> deleteIngreso(String id) async {
    await _getUserIngresosCollection().doc(id).delete();
  }

  /// Obtener stream de ingresos en tiempo real del usuario actual
  Stream<List<Ingreso>> getIngresosStream() {
    return _getUserIngresosCollection().snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  /// Calcular total de ingresos por mes del usuario actual
  Future<double> calcularTotalIngresosMes(int month, int year) async {
    final ingresos = await getIngresosByMonth(month, year);

    return ingresos.fold<double>(
      0.0,
      (sum, ingreso) => sum + ingreso.monto,
    );
  }

  // ========== MÉTODOS PARA GASTOS ==========

  /// Obtener todos los gastos del usuario actual
  Future<List<Gasto>> getAllGastos() async {
    final snapshot = await _getUserGastosCollection().get();
    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Obtener gastos por mes y año del usuario actual
  Future<List<Gasto>> getGastosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserGastosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Gasto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Insertar un nuevo gasto para el usuario actual
  Future<String> insertGasto(Gasto gasto) async {
    final docRef = await _getUserGastosCollection().add(gasto.toMap());
    return docRef.id;
  }

  /// Calcular total de gastos por mes del usuario actual
  Future<double> calcularTotalGastosMes(int month, int year) async {
    final gastos = await getGastosByMonth(month, year);

    return gastos.fold<double>(
      0.0,
      (sum, gasto) => sum + gasto.monto,
    );
  }

  // ========== MÉTODOS PARA AHORROS ==========

  /// Obtener todos los ahorros del usuario actual
  Future<List<Ahorro>> getAllAhorros() async {
    final snapshot = await _getUserAhorrosCollection().get();
    return snapshot.docs
        .map((doc) => Ahorro.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Obtener ahorros por mes y año del usuario actual
  Future<List<Ahorro>> getAhorrosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserAhorrosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) => Ahorro.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// Insertar un nuevo ahorro para el usuario actual
  Future<String> insertAhorro(Ahorro ahorro) async {
    final docRef = await _getUserAhorrosCollection().add(ahorro.toMap());
    return docRef.id;
  }

  /// Calcular total de ahorros por mes del usuario actual
  Future<double> calcularTotalAhorrosMes(int month, int year) async {
    final ahorros = await getAhorrosByMonth(month, year);

    return ahorros.fold<double>(
      0.0,
      (sum, ahorro) => sum + ahorro.monto,
    );
  }

  // ========== MÉTODOS COMBINADOS/REPORTES ==========

  /// Obtener resumen del mes (ingresos, gastos, ahorros) del usuario actual
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

  /// Obtener datos agrupados por categoría para ingresos del usuario actual
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

  /// Obtener datos agrupados por categoría para gastos del usuario actual
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

  /// Obtener datos agrupados por categoría para ahorros del usuario actual
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


