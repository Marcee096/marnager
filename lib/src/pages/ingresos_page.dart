import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart' show AhorrosPage;
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:fl_chart/fl_chart.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  String? _opcionSeleccionadaDropdown;
  String? ingresoSeleccionado;
  String? cuentaSeleccionada;

  

  final List<String> _ingresos = [
    //ejemplos, esta lista debe obtenerse de una BD
    'Invitaciones',
    'Joyas',
    'Beca',
  ];

  final List<String> _cuentas = [
    //ejemplos, esta lista debe obtenerse de una BD
    'Venta',
    'Seña',
    'Cobro',
    'Intereses',
  ];
  final Map<String, double> datos = {
    'Invitaciones': 5000,
    'Joyas': 3000,
    'Beca': 2000,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ingresos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 61, 56, 245),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [_cardFuente(), _cardCargaIngreso(), _cardGrafico(datos), _pieChartResumen(datos)],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color.fromARGB(255, 61, 56, 245),
        unselectedItemColor: const Color.fromARGB(255, 158, 158, 158),
        unselectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 158, 158, 158),
        ),
        selectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 61, 56, 245),
        ),
        onTap: (index) {

          // Navegación basada en el índice seleccionado
          switch (index) {
            case 0:
              //ya estamos en ingresos
              break;
            case 1:
              // Navegar a página de Gastos
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GastosPage()),
              );
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()));
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

  Widget _cardFuente() {
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fuente de Ingreso'),
            const SizedBox(height: 15.0),
            _crearDropdown(),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var ingreso in _ingresos) {
      lista.add(
        DropdownMenuItem(
          value: ingreso,
          child: Text(
            ingreso,
            style: const TextStyle(
              color: Colors.white,
            ), // Texto blanco en los items
          ),
        ),
      );
    }
    return lista;
  }

  List<DropdownMenuItem<String>> getOpcionesCuentasDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var cuenta in _cuentas) {
      lista.add(
        DropdownMenuItem(
          value: cuenta,
          child: Text(
            cuenta,
            style: const TextStyle(
              color: Colors.white,
            ), // Texto blanco en los items
          ),
        ),
      );
    }
    return lista;
  }

  Widget _crearDropdownCuentas() {
    return Row(
      children: <Widget>[
        const SizedBox(width: 10.0),
        Container(
          width: 250.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 233, 233, 236), // Color de fondo
            borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
            border: Border.all(
              color: Color.fromARGB(255, 61, 56, 245), // Color del borde
              width: 2.0, // Ancho del borde
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              value: ingresoSeleccionado,
              hint: const Text(
                'Cuenta',
                style: TextStyle(color: Colors.black),
              ),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black,
              ), // Color del texto seleccionado
              
              items: getOpcionesCuentasDropdown(),
              onChanged: (opt) {
                setState(() {
                  ingresoSeleccionado = opt.toString();
                });
              },
            ),
          ),
        ),
      ],
    );
  }
  Widget _crearDropdown() {
    return Row(
      children: <Widget>[
        const SizedBox(width: 10.0),
        Container(
          width: 250.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 61, 56, 245), // Color de fondo
            borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              value: _opcionSeleccionadaDropdown,
              hint: const Text(
                'Seleccione',
                style: TextStyle(color: Colors.white),
              ),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.white,
              ), // Color del texto seleccionado
              dropdownColor: const Color.fromARGB( 255,61,56,245,), // Color de fondo del menú desplegable
              items: getOpcionesDropdown(),
              onChanged: (opt) {
                setState(() {
                  _opcionSeleccionadaDropdown = opt.toString();
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardCargaIngreso(){
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Carga de datos'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      
                      padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                      elevation: 5,
                      shadowColor: Colors.grey,
                    ),
                    onPressed: () {
                      
                    }, 
                    child: const Icon(Icons.camera_alt, size: 18), // Icono más pequeño
                  ),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0), // Reducido de 12 a 8
                      elevation: 5,
                      shadowColor: Colors.grey,
                    ),
                    onPressed: () {
                      
                    }, 
                    child: const Icon(Icons.attach_file, size: 18), // Icono más pequeño
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          _crearDropdownCuentas(),
          const SizedBox(height: 15.0),
          Container(
            width: 250.0,
          margin: const EdgeInsets.only(left: 10.0), // Mismo margen que el dropdown
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none, // Sin borde para que coincida con el dropdown
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 232, 232, 236), // Mismo color que el dropdown
              hintText: 'Monto',
              hintStyle: const TextStyle(color: Colors.black),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Mismo padding que el dropdown
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(height: 15.0),
        // TextField con el mismo estilo que el dropdown
        Container(
          width: 250.0,
          margin: const EdgeInsets.only(left: 10.0), // Mismo margen que el dropdown
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none, // Sin borde para que coincida con el dropdown
              ),
              filled: true,
              
              fillColor: const Color.fromARGB(255, 232, 232, 236), // Mismo color que el dropdown
              hintText: 'Detalle (opcional)',
              hintStyle: const TextStyle(color: Colors.black),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Mismo padding que el dropdown
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  ));
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

  // Método específico para gráfico de categorías de ingresos
  Widget _pieChartIngresos(Map<String, double> datos) {
    // Si no hay datos, mostrar placeholder
    if (datos.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('Sin datos para mostrar', style: TextStyle(color: Colors.grey))),
      );
    }

    // Colores para las diferentes categorías
    final List<Color> colores = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return SizedBox(
      height: 160,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: datos.entries.map((entry) {
            int index = datos.keys.toList().indexOf(entry.key);
            return PieChartSectionData(
              value: entry.value,
              color: colores[index % colores.length],
              title: '\$${entry.value.toStringAsFixed(0)}',
              radius: 40,
              showTitle: true,
              titleStyle: const TextStyle(
                color: Colors.white, 
                fontSize: 12, 
                fontWeight: FontWeight.bold
              ),
              borderSide: BorderSide.none,
              titlePositionPercentageOffset: 0.6,
            );
          }).toList(),
        ),
      ),
    );
  }

  // Actualiza la card del gráfico para usar el nuevo método
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
              'Resumen',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 61, 56, 245),
              ),
            ),
            const SizedBox(height: 10),
            // Usa el método específico para ingresos
            _pieChartIngresos(datos),
            const SizedBox(height: 10),
            // Opcional: mostrar leyenda
            _leyendaIngresos(datos),
          ],
        ),
      ),
    );
  }

  // leyenda para identificar las categorías
  Widget _leyendaIngresos(Map<String, double> datos) {
    final List<Color> colores = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Column(
      children: datos.entries.map((entry) {
        int index = datos.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colores[index % colores.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 61, 56, 245),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
