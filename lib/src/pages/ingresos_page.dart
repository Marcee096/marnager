import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart' show AhorrosPage;
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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

  // Controladores para los campos de texto
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _subcategoriaController = TextEditingController();

  // Fecha seleccionada
  DateTime _fechaSeleccionada = DateTime.now();

  // Instancia del servicio de Firebase
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Variables para almacenar datos de Firebase
  List<Ingreso> _ingresosList = [];
  List<String> _categorias = [];
  List<String> _subcategoriasDisponibles = [];
  bool _isLoading = true;
  bool _mostrarSubcategorias = false;

  // Mes y año actual
  final _mesActual = DateTime.now().month;
  final _anioActual = DateTime.now().year;

  // Mapa de íconos para subcategorías
  final Map<String, IconData> _iconosSubcategorias = {};

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  // Método para inicializar la localización y cargar datos
  Future<void> _inicializar() async {
    // Inicializar datos de localización para español
    await initializeDateFormatting('es_ES', null);
    
    // Cargar datos de Firebase
    _cargarDatosFirebase();
    
    // Inicializar el campo de fecha con la fecha actual
    _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _detalleController.dispose();
    _fechaController.dispose();
    _subcategoriaController.dispose();
    super.dispose();
  }

  // Cargar datos desde Firebase
  Future<void> _cargarDatosFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener todos los ingresos (no solo del mes actual) para obtener todas las subcategorías
      final ingresos = await _firebaseServices.getAllIngresos();
      
      // Obtener categorías únicas
      final categoriasSet = ingresos.map((i) => i.categoria).toSet();
      final categoriasList = categoriasSet.toList();

      // Obtener ingresos del mes actual para el gráfico
      final ingresosDelMes = await _firebaseServices.getIngresosByMonth(_mesActual, _anioActual);

      // Asignar íconos a todas las subcategorías existentes
      for (var ingreso in ingresos) {
        if (!_iconosSubcategorias.containsKey(ingreso.subcategoria)) {
          _iconosSubcategorias[ingreso.subcategoria] = _asignarIcono(ingreso.subcategoria);
        }
      }

      setState(() {
        _ingresosList = ingresosDelMes;
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

  // Actualizar subcategorías disponibles cuando se selecciona una categoría
  Future<void> _actualizarSubcategorias(String categoria) async {
   
      final todosLosIngresos = await _firebaseServices.getAllIngresos();
      
      final subcategorias = todosLosIngresos
          .where((i) => i.categoria == categoria)
          .map((i) => i.subcategoria)
          .toSet()
          .toList();

      setState(() {
        _subcategoriasDisponibles = subcategorias;
      });
    
  }

  // Asignar icono automáticamente basado en palabras clave
  IconData _asignarIcono(String subcategoria) {
    final subcategoriaLower = subcategoria.toLowerCase();
    
    // Palabras clave para diferentes categorías
    if (subcategoriaLower.contains('web') || subcategoriaLower.contains('página')) {
      return Icons.web;
    } else if (subcategoriaLower.contains('diseño') || subcategoriaLower.contains('gráfico') || subcategoriaLower.contains('imagen')) {
      return Icons.palette;
    } else if (subcategoriaLower.contains('video') || subcategoriaLower.contains('edición')) {
      return Icons.video_library;
    } else if (subcategoriaLower.contains('pdf') || subcategoriaLower.contains('documento')) {
      return Icons.picture_as_pdf;
    } else if (subcategoriaLower.contains('tienda') || subcategoriaLower.contains('retail') || subcategoriaLower.contains('venta')) {
      return Icons.store;
    } else if (subcategoriaLower.contains('educación') || subcategoriaLower.contains('beca') || subcategoriaLower.contains('curso')) {
      return Icons.school;
    } else if (subcategoriaLower.contains('invitación') || subcategoriaLower.contains('evento')) {
      return Icons.card_giftcard;
    } else if (subcategoriaLower.contains('joya') || subcategoriaLower.contains('anillo') || subcategoriaLower.contains('collar')) {
      return Icons.diamond;
    } else if (subcategoriaLower.contains('foto') || subcategoriaLower.contains('fotografía')) {
      return Icons.camera_alt;
    } else if (subcategoriaLower.contains('consulta') || subcategoriaLower.contains('asesoría')) {
      return Icons.support_agent;
    } else if (subcategoriaLower.contains('desarrollo') || subcategoriaLower.contains('app')) {
      return Icons.code;
    } else if (subcategoriaLower.contains('marketing') || subcategoriaLower.contains('publicidad')) {
      return Icons.campaign;
    } else if (subcategoriaLower.contains('social') || subcategoriaLower.contains('redes')) {
      return Icons.share;
    } else if (subcategoriaLower.contains('redacción') || subcategoriaLower.contains('contenido')) {
      return Icons.article;
    } else if (subcategoriaLower.contains('traducción') || subcategoriaLower.contains('idioma')) {
      return Icons.translate;
    } else if (subcategoriaLower.contains('música') || subcategoriaLower.contains('audio')) {
      return Icons.music_note;
    } else {
      return Icons.work_outline;
    }
  }

  // Mostrar selector de fecha
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 61, 56, 245),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Seleccionar una subcategoría existente
  void _seleccionarSubcategoria(String subcategoria) {
    setState(() {
      _subcategoriaController.text = subcategoria;
      ingresoSeleccionado = subcategoria;
      _mostrarSubcategorias = false;
    });
  }

  // Método para guardar un nuevo ingreso
  Future<void> _guardarIngreso() async {
    // Validar campos obligatorios
    if (_opcionSeleccionadaDropdown == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_subcategoriaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese o seleccione una subcategoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese el monto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final monto = double.parse(_montoController.text);
      final detalle = _detalleController.text.trim();
      final subcategoria = _subcategoriaController.text.trim();
      
      // Si es una subcategoría nueva, asignarle un icono
      if (!_iconosSubcategorias.containsKey(subcategoria)) {
        _iconosSubcategorias[subcategoria] = _asignarIcono(subcategoria);
      }

      // Crear el objeto Ingreso
      final nuevoIngreso = Ingreso(
        id: '',
        categoria: _opcionSeleccionadaDropdown!,
        subcategoria: subcategoria,
        monto: monto,
        fecha: _fechaSeleccionada,
        detalle: detalle.isNotEmpty ? detalle : '',
      );

      

      // Guardar en Firebase
      await _firebaseServices.insertIngreso(nuevoIngreso);

      // Limpiar campos
      setState(() {
        _opcionSeleccionadaDropdown = null;
        ingresoSeleccionado = null;
        _montoController.clear();
        _detalleController.clear();
        _subcategoriaController.clear();
        _fechaSeleccionada = DateTime.now();
        _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
        _subcategoriasDisponibles = [];
      });

      // Recargar datos
      await _cargarDatosFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ingreso guardado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El monto debe ser un número válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para obtener el icono según la categoría
  IconData _obtenerIcono(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'freelance':
        return Icons.computer;
      case 'retail':
        return Icons.store;
      case 'educación':
        return Icons.school;
      case 'eventos':
        return Icons.event;
      case 'joyería':
        return Icons.diamond;
      case 'otros':
        return Icons.attach_money;
      default:
        return Icons.attach_money;
    }
  }

  // Método para obtener datos del gráfico SOLO por categorías principales
  Map<String, double> _obtenerDatosParaGrafico() {
    Map<String, double> categoriasPrincipales = {};
    
    for (var ingreso in _ingresosList) {
      categoriasPrincipales[ingreso.categoria] = 
          (categoriasPrincipales[ingreso.categoria] ?? 0.0) + ingreso.monto;
    }
    
    return categoriasPrincipales;
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

  Widget _crearDropdown() {
    return Container(
      width: double.infinity,
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
            'Categoría',
            style: TextStyle(color: Colors.white),
          ),
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color.fromARGB(255, 61, 56, 245),
          items: getOpcionesDropdown(),
          onChanged: (opt) {
            setState(() {
              _opcionSeleccionadaDropdown = opt;
              ingresoSeleccionado = null;
              _subcategoriaController.clear();
              _mostrarSubcategorias = false;
            });
            if (opt != null) {
              _actualizarSubcategorias(opt);
            }
          },
        ),
      ),
    );
  }

  Widget _crearCampoSubcategoria() {
    return Column(
      children: [
        TextField(
          controller: _subcategoriaController,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _mostrarSubcategorias = false;
              });
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color.fromARGB(255, 232, 232, 236),
            hintText: 'Escribe o selecciona subcategoría',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
            prefixIcon: const Icon(Icons.category, 
                color: Color.fromARGB(255, 61, 56, 245)),
            suffixIcon: _subcategoriasDisponibles.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      _mostrarSubcategorias ? Icons.expand_less : Icons.expand_more,
                      color: const Color.fromARGB(255, 61, 56, 245),
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarSubcategorias = !_mostrarSubcategorias;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        
        // Mostrar subcategorías disponibles
        if (_mostrarSubcategorias && _subcategoriasDisponibles.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Subcategorías guardadas:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _subcategoriasDisponibles.map((subcategoria) {
                    final icono = _iconosSubcategorias[subcategoria] ?? Icons.work_outline;
                    return GestureDetector(
                      onTap: () => _seleccionarSubcategoria(subcategoria),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 61, 56, 245),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(255, 240, 240, 243),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icono,
                              size: 18,
                              color: const Color.fromARGB(255, 251, 251, 252),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              subcategoria,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 241, 241, 243),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
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
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Nuevo Ingreso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(95, 200, 200, 206),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, 
                            color: Color.fromARGB(255, 61, 56, 245), size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidad en desarrollo')),
                          );
                        },
                      ),
                      Container(width: 1, height: 20, color: Colors.white),
                      IconButton(
                        icon: const Icon(Icons.attach_file, 
                            color: Color.fromARGB(255, 61, 56, 245), size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funcionalidad en desarrollo')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // Dropdown Categoría
            _crearDropdown(),
            const SizedBox(height: 15.0),

            // Campo Subcategoría con selector
            _crearCampoSubcategoria(),
            const SizedBox(height: 15.0),

            // Campo Fecha
            TextField(
              controller: _fechaController,
              readOnly: true,
              onTap: _seleccionarFecha,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 232, 232, 236),
                hintText: 'Fecha',
                hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
                prefixIcon: const Icon(Icons.calendar_today, 
                    color: Color.fromARGB(255, 61, 56, 245)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 15.0),

            // Campo monto
            TextField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 232, 232, 236),
                hintText: 'Monto',
                hintStyle: const TextStyle(color: Colors.black, fontSize: 14.0),
                prefixIcon: const Icon(Icons.attach_money, 
                    color: Color.fromARGB(255, 61, 56, 245)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 15.0),

            // Campo detalle
            TextField(
              controller: _detalleController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 232, 232, 236),
                hintText: 'Detalle (opcional)',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
                prefixIcon: const Icon(Icons.notes, 
                    color: Color.fromARGB(255, 61, 56, 245)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 20.0),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _guardarIngreso,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Ingreso', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'No hay ingresos registrados este mes',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, 
                    color: Color.fromARGB(255, 61, 56, 245), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resumen por Categorías - ${DateFormat('MMMM yyyy', 'es_ES').format(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 25, 26),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _pieChartIngresos(datos),
            const SizedBox(height: 10),
            if (datos.isNotEmpty) _leyendaIngresos(datos),
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

    final double total = datos.values.reduce((a, b) => a + b);

    return Column(
      children: [
        const Divider(),
        ...datos.entries.map((entry) {
          int index = datos.keys.toList().indexOf(entry.key);
          double porcentaje = (entry.value / total) * 100;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Icon(
                  _obtenerIcono(entry.key),
                  color: colores[index % colores.length],
                  size: 28,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 21, 21, 21),
                        ),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 61, 56, 245),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
