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
  
  // Variables para el carrusel de gráficos
  int _graficoActual = 0; // 0: Ingresos, 1: Gastos, 2: Ahorros
  final List<String> _tiposGrafico = ['Ingresos', 'Gastos', 'Ahorros'];

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

  // Datos de ejemplo para las categorías (estos deberían venir de la BD)
  final Map<String, double> _datosIngresos = {
    'Invitaciones': 21000,
    'Joyas': 3000,
    'Beca': 2000,
  };

  final Map<String, double> _datosGastos = {
    'Personales': 21000,
    'Joyas': 3000,
    'Invitaciones': 2000,
  };

  final Map<String, double> _datosAhorros = {
    'Vacaciones': 21000,
    'Cumpleaños': 3000,
    'Fondo de Emergencia': 2000,
  };

  // Método para obtener el icono según la categoría
  IconData _obtenerIcono(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'invitaciones':
        return Icons.card_giftcard;
      case 'joyas':
        return Icons.diamond;
      case 'beca':
      case 'educación':
        return Icons.school;
      case 'personales':
        return Icons.person;
      case 'vacaciones':
        return Icons.beach_access;
      case 'cumpleaños':
        return Icons.cake;
      case 'fondo de emergencia':
        return Icons.security;
      default:
        return Icons.attach_money;
    }
  }

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
  
  // Método para obtener datos según el gráfico seleccionado
  Map<String, double> _obtenerDatosGraficoActual() {
    switch (_graficoActual) {
      case 0:
        return _datosIngresos;
      case 1:
        return _datosGastos;
      case 2:
        return _datosAhorros;
      default:
        return _datosIngresos;
    }
  }

  // Nuevo método: grafico de pastel para categorías (estilo actualizado)
  Widget _pieChartCategorias(Map<String, double> datos) {
    // Si no hay datos, mostrar placeholder  
    if (datos.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Sin datos para mostrar', style: TextStyle(color: Colors.grey))),
      );
    }

    // Colores que coinciden con las otras páginas
    final List<Color> colores = [
      const Color(0xff0293ee),
      const Color(0xfff8b250),
      const Color(0xff845bef),
      const Color(0xff13d38e),
      const Color(0xffff6b6b),
      const Color(0xff4ecdc4),
    ];

    // Calcular el total para los porcentajes
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
                fontWeight: FontWeight.bold
              ),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.5,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Leyenda para las categorías
  Widget _leyendaCategorias(Map<String, double> datos) {
    if (datos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Colores que coinciden con el gráfico
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
              // Nombre de la categoría y monto
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

  // Nueva card que contiene el gráfico con carrusel
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
             // Título dinámico
            Text(
              '${_tiposGrafico[_graficoActual]} por Categoría',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 25, 25, 26),
              ),
            ),
            const SizedBox(height: 10),
            // Botones del carrusel
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
            // Gráfico de categorías
            _pieChartCategorias(datosGrafico),
            const SizedBox(height: 10),
            // Leyenda
            _leyendaCategorias(datosGrafico),
          ],
        ),
      ),
    );
  }

  // Método para construir botones del carrusel
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
