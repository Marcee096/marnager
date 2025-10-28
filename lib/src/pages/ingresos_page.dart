import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart' show AhorrosPage;
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_services.dart';
import '../models/ingreso.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  String? _opcionSeleccionadaDropdown;
  String? ingresoSeleccionado;
  String? cuentaSeleccionada;

  // Controladores para los campos de texto
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();

  // Instancia del servicio de Firebase
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Variables para almacenar datos de Firebase
  List<Ingreso> _ingresosList = [];
  List<String> _categorias = [];
  bool _isLoading = true;

  // Mes y año actual
  final _mesActual = DateTime.now().month;
  final _anioActual = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _cargarDatosFirebase();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _detalleController.dispose();
    super.dispose();
  }

  // Cargar datos desde Firebase
  Future<void> _cargarDatosFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener ingresos del mes actual
      final ingresos = await _firebaseServices.getIngresosByMonth(_mesActual, _anioActual);
      
      // Obtener categorías únicas de los ingresos
      final categoriasSet = ingresos.map((i) => i.categoria).toSet();
      final categoriasList = categoriasSet.toList();

      setState(() {
        _ingresosList = ingresos;
        _categorias = categoriasList;
        _isLoading = false;
      });
    } catch (e) {
      
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  // Método para guardar un nuevo ingreso
  Future<void> _guardarIngreso() async {
    // Validar campos
    if (_opcionSeleccionadaDropdown == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una categoría')),
      );
      return;
    }

    if (ingresoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una subcategoría')),
      );
      return;
    }

    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese el monto')),
      );
      return;
    }

    try {
      final monto = double.parse(_montoController.text);
      
      // Crear el objeto Ingreso
      final nuevoIngreso = Ingreso(
        id: '', // Se genera automáticamente en Firebase
        categoria: _opcionSeleccionadaDropdown!,
        subcategoria: ingresoSeleccionado!,
        monto: monto,
        fecha: DateTime.now(),
      );

      // Guardar en Firebase
      await _firebaseServices.insertIngreso(nuevoIngreso);

      // Limpiar campos
      setState(() {
        _opcionSeleccionadaDropdown = null;
        ingresoSeleccionado = null;
        _montoController.clear();
        _detalleController.clear();
      });

      // Recargar datos
      await _cargarDatosFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso guardado exitosamente')),
        );
      }
    } catch (e) {
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

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

  // Método para obtener datos del gráfico desde Firebase
  Map<String, double> _obtenerDatosParaGrafico() {
    if (_opcionSeleccionadaDropdown == null) {
      // Si no hay selección, mostrar todas las categorías principales
      Map<String, double> categoriasPrincipales = {};
      
      for (var ingreso in _ingresosList) {
        categoriasPrincipales[ingreso.categoria] = 
            (categoriasPrincipales[ingreso.categoria] ?? 0.0) + ingreso.monto;
      }
      
      return categoriasPrincipales;
    } else {
      // Si hay una categoría seleccionada, mostrar sus subcategorías
      Map<String, double> subcategorias = {};
      
      var ingresosFiltrados = _ingresosList
          .where((ingreso) => ingreso.categoria == _opcionSeleccionadaDropdown)
          .toList();
      
      for (var ingreso in ingresosFiltrados) {
        subcategorias[ingreso.subcategoria] = 
            (subcategorias[ingreso.subcategoria] ?? 0.0) + ingreso.monto;
      }
      
      return subcategorias;
    }
  }

  @override
  Widget build(BuildContext context) {
    final datosDinamicos = _obtenerDatosParaGrafico();
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ingresos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosFirebase,
            tooltip: 'Recargar datos',
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
                  _cardFuente(),
                  _cardCargaIngreso(),
                  _cardGrafico(datosDinamicos),
                ],
              ),
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
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GastosPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AhorrosPage()),
              );
              break;
            case 4:
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
    for (var categoria in _categorias) {
      lista.add(
        DropdownMenuItem(
          value: categoria,
          child: Text(
            categoria,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return lista;
  }

  List<DropdownMenuItem<String>> getOpcionesCuentasDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    
    if (_opcionSeleccionadaDropdown != null) {
      // Obtener subcategorías únicas de la categoría seleccionada
      var subcategorias = _ingresosList
          .where((i) => i.categoria == _opcionSeleccionadaDropdown)
          .map((i) => i.subcategoria)
          .toSet()
          .toList();
      
      for (var subcategoria in subcategorias) {
        lista.add(
          DropdownMenuItem(
            value: subcategoria,
            child: Text(
              subcategoria,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
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
            color: const Color.fromARGB(255, 233, 233, 236),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: const Color.fromARGB(255, 61, 56, 245),
              width: 2.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              value: ingresoSeleccionado,
              hint: const Text(
                'Subcategoría',
                style: TextStyle(color: Colors.black),
              ),
              isExpanded: true,
              style: const TextStyle(color: Colors.black),
              items: getOpcionesCuentasDropdown(),
              onChanged: (opt) {
                setState(() {
                  ingresoSeleccionado = opt;
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
            color: const Color.fromARGB(255, 61, 56, 245),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              value: _opcionSeleccionadaDropdown,
              hint: const Text(
                'Seleccione Categoría',
                style: TextStyle(color: Colors.white),
              ),
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              dropdownColor: const Color.fromARGB(255, 61, 56, 245),
              items: getOpcionesDropdown(),
              onChanged: (opt) {
                setState(() {
                  _opcionSeleccionadaDropdown = opt;
                  ingresoSeleccionado = null; // Reset subcategoría
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardCargaIngreso() {
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
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        elevation: 5,
                      ),
                      onPressed: () {
                        
                      },
                      child: const Icon(Icons.camera_alt, size: 18),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        elevation: 5,
                      ),
                      onPressed: () {
                        
                      },
                      child: const Icon(Icons.attach_file, size: 18),
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
              margin: const EdgeInsets.only(left: 10.0),
              child: TextField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 232, 232, 236),
                  hintText: 'Monto',
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 15.0),
            Container(
              width: 250.0,
              margin: const EdgeInsets.only(left: 10.0),
              child: TextField(
                controller: _detalleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 232, 232, 236),
                  hintText: 'Detalle (opcional)',
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 15.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _guardarIngreso,
                child: const Text('Guardar Ingreso'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieChartIngresos(Map<String, double> datos) {
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

  Widget _cardGrafico(Map<String, double> datos) {
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
            _pieChartIngresos(datos),
            const SizedBox(height: 10),
            _leyendaIngresos(datos),
          ],
        ),
      ),
    );
  }

  Widget _leyendaIngresos(Map<String, double> datos) {
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
}
