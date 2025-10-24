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

  // Método para obtener el icono según la categoría/subcategoría
  IconData _obtenerIcono(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'web':
      case 'páginas web':
        return Icons.web;
      case 'imagen':
      case 'diseño gráfico':
        return Icons.image;
      case 'video':
      case 'edición de video':
        return Icons.video_library;
      case 'pdf':
      case 'documentos':
        return Icons.picture_as_pdf;
      case 'tienda':
      case 'retail':
        return Icons.store;
      case 'educación':
      case 'beca':
        return Icons.school;
      case 'invitaciones':
        return Icons.card_giftcard;
      case 'joyas':
        return Icons.diamond;
      default:
        return Icons.attach_money;
    }
  }
  
  // Datos estructurados con categorías y subcategorías
  final List<Map<String, dynamic>> datosCompletos = [
    { 'categoria': 'Invitaciones', 'subcategoria': 'Web', 'monto': 5000 },
    { 'categoria': 'Invitaciones', 'subcategoria': 'Imagen', 'monto': 3000 },
    { 'categoria': 'Invitaciones', 'subcategoria': 'Video', 'monto': 8000 },
    { 'categoria': 'Invitaciones', 'subcategoria': 'PDF', 'monto': 5000 },
    { 'categoria': 'Joyas', 'subcategoria': 'Tienda', 'monto': 3000 },
    { 'categoria': 'Beca', 'subcategoria': 'Educación', 'monto': 2000 },
  ];

  // Método para obtener subcategorías según la selección del dropdown
  Map<String, double> _obtenerDatosParaGrafico() {
    if (_opcionSeleccionadaDropdown == null) {
      // Si no hay selección, mostrar todas las categorías principales
      Map<String, double> categoriasPrincipales = {};
      for (var categoria in _ingresos) {
        double total = datosCompletos
            .where((item) => item['categoria'] == categoria)
            .fold(0.0, (sum, item) => sum + item['monto']);
        if (total > 0) {
          categoriasPrincipales[categoria] = total;
        }
      }
      return categoriasPrincipales;
    } else {
      // Si hay una categoría seleccionada, mostrar sus subcategorías
      Map<String, double> subcategorias = {};
      var datosCategoria = datosCompletos
          .where((item) => item['categoria'] == _opcionSeleccionadaDropdown)
          .toList();
      
      for (var item in datosCategoria) {
        subcategorias[item['subcategoria']] = item['monto'].toDouble();
      }
      return subcategorias;
    }
  }
  @override
  Widget build(BuildContext context) {
    // Obtener datos dinámicos según la selección
    final datosDinamicos = _obtenerDatosParaGrafico();
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ingresos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 61, 56, 245),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [_cardFuente(), _cardCargaIngreso(), _cardGrafico(datosDinamicos)],
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
              hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
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
              hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Mismo padding que el dropdown
            ),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  ));
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
          centerSpaceRadius: 60,
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
                fontSize: 12, 
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

  
  Widget _cardGrafico(Map<String, double> datos) {
    // Título dinámico según la selección
    String titulo = _opcionSeleccionadaDropdown == null 
        ? 'Resumen por Categorías' 
        : 'Subcategorías de $_opcionSeleccionadaDropdown';
    
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
              titulo,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 25, 25, 26),
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
             
              const SizedBox(width: 10),
              // Icono específico para cada categoría
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
}
