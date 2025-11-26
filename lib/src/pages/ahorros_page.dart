import 'package:flutter/material.dart';
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:marnager/src/pages/ingresos_page.dart';
import 'package:marnager/src/pages/registros_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/firebase_services.dart';
import '../models/ahorro.dart';

class AhorrosPage extends StatefulWidget {
  const AhorrosPage({super.key});

  @override
  State<AhorrosPage> createState() => _AhorrosPageState();
}

class _AhorrosPageState extends State<AhorrosPage> {
  String? ahorroSeleccionado;

  // Controladores para los campos de texto
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _subcategoriaController = TextEditingController();

  // Fecha seleccionada
  DateTime _fechaSeleccionada = DateTime.now();

  // Instancia del servicio de Firebase
  final FirebaseServices _firebaseServices = FirebaseServices.instance;

  // Variables para almacenar datos de Firebase
  List<Ahorro> _ahorrosList = [];
  List<String> _categorias = [];
  List<String> _subcategoriasDisponibles = [];
  bool _isLoading = true;
  bool _mostrarCategorias = false;
  bool _mostrarSubcategorias = false;

  // Mes y año seleccionado
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;

  // Para el gráfico
  String? _categoriaGraficoSeleccionada;
  bool _vistaSubcategorias = false;

  // Mapas de íconos
  final Map<String, IconData> _iconosSubcategorias = {};
  final Map<String, IconData> _iconosCategorias = {};
  
