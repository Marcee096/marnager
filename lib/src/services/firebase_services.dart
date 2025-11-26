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

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference _getUserIngresosCollection() {
    final uid = currentUserId;
    if (uid == null) throw Exception('Usuario no autenticado');
    return _db.collection('usuarios').doc(uid).collection('ingresos');
  }

  CollectionReference _getUserGastosCollection() {
    final uid = currentUserId;
    if (uid == null) throw Exception('Usuario no autenticado');
    return _db.collection('usuarios').doc(uid).collection('gastos');
  }

  CollectionReference _getUserAhorrosCollection() {
    final uid = currentUserId;
    if (uid == null) throw Exception('Usuario no autenticado');
    return _db.collection('usuarios').doc(uid).collection('ahorros');
  }

  // ======================= INGRESOS =======================

  Future<List<Ingreso>> getAllIngresos() async {
    final snapshot = await _getUserIngresosCollection().get();
    return snapshot.docs
        .map((doc) =>
            Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Ingreso>> getIngresosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserIngresosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map((doc) =>
            Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Ingreso>> getIngresosByCategoria(String categoria) async {
    final snapshot = await _getUserIngresosCollection()
        .where('categoria', isEqualTo: categoria)
        .get();

    return snapshot.docs
        .map((doc) =>
            Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<Ingreso?> getIngresoById(String id) async {
    final doc = await _getUserIngresosCollection().doc(id).get();
    if (!doc.exists) return null;
    return Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<String> insertIngreso(Ingreso ingreso) async {
    final docRef = await _getUserIngresosCollection().add(ingreso.toMap());
    return docRef.id;
  }

  Future<void> updateIngreso(Ingreso ingreso) async {
    await _getUserIngresosCollection()
        .doc(ingreso.id)
        .update(ingreso.toMap());
  }

  Future<void> deleteIngreso(String id) async {
    await _getUserIngresosCollection().doc(id).delete();
  }

  Stream<List<Ingreso>> getIngresosStream() {
    return _getUserIngresosCollection().snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  Ingreso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList(),
        );
  }

  Future<double> calcularTotalIngresosMes(int month, int year) async {
    final ingresos = await getIngresosByMonth(month, year);

    return ingresos.fold<double>(
      0.0,
      (acum, ingreso) => acum + ingreso.monto,
    );
  }

  // ======================= GASTOS =======================

  Future<List<Gasto>> getAllGastos() async {
    final snapshot = await _getUserGastosCollection().get();
    return snapshot.docs
        .map(
            (doc) => Gasto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Gasto>> getGastosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserGastosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map(
            (doc) => Gasto.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<String> insertGasto(Gasto gasto) async {
    final docRef = await _getUserGastosCollection().add(gasto.toMap());
    return docRef.id;
  }

  Future<void> updateGasto(Gasto gasto) async {
    await _getUserGastosCollection()
        .doc(gasto.id)
        .update(gasto.toMap());
  }

  Future<void> deleteGasto(String id) async {
    await _getUserGastosCollection().doc(id).delete();
  }

  Future<double> calcularTotalGastosMes(int month, int year) async {
    final gastos = await getGastosByMonth(month, year);

    return gastos.fold<double>(
      0.0,
      (acum, gasto) => acum + gasto.monto,
    );
  }

  // ======================= AHORROS =======================

  Future<List<Ahorro>> getAllAhorros() async {
    final snapshot = await _getUserAhorrosCollection().get();
    return snapshot.docs
        .map(
            (doc) => Ahorro.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<Ahorro>> getAhorrosByMonth(int month, int year) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await _getUserAhorrosCollection()
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs
        .map(
            (doc) => Ahorro.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<String> insertAhorro(Ahorro ahorro) async {
    final docRef = await _getUserAhorrosCollection().add(ahorro.toMap());
    return docRef.id;
  }

  Future<void> updateAhorro(Ahorro ahorro) async {
    await _getUserAhorrosCollection()
        .doc(ahorro.id)
        .update(ahorro.toMap());
  }

  Future<void> deleteAhorro(String id) async {
    await _getUserAhorrosCollection().doc(id).delete();
  }

  Future<double> calcularTotalAhorrosMes(int month, int year) async {
    final ahorros = await getAhorrosByMonth(month, year);

    return ahorros.fold<double>(
      0.0,
      (acum, ahorro) => acum + ahorro.monto,
    );
  }

  // ======================= REPORTES =======================

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

  Future<Map<String, double>> getIngresosPorCategoria(
      int month, int year) async {
    final ingresos = await getIngresosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var ingreso in ingresos) {
      agrupado[ingreso.categoria] =
          (agrupado[ingreso.categoria] ?? 0.0) + ingreso.monto;
    }

    return agrupado;
  }

  Future<Map<String, double>> getGastosPorCategoria(
      int month, int year) async {
    final gastos = await getGastosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var gasto in gastos) {
      agrupado[gasto.categoria] =
          (agrupado[gasto.categoria] ?? 0.0) + gasto.monto;
    }

    return agrupado;
  }

  Future<Map<String, double>> getAhorrosPorCategoria(
      int month, int year) async {
    final ahorros = await getAhorrosByMonth(month, year);
    final Map<String, double> agrupado = {};

    for (var ahorro in ahorros) {
      agrupado[ahorro.categoria] =
          (agrupado[ahorro.categoria] ?? 0.0) + ahorro.monto;
    }

    return agrupado;
  }
}

