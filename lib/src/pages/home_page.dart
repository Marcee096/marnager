import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart';
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/ingresos_page.dart';
import 'package:fl_chart/fl_chart.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indexInicial = 2; // Inicio como selección inicial
  late int _mesSeleccionado; // Se inicializa en initState
  

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
    // Inicializar con el mes actual
    final int mesActual = DateTime.now().month;
    _mesSeleccionado = mesActual;
  }

  String _obtenerMesSeleccionado() {
    return _meses[_mesSeleccionado - 1];
  }

  Future<void> _seleccionarMes() async {
    final int mesActual = DateTime.now().month;

    // Calcular los 5 meses anteriores hasta el actual
    List<int> mesesDisponibles = [];
    for (int i = 4; i >= 0; i--) {
      int mes = mesActual - i;
      if (mes > 0) {
        mesesDisponibles.add(mes);
      } else {
        // Si el mes es menor a 1, no lo incluimos (para mantener solo el año actual)
        break;
      }
    }

    // Mostrar diálogo con los meses disponibles
    final int? mesSeleccionado = await showDialog<int>(
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
                final mes = mesesDisponibles[index];
                return ListTile(
                  title: Text(
                    _meses[mes - 1],
                    style: TextStyle(
                      fontWeight: mes == _mesSeleccionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: mes == _mesSeleccionado
                          ? const Color.fromARGB(255, 61, 56, 245)
                          : null,
                    ),
                  ),
                  leading: Icon(
                    Icons.calendar_month,
                    color: mes == _mesSeleccionado
                        ? const Color.fromARGB(255, 61, 56, 245)
                        : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(mes);
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
        _mesSeleccionado = mesSeleccionado;
      });
    }
  }
  
  // Método para obtener datos del mes seleccionado
  Map<String, double> _obtenerDatosMes() {
    // BD
    // Ejemplo
    double ingresos = 35000 + (_mesSeleccionado * 100); // Datos de ejemplo
    double gastos = 22000 + (_mesSeleccionado * 50);
    double ahorros = ingresos - gastos;

    return {'ingresos': ingresos, 'gastos': gastos, 'ahorros': ahorros};
  }
  
  @override
  Widget build(BuildContext context) {
    final datos = _obtenerDatosMes();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hola, Marce', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          // Row con el mes y el icono del calendario
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _obtenerMesSeleccionado(),
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
          // Card de resumen (ahora recibe los datos)
          _cardResumen(datos),
          const SizedBox(height: 20.0),
          // Card de atajos
          _cardAtajos(),
          const SizedBox(height: 30.0),
          // Card de gráfico (debajo de resumen)
          _cardGrafico(datos),
          const SizedBox(height: 20.0),
          _cardFuentesIngresos(),
          const SizedBox(height: 30.0),
        ],
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

          // Navegación basada en el índice seleccionado
          switch (index) {
            case 0:
              // Navegar a página de Ingresos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IngresosPage()),
              );
              break;
            case 1:
              // Navegar a página de Gastos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GastosPage()),
              );
              break;
            case 2:
              // Ya estamos en Inicio
              break;
            case 3:
              // Navegar a página de Ahorros
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AhorrosPage()),
              );
              break;
            case 4:
              // Navegar a página de Más opciones
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

  // ajustar firma para recibir datos
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
            // Contenedor principal con dos columnas
            Row(
              children: [
                // Columna de textos (lado izquierdo)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 30,
                          ), // Padding fijo desde la izquierda
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
                          const SizedBox(
                            width: 30,
                          ), // Mismo padding para alineación
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
                          const SizedBox(
                            width: 30,
                          ), // Mismo padding para alineación
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
                // Columna de valores (lado derecho)
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
  
  // Nuevo método: grafico de pastel para el resumen
  Widget _pieChartResumen(Map<String, double> datos) {
    final double ingresos = datos['ingresos'] ?? 0;
    final double gastos = datos['gastos'] ?? 0;
    final double ahorros = datos['ahorros'] ?? 0;

    // Si todos son 0, mostrar placeholder (evita división por 0 visualmente)
    if (ingresos == 0 && gastos == 0 && ahorros == 0) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Sin datos para mostrar', style: TextStyle(color: Colors.grey))),
      );
    }

    return SizedBox(
      height: 160,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(
              value: ingresos,
              color: Colors.green,
              title: '\$${ingresos.toStringAsFixed(0)}',
              radius: 40,
              showTitle: true,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.6,
            ),
            PieChartSectionData(
              value: gastos,
              color: Colors.orange,
              title: '\$${gastos.toStringAsFixed(0)}',
              radius: 40,
              showTitle: true,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.6,
            ),
            PieChartSectionData(
              value: ahorros,
              color: Colors.blue,
              title: '\$${ahorros.toStringAsFixed(0)}',
              radius: 40,
              showTitle: true,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.6,
            ),
          ],
        ),
      ),
    );
  }

  // Nueva card que contiene el gráfico
  Widget _cardGrafico(Map<String, double> datos) {
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
              'Distribución',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 56, 245),
              ),
            ),
            const SizedBox(height: 10),
            // reutiliza tu método de pie chart
            _pieChartResumen(datos),
          ],
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
            // Botón Ingresos
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IngresosPage()),
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
            // Botón Gastos
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GastosPage()),
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
            // Botón Ahorros
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AhorrosPage()),
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
            // Botón Registros
            GestureDetector(
              onTap: () {},
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

  Widget _cardFuentesIngresos() {
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
              'Mis fuentes de ingresos',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 56, 245),
              ),
            ),
            const SizedBox(height: 10.0),
            // Aquí puedes agregar una lista o gráficos de las fuentes de ingresos
            const Text(
              'Fotos de los ingresos mas el boton para agregar nuevas fuentes',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  
}