  // Para manejo de imágenes
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await initializeDateFormatting('es_ES', null);
    _cargarDatosFirebase();
    _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
  }

  @override
  void dispose() {
    _montoController.dispose();
    _detalleController.dispose();
    _fechaController.dispose();
    _categoriaController.dispose();
    _subcategoriaController.dispose();
    super.dispose();
  }

  // Cargar datos desde Firebase
  Future<void> _cargarDatosFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ahorros = await _firebaseServices.getAllAhorros();
      
      final categoriasSet = ahorros.map((a) => a.categoria).toSet();
      final categoriasList = categoriasSet.toList();

      final ahorrosDelMes = await _firebaseServices.getAhorrosByMonth(_mesSeleccionado, _anioSeleccionado);

      // Asignar íconos
      for (var ahorro in ahorros) {
        if (!_iconosSubcategorias.containsKey(ahorro.subcategoria)) {
          _iconosSubcategorias[ahorro.subcategoria] = _asignarIcono(ahorro.subcategoria);
        }
        if (!_iconosCategorias.containsKey(ahorro.categoria)) {
          _iconosCategorias[ahorro.categoria] = _asignarIconoCategoria(ahorro.categoria);
        }
      }

      setState(() {
        _ahorrosList = ahorrosDelMes ;
        _categorias = categoriasList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ahorrosList = [];
        _categorias = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  // Actualizar subcategorías disponibles
  Future<void> _actualizarSubcategorias(String categoria) async {
    final todosLosAhorros = await _firebaseServices.getAllAhorros();
    
    final subcategorias = todosLosAhorros
        .where((a) => a.categoria == categoria)
        .map((a) => a.subcategoria)
        .toSet()
        .toList();

    setState(() {
      _subcategoriasDisponibles = subcategorias;
    });
  }

  // Asignar icono para categorías
  IconData _asignarIconoCategoria(String categoria) {
    final categoriaLower = categoria.toLowerCase();
    
    if (categoriaLower.contains('vacaciones') || categoriaLower.contains('viaje')) {
      return Icons.flight;
    } else if (categoriaLower.contains('emergencia') || categoriaLower.contains('fondo')) {
      return Icons.shield;
    } else if (categoriaLower.contains('jubilación') || categoriaLower.contains('retiro')) {
      return Icons.elderly;
    } else if (categoriaLower.contains('educación') || categoriaLower.contains('estudio')) {
      return Icons.school;
    } else if (categoriaLower.contains('casa') || categoriaLower.contains('hogar')) {
      return Icons.home;
    } else if (categoriaLower.contains('auto') || categoriaLower.contains('vehículo')) {
      return Icons.directions_car;
    } else if (categoriaLower.contains('inversión')) {
      return Icons.trending_up;
    } else if (categoriaLower.contains('navidad') || categoriaLower.contains('regalo')) {
      return Icons.card_giftcard;
    } else if (categoriaLower.contains('boda') || categoriaLower.contains('matrimonio')) {
      return Icons.favorite;
    } else if (categoriaLower.contains('cumpleaños') || categoriaLower.contains('celebración')) {
      return Icons.cake;
    } else {
      return Icons.savings;
    }
  }

  // Asignar icono para subcategorías
  IconData _asignarIcono(String subcategoria) {
    final subcategoriaLower = subcategoria.toLowerCase();
    
    if (subcategoriaLower.contains('boletos') || subcategoriaLower.contains('pasajes')) {
      return Icons.flight_takeoff;
    } else if (subcategoriaLower.contains('hotel') || subcategoriaLower.contains('alojamiento')) {
      return Icons.hotel;
    } else if (subcategoriaLower.contains('emergencia') || subcategoriaLower.contains('urgencia')) {
      return Icons.local_hospital;
    } else if (subcategoriaLower.contains('matrícula') || subcategoriaLower.contains('colegiatura')) {
      return Icons.school;
    } else if (subcategoriaLower.contains('inicial') || subcategoriaLower.contains('enganche')) {
      return Icons.account_balance;
    } else if (subcategoriaLower.contains('decoración') || subcategoriaLower.contains('muebles')) {
      return Icons.chair;
    } else if (subcategoriaLower.contains('fiestas') || subcategoriaLower.contains('celebración')) {
      return Icons.celebration;
    } else if (subcategoriaLower.contains('regalo')) {
      return Icons.redeem;
    } else {
      return Icons.savings_outlined;
    }
  }

  // Mostrar selector de fecha
  Future<void> _seleccionarFecha() async {
    final DateTime hoy = DateTime.now();
    final DateTime unAnioAtras = DateTime(hoy.year - 1, hoy.month, hoy.day);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada.isAfter(hoy) 
          ? hoy 
          : (_fechaSeleccionada.isBefore(unAnioAtras) ? unAnioAtras : _fechaSeleccionada),
      firstDate: unAnioAtras,  // Solo puede seleccionar desde hace 1 año
      lastDate: hoy,            // Solo puede seleccionar hasta hoy
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

  // Seleccionar categoría
  void _seleccionarCategoria(String categoria) {
    setState(() {
      _categoriaController.text = categoria;
      _mostrarCategorias = false;
      _subcategoriaController.clear();
    });
    _actualizarSubcategorias(categoria);
  }

  // Seleccionar subcategoría
  void _seleccionarSubcategoria(String subcategoria) {
    setState(() {
      _subcategoriaController.text = subcategoria;
      ahorroSeleccionado = subcategoria;
      _mostrarSubcategorias = false;
    });
  }

  // Seleccionar imagen desde la cámara
  Future<void> _tomarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenSeleccionada = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📷 Foto capturada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al tomar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Subir imagen a Firebase Storage
  Future<String?> _subirImagenAFirebase() async {
    if (_imagenSeleccionada == null) return null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final String fileName = 'ahorros/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      final UploadTask uploadTask = storageRef.putFile(_imagenSeleccionada!);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Seleccionar imagen desde la galería
  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenSeleccionada = File(image.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🖼️ Imagen seleccionada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Mostrar opciones para adjuntar archivo
  void _mostrarOpcionesAdjuntar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color.fromARGB(255, 61, 56, 245),
                  ),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _tomarFoto();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color.fromARGB(255, 61, 56, 245),
                  ),
                  title: const Text('Seleccionar de galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarImagen(ImageSource.gallery);
                  },
                ),
                if (_imagenSeleccionada != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text('Eliminar imagen'),
                    onTap: () {
                      setState(() {
                        _imagenSeleccionada = null;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Imagen eliminada'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Guardar ahorro
  Future<void> _guardarAhorro() async {
    if (_categoriaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese o seleccione una categoría'),
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
      final categoria = _categoriaController.text.trim();
      final subcategoria = _subcategoriaController.text.trim();
      
      if (!_iconosSubcategorias.containsKey(subcategoria)) {
        _iconosSubcategorias[subcategoria] = _asignarIcono(subcategoria);
      }
      
      if (!_iconosCategorias.containsKey(categoria)) {
        _iconosCategorias[categoria] = _asignarIconoCategoria(categoria);
      }

      // Subir imagen a Firebase Storage si existe
      String? urlComprobante;
      if (_imagenSeleccionada != null) {
        urlComprobante = await _subirImagenAFirebase();
      }

      final nuevoAhorro = Ahorro(
        id: '',
        categoria: categoria,
        subcategoria: subcategoria,
        monto: monto,
        fecha: _fechaSeleccionada,
        detalle: detalle.isNotEmpty ? detalle : null,
        comprobante: urlComprobante,
      );

      await _firebaseServices.insertAhorro(nuevoAhorro);

      setState(() {
        ahorroSeleccionado = null;
        _montoController.clear();
        _detalleController.clear();
        _categoriaController.clear();
        _subcategoriaController.clear();
        _fechaSeleccionada = DateTime.now();
        _fechaController.text = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);
        _subcategoriasDisponibles = [];
        _imagenSeleccionada = null;
      });

      await _cargarDatosFirebase();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ahorro guardado exitosamente'),
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

  // Obtener icono
  IconData _obtenerIcono(String nombre) {
    return _iconosCategorias[nombre] ?? 
           _iconosSubcategorias[nombre] ?? 
           Icons.savings;
  }

  // Obtener datos para gráfico
  Map<String, double> _obtenerDatosParaGrafico() {
    if (_ahorrosList.isEmpty) {
      return {};
    }

    if (_vistaSubcategorias && _categoriaGraficoSeleccionada != null) {
      Map<String, double> subcategorias = {};
      
      try {
        var ahorrosFiltrados = _ahorrosList
            .where((ahorro) => ahorro.categoria == _categoriaGraficoSeleccionada)
            .toList();
        
        for (var ahorro in ahorrosFiltrados) {
          subcategorias[ahorro.subcategoria] = 
              (subcategorias[ahorro.subcategoria] ?? 0.0) + ahorro.monto;
        }
      } catch (e) {
        return {};
      }
      
      return subcategorias;
    } else {
      Map<String, double> categoriasPrincipales = {};
      
      try {
        for (var ahorro in _ahorrosList) {
          categoriasPrincipales[ahorro.categoria] = 
              (categoriasPrincipales[ahorro.categoria] ?? 0.0) + ahorro.monto;
        }
      } catch (e) {
        return {};
      }
      
      return categoriasPrincipales;
    }
  }

  // Cambiar mes
  void _cambiarMes(int delta) {
    setState(() {
      _mesSeleccionado += delta;
      if (_mesSeleccionado > 12) {
        _mesSeleccionado = 1;
        _anioSeleccionado++;
      } else if (_mesSeleccionado < 1) {
        _mesSeleccionado = 12;
        _anioSeleccionado--;
      }
    });
    _cargarDatosFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final datosDinamicos = _isLoading ? <String, double>{} : _obtenerDatosParaGrafico();
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ahorros', style: TextStyle(color: Colors.white)),
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
                  _cardCargaAhorro(),
                  _cardGrafico(datosDinamicos),
                  _cardBotonRegistros(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 3:
              // ya estamos en ahorros
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

  Widget _crearCampoCategoria() {
    return Column(
      children: [
        TextField(
          controller: _categoriaController,
          onChanged: (value) {
            if (value.isEmpty) {
              setState(() {
                _mostrarCategorias = false;
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
            hintText: 'Escribe o selecciona categoría',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
            prefixIcon: const Icon(Icons.folder, 
                color: Color.fromARGB(255, 61, 56, 245)),
            suffixIcon: _categorias.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      _mostrarCategorias ? Icons.expand_less : Icons.expand_more,
                      color: const Color.fromARGB(255, 61, 56, 245),
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarCategorias = !_mostrarCategorias;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
          ),
          style: const TextStyle(color: Colors.black),
        ),
        
        if (_mostrarCategorias && _categorias.isNotEmpty)
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
                    'Categorías guardadas:',
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
                  children: _categorias.map((categoria) {
                    final icono = _iconosCategorias[categoria] ?? Icons.folder;
                    return GestureDetector(
                      onTap: () => _seleccionarCategoria(categoria),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 61, 56, 245),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icono,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoria,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
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
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icono,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              subcategoria,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
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

  Widget _cardCargaAhorro() {
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
                const Text(
                  'Nuevo Ahorro',
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
                        onPressed: () => _seleccionarImagen(ImageSource.camera),
                      ),
                      Container(width: 1, height: 20, color: Colors.white),
                      IconButton(
                        icon: const Icon(Icons.attach_file, 
                            color: Color.fromARGB(255, 61, 56, 245), size: 20),
                        onPressed: _mostrarOpcionesAdjuntar,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            _crearCampoCategoria(),
            const SizedBox(height: 15.0),

            _crearCampoSubcategoria(),
            const SizedBox(height: 15.0),

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

            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 61, 56, 245),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _guardarAhorro,
                child: const Text('Guardar', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pieChartAhorros(Map<String, double> datos) {
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
                'No hay ahorros registrados',
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
      const Color(0xffff9800),
      const Color(0xff9c27b0),
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
    final nombreMes = DateFormat('MMMM yyyy', 'es_ES').format(DateTime(_anioSeleccionado, _mesSeleccionado));
    
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => _cambiarMes(-1),
                  color: const Color.fromARGB(255, 61, 56, 245),
                ),
                Text(
                  nombreMes.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 61, 56, 245),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: () => _cambiarMes(1),
                  color: const Color.fromARGB(255, 61, 56, 245),
                ),
              ],
            ),
            
            const Divider(),
            
            if (!_vistaSubcategorias)
              Row(
                children: [
                  const Icon(Icons.pie_chart, 
                      color: Color.fromARGB(255, 61, 56, 245), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Resumen por Categorías',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 25, 25, 26),
                    ),
                  ),
                ],
              ),
            
            if (_vistaSubcategorias && _categoriaGraficoSeleccionada != null)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () {
                      setState(() {
                        _vistaSubcategorias = false;
                        _categoriaGraficoSeleccionada = null;
                      });
                    },
                    color: const Color.fromARGB(255, 61, 56, 245),
                  ),
                  Icon(
                    _obtenerIcono(_categoriaGraficoSeleccionada!),
                    color: const Color.fromARGB(255, 61, 56, 245),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Subcategorías de $_categoriaGraficoSeleccionada',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 25, 25, 26),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 10),
            _pieChartAhorros(datos),
            const SizedBox(height: 10),
            if (datos.isNotEmpty) _leyendaAhorros(datos),
          ],
        ),
      ),
    );
  }

  Widget _leyendaAhorros(Map<String, double> datos) {
    final List<Color> colores = [
      const Color(0xff0293ee),
      const Color(0xfff8b250),
      const Color(0xff845bef),
      const Color(0xff13d38e),
      const Color(0xffff6b6b),
      const Color(0xff4ecdc4),
      const Color(0xffff9800),
      const Color(0xff9c27b0),
    ];

    final double total = datos.values.reduce((a, b) => a + b);

    return Column(
      children: [
        const Divider(),
        ...datos.entries.map((entry) {
          int index = datos.keys.toList().indexOf(entry.key);
          double porcentaje = (entry.value / total) * 100;
          return InkWell(
            onTap: !_vistaSubcategorias ? () {
              setState(() {
                _categoriaGraficoSeleccionada = entry.key;
                _vistaSubcategorias = true;
              });
            } : null,
            child: Padding(
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
                  if (!_vistaSubcategorias)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
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
                'Total Ahorrado:',
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

  // Card con botón para ver registros
  Widget _cardBotonRegistros() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8,
      shadowColor: Colors.black,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrosPage(tabInicial: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.list_alt,
                color: Color.fromARGB(255, 61, 56, 245),
                size: 30,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ver Registros Completos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 61, 56, 245),
                    ),
                  ),
                  Text(
                    'Editar, eliminar y gestionar comprobantes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color.fromARGB(255, 61, 56, 245),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
