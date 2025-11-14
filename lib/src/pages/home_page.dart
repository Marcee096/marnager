import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart';
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/ingresos_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/firebase_services.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../models/ahorro.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indexInicial = 2; // Inicio como selección inicial
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;
  
  // Variables para el carrusel de gráficos
  int _graficoActual = 0; // 0: Ingresos, 1: Gastos, 2: Ahorros
  final List<String> _tiposGrafico = ['Ingresos', 'Gastos', 'Ahorros'];

  // Instancia del servicio de Firebase
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Datos de Firebase
  List<Ingreso> _ingresosList = [];
  List<Gasto> _gastosList = [];
  List<Ahorro> _ahorrosList = [];
  bool _isLoading = true;

  // Mapas de íconos
  final Map<String, IconData> _iconosCategorias = {};

  final List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await initializeDateFormatting('es_ES', null);
    _cargarDatosFirebase();
  }

  // Cargar datos desde Firebase
  Future<void> _cargarDatosFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar datos del mes seleccionado
      final ingresos = await _firebaseServices.getIngresosByMonth(_mesSeleccionado, _anioSeleccionado);
      final gastos = await _firebaseServices.getGastosByMonth(_mesSeleccionado, _anioSeleccionado);
      final ahorros = await _firebaseServices.getAhorrosByMonth(_mesSeleccionado, _anioSeleccionado);

      // Asegurar que siempre sean listas válidas
      final ingresosValidos = ingresos ;
      final gastosValidos = gastos ;
      final ahorrosValidos = ahorros ;

      // Asignar íconos
      for (var ingreso in ingresosValidos) {
        if (!_iconosCategorias.containsKey(ingreso.categoria)) {
          _iconosCategorias[ingreso.categoria] = _asignarIcono(ingreso.categoria, 'ingreso');
        }
      }

      for (var gasto in gastosValidos) {
        if (!_iconosCategorias.containsKey(gasto.categoria)) {
          _iconosCategorias[gasto.categoria] = _asignarIcono(gasto.categoria, 'gasto');
        }
      }

      for (var ahorro in ahorrosValidos) {
        if (!_iconosCategorias.containsKey(ahorro.categoria)) {
          _iconosCategorias[ahorro.categoria] = _asignarIcono(ahorro.categoria, 'ahorro');
        }
      }

      setState(() {
        _ingresosList = ingresosValidos;
        _gastosList = gastosValidos;
        _ahorrosList = ahorrosValidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ingresosList = [];
        _gastosList = [];
        _ahorrosList = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  // Asignar icono según la categoría y tipo
  IconData _asignarIcono(String categoria, String tipo) {
    final categoriaLower = categoria.toLowerCase();
    
    if (tipo == 'ingreso') {
      if (categoriaLower.contains('freelance') || categoriaLower.contains('trabajo')) {
        return Icons.computer;
      } else if (categoriaLower.contains('retail') || categoriaLower.contains('tienda')) {
        return Icons.store;
      } else if (categoriaLower.contains('educación') || categoriaLower.contains('beca')) {
        return Icons.school;
      } else if (categoriaLower.contains('evento')) {
        return Icons.event;
      } else if (categoriaLower.contains('joya')) {
        return Icons.diamond;
      } else if (categoriaLower.contains('consulta')) {
        return Icons.support_agent;
      } else if (categoriaLower.contains('inversión')) {
        return Icons.trending_up;
      } else {
        return Icons.attach_money;
      }
    } else if (tipo == 'gasto') {
      if (categoriaLower.contains('personal') || categoriaLower.contains('compras')) {
        return Icons.shopping_bag;
      } else if (categoriaLower.contains('comida') || categoriaLower.contains('alimentación')) {
        return Icons.restaurant;
      } else if (categoriaLower.contains('transporte')) {
        return Icons.directions_car;
      } else if (categoriaLower.contains('salud')) {
        return Icons.local_hospital;
      } else if (categoriaLower.contains('educación')) {
        return Icons.school;
      } else if (categoriaLower.contains('entretenimiento')) {
        return Icons.movie;
      } else if (categoriaLower.contains('servicio')) {
        return Icons.receipt_long;
      } else if (categoriaLower.contains('hogar')) {
        return Icons.home;
      } else if (categoriaLower.contains('invitación')) {
        return Icons.card_giftcard;
      } else if (categoriaLower.contains('joya')) {
        return Icons.diamond;
      } else {
        return Icons.attach_money;
      }
    } else if (tipo == 'ahorro') {
      if (categoriaLower.contains('vacaciones') || categoriaLower.contains('viaje')) {
        return Icons.flight;
      } else if (categoriaLower.contains('emergencia') || categoriaLower.contains('fondo')) {
        return Icons.shield;
      } else if (categoriaLower.contains('jubilación')) {
        return Icons.elderly;
      } else if (categoriaLower.contains('educación')) {
        return Icons.school;
      } else if (categoriaLower.contains('casa')) {
        return Icons.home;
      } else if (categoriaLower.contains('auto')) {
        return Icons.directions_car;
      } else if (categoriaLower.contains('inversión')) {
        return Icons.trending_up;
      } else if (categoriaLower.contains('navidad')) {
        return Icons.card_giftcard;
      } else if (categoriaLower.contains('boda')) {
        return Icons.favorite;
      } else if (categoriaLower.contains('cumpleaños')) {
        return Icons.cake;
      } else {
        return Icons.savings;
      }
    }
    
    return Icons.category;
  }

  // Obtener datos del mes seleccionado
  Map<String, double> _obtenerDatosMes() {
    double totalIngresos = 0;
    double totalGastos = 0;
    double totalAhorros = 0;

    
      for (var ingreso in _ingresosList) {
        totalIngresos += ingreso.monto;
      }

      for (var gasto in _gastosList) {
        totalGastos += gasto.monto;
      }

      for (var ahorro in _ahorrosList) {
        totalAhorros += ahorro.monto;
      }

    return {
      'ingresos': totalIngresos,
      'gastos': totalGastos,
      'ahorros': totalAhorros,
    };
  }

  // Obtener datos para el gráfico según el tipo seleccionado
  Map<String, double> _obtenerDatosGraficoActual() {
    Map<String, double> datos = {};

      switch (_graficoActual) {
        case 0: // Ingresos
          if (_ingresosList.isNotEmpty) {
            for (var ingreso in _ingresosList) {
              datos[ingreso.categoria] = (datos[ingreso.categoria] ?? 0.0) + ingreso.monto;
            }
          }
          break;
        case 1: // Gastos
          if (_gastosList.isNotEmpty) {
            for (var gasto in _gastosList) {
              datos[gasto.categoria] = (datos[gasto.categoria] ?? 0.0) + gasto.monto;
            }
          }
          break;
        case 2: // Ahorros
          if (_ahorrosList.isNotEmpty) {
            for (var ahorro in _ahorrosList) {
              datos[ahorro.categoria] = (datos[ahorro.categoria] ?? 0.0) + ahorro.monto;
            }
          }
          break;
      }
    return datos;
  }

  String _obtenerMesSeleccionado() {
    return _meses[_mesSeleccionado - 1];
  }

  Future<void> _seleccionarMes() async {
    final int mesActual = DateTime.now().month;
    final int anioActual = DateTime.now().year;

    // Calcular los últimos 12 meses
    List<Map<String, dynamic>> mesesDisponibles = [];
    for (int i = 11; i >= 0; i--) {
      int mes = mesActual - i;
      int anio = anioActual;
      
      if (mes <= 0) {
        mes += 12;
        anio -= 1;
      }
      
      mesesDisponibles.add({
        'mes': mes,
        'anio': anio,
        'nombre': '${_meses[mes - 1]} $anio',
      });
    }

    final Map<String, dynamic>? mesSeleccionado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Mes'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mesesDisponibles.length,
              itemBuilder: (context, index) {
                final mesData = mesesDisponibles[index];
                final isSelected = mesData['mes'] == _mesSeleccionado && 
                                   mesData['anio'] == _anioSeleccionado;
                
                return ListTile(
                  title: Text(
                    mesData['nombre'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color.fromARGB(255, 61, 56, 245)
                          : null,
                    ),
                  ),
                  leading: Icon(
                    Icons.calendar_month,
                    color: isSelected
                        ? const Color.fromARGB(255, 61, 56, 245)
                        : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(mesData);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (mesSeleccionado != null) {
      setState(() {
        _mesSeleccionado = mesSeleccionado['mes'];
        _anioSeleccionado = mesSeleccionado['anio'];
      });
      _cargarDatosFirebase();
    }
  }

  IconData _obtenerIcono(String categoria) {
    return _iconosCategorias[categoria] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final datos = _obtenerDatosMes();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarDatosFirebase,
            tooltip: 'Recargar datos',
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatosFirebase,
              child: ListView(
                padding: const EdgeInsets.all(10.0),
                children: [
                  // Row con el mes y el icono del calendario
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_obtenerMesSeleccionado()} $_anioSeleccionado',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 61, 56, 245),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _seleccionarMes,
                        child: const Icon(
                          Icons.calendar_month,
                          color: Color.fromARGB(255, 61, 56, 245),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  _cardResumen(datos),
                  const SizedBox(height: 20.0),
                  _cardAtajos(),
                  const SizedBox(height: 30.0),
                  _cardGrafico(datos),
                  const SizedBox(height: 20.0),
                  _cardEstadisticas(datos),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indexInicial,
        selectedItemColor: const Color.fromARGB(255, 61, 56, 245),
        unselectedItemColor: const Color.fromARGB(255, 158, 158, 158),
        unselectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 158, 158, 158),
        ),
        selectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 61, 56, 245),
        ),
        onTap: (index) {
          setState(() {
            _indexInicial = index;
          });

          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IngresosPage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GastosPage()),
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AhorrosPage()),
              );
              break;
            case 4:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'Ingresos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Ahorros'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Más'),
        ],
      ),
    );
  }

  Widget _cardResumen(Map<String, double> datos) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 128, 0, 0.5),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ingresos',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 61, 56, 245),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(255, 165, 0, 0.5),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Gastos',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 61, 56, 245),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 255, 0.5),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Ahorros',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(255, 61, 56, 245),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          '\$${datos['ingresos']!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 61, 56, 245),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          '\$${datos['gastos']!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 61, 56, 245),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          '\$${datos['ahorros']!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 61, 56, 245),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieChartCategorias(Map<String, double> datos) {
    if (datos.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Sin datos para mostrar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final List<Color> colores = [
      const Color(0xff0293ee),
      const Color(0xfff8b250),
      const Color(0xff845bef),
      const Color(0xff13d38e),
      const Color(0xffff6b6b),
      const Color(0xff4ecdc4),
    ];

    final double total = datos.values.reduce((a, b) => a + b);

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 70,
          sections: datos.entries.map((entry) {
            int index = datos.keys.toList().indexOf(entry.key);
            double porcentaje = (entry.value / total) * 100;
            return PieChartSectionData(
              value: entry.value,
              color: colores[index % colores.length],
              title: '${porcentaje.toStringAsFixed(1)}%',
              radius: 40,
              showTitle: true,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.5,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _leyendaCategorias(Map<String, double> datos) {
    if (datos.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Color> colores = [
      const Color(0xff0293ee),
      const Color(0xfff8b250),
      const Color(0xff845bef),
      const Color(0xff13d38e),
      const Color(0xffff6b6b),
      const Color(0xff4ecdc4),
    ];

    return Column(
      children: datos.entries.map((entry) {
        int index = datos.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Icon(
                _obtenerIcono(entry.key),
                color: colores[index % colores.length],
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${entry.key}: \$${entry.value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 21, 21, 21),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _cardGrafico(Map<String, double> datos) {
    final datosGrafico = _obtenerDatosGraficoActual();
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_tiposGrafico[_graficoActual]} por Categoría',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 25, 25, 26),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBotonCarrusel('Ingresos', 0),
                  _buildBotonCarrusel('Gastos', 1),
                  _buildBotonCarrusel('Ahorros', 2),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _pieChartCategorias(datosGrafico),
            const SizedBox(height: 10),
            _leyendaCategorias(datosGrafico),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCarrusel(String titulo, int indice) {
    final bool isSelected = _graficoActual == indice;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _graficoActual = indice;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 61, 56, 245)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          titulo,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _cardAtajos() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IngresosPage()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Color.fromARGB(255, 61, 56, 245),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Ingresos',
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 56, 245),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GastosPage()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Color.fromARGB(255, 61, 56, 245),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Gastos',
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 56, 245),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AhorrosPage()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.savings,
                      color: Color.fromARGB(255, 61, 56, 245),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Ahorros',
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 56, 245),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad en desarrollo')),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.list,
                      color: Color.fromARGB(255, 61, 56, 245),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Registros',
                    style: TextStyle(
                      color: Color.fromARGB(255, 61, 56, 245),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardEstadisticas(Map<String, double> datos) {
    final double balance = datos['ingresos']! - datos['gastos']!;
    final bool isPositive = balance >= 0;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance del mes',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 56, 245),
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${balance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isPositive
                  ? '¡Excelente! Tus ingresos superan tus gastos'
                  : 'Atención: Tus gastos superan tus ingresos',
              style: TextStyle(
                fontSize: 13.0,
                color: isPositive ? Colors.green : Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
