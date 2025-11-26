import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firebase_services.dart';
import '../models/ingreso.dart';
import '../models/gasto.dart';
import '../models/ahorro.dart';

class RegistrosPage extends StatefulWidget {
  final int tabInicial; // 0: Ingresos, 1: Gastos, 2: Ahorros

  const RegistrosPage({super.key, this.tabInicial = 0});

  @override
  State<RegistrosPage> createState() => _RegistrosPageState();
}

class _RegistrosPageState extends State<RegistrosPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseServices _firebaseServices = FirebaseServices.instance;
  final ImagePicker _picker = ImagePicker();

  List<Ingreso> _ingresos = [];
  List<Gasto> _gastos = [];
  List<Ahorro> _ahorros = [];
  bool _isLoading = true;

  // Mes y año seleccionado
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.tabInicial);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final ingresos = await _firebaseServices.getAllIngresos();
      final gastos = await _firebaseServices.getAllGastos();
      final ahorros = await _firebaseServices.getAllAhorros();

      setState(() {
        _ingresos = ingresos;
        _gastos = gastos;
        _ahorros = ahorros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  void _cambiarMes(int cambio) {
    setState(() {
      _mesSeleccionado += cambio;
      if (_mesSeleccionado > 12) {
        _mesSeleccionado = 1;
        _anioSeleccionado++;
      } else if (_mesSeleccionado < 1) {
        _mesSeleccionado = 12;
        _anioSeleccionado--;
      }
    });
  }

  Future<void> _eliminarIngreso(Ingreso ingreso) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este ingreso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _firebaseServices.deleteIngreso(ingreso.id);
      await _cargarDatos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingreso eliminado')),
      );
    }
  }

  Future<void> _eliminarGasto(Gasto gasto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _firebaseServices.deleteGasto(gasto.id);
      await _cargarDatos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gasto eliminado')),
      );
    }
  }

  Future<void> _eliminarAhorro(Ahorro ahorro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este ahorro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _firebaseServices.deleteAhorro(ahorro.id);
      await _cargarDatos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ahorro eliminado')),
      );
    }
  }

  Future<void> _agregarComprobante(String id, String tipo) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );

        if (image != null) {
          // Mostrar indicador de carga
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          // Subir imagen
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          final String fileName = '$tipo/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          final UploadTask uploadTask = storageRef.putFile(File(image.path));
          final TaskSnapshot snapshot = await uploadTask;
          final String downloadUrl = await snapshot.ref.getDownloadURL();

          // Actualizar el registro
          if (tipo == 'ingresos') {
            final ingreso = _ingresos.firstWhere((i) => i.id == id);
            final actualizado = ingreso.copyWith(comprobante: downloadUrl);
            await _firebaseServices.updateIngreso(actualizado);
          } else if (tipo == 'gastos') {
            final gasto = _gastos.firstWhere((g) => g.id == id);
            final actualizado = gasto.copyWith(comprobante: downloadUrl);
            await _firebaseServices.updateGasto(actualizado);
          } else if (tipo == 'ahorros') {
            final ahorro = _ahorros.firstWhere((a) => a.id == id);
            final actualizado = ahorro.copyWith(comprobante: downloadUrl);
            await _firebaseServices.updateAhorro(actualizado);
          }

          // Cerrar indicador
          if (!mounted) return;
          Navigator.of(context).pop();

          await _cargarDatos();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comprobante agregado exitosamente')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Cerrar indicador
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  void _mostrarComprobante(String? urlComprobante, String tipo) {
    if (urlComprobante == null || urlComprobante.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este registro no tiene comprobante'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Comprobante'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Image.network(
                  urlComprobante,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 10),
                          Text('Error al cargar la imagen'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editarIngreso(Ingreso ingreso) {
    final montoController = TextEditingController(text: ingreso.monto.toString());
    final detalleController = TextEditingController(text: ingreso.detalle ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Ingreso'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detalleController,
                decoration: const InputDecoration(labelText: 'Detalle'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final monto = double.parse(montoController.text);
                final actualizado = ingreso.copyWith(
                  monto: monto,
                  detalle: detalleController.text.trim(),
                );

                await _firebaseServices.updateIngreso(actualizado);

                if (!mounted) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();

                await _cargarDatos();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingreso actualizado')),
                );

              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarGasto(Gasto gasto) {
    final montoController = TextEditingController(text: gasto.monto.toString());
    final detalleController = TextEditingController(text: gasto.detalle ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Gasto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detalleController,
                decoration: const InputDecoration(labelText: 'Detalle'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final monto = double.parse(montoController.text);
                final actualizado = gasto.copyWith(
                  monto: monto,
                  detalle: detalleController.text.trim(),
                );

                await _firebaseServices.updateGasto(actualizado);

                if (!mounted) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();

                await _cargarDatos();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gasto actualizado')),
                );

              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _editarAhorro(Ahorro ahorro) {
    final montoController = TextEditingController(text: ahorro.monto.toString());
    final detalleController = TextEditingController(text: ahorro.detalle ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar Ahorro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detalleController,
                decoration: const InputDecoration(labelText: 'Detalle'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final monto = double.parse(montoController.text);
                final actualizado = ahorro.copyWith(
                  monto: monto,
                  detalle: detalleController.text.trim(),
                );

                await _firebaseServices.updateAhorro(actualizado);

                if (!mounted) return;
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();

                await _cargarDatos();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ahorro actualizado')),
                );

              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros'),
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
            Tab(text: 'Ahorros'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de mes
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        onPressed: () => _cambiarMes(-1),
                        color: const Color.fromARGB(255, 61, 56, 245),
                      ),
                      Text(
                        DateFormat('MMMM yyyy', 'es_ES')
                            .format(DateTime(_anioSeleccionado, _mesSeleccionado))
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
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
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListaIngresos(),
                      _buildListaGastos(),
                      _buildListaAhorros(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildListaIngresos() {
    final ingresosFiltrados = _ingresos.where((ingreso) {
      return ingreso.fecha.month == _mesSeleccionado &&
             ingreso.fecha.year == _anioSeleccionado;
    }).toList();

    ingresosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

    if (ingresosFiltrados.isEmpty) {
      return const Center(
        child: Text('No hay ingresos registrados en este mes'),
      );
    }

    return ListView.builder(
      itemCount: ingresosFiltrados.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final ingreso = ingresosFiltrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              '${ingreso.categoria} - ${ingreso.subcategoria}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(ingreso.fecha)),
                if (ingreso.detalle != null && ingreso.detalle!.isNotEmpty)
                  Text(ingreso.detalle!),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${ingreso.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 61, 56, 245),
                    fontSize: 16,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'comprobante',
                      child: Row(
                        children: [
                          Icon(
                            ingreso.comprobante != null && ingreso.comprobante!.isNotEmpty
                                ? Icons.receipt_long
                                : Icons.add_photo_alternate,
                            color: ingreso.comprobante != null && ingreso.comprobante!.isNotEmpty
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ingreso.comprobante != null && ingreso.comprobante!.isNotEmpty
                                ? 'Ver comprobante'
                                : 'Agregar comprobante',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarIngreso(ingreso);
                    } else if (value == 'comprobante') {
                      if (ingreso.comprobante != null && ingreso.comprobante!.isNotEmpty) {
                        _mostrarComprobante(ingreso.comprobante, 'ingresos');
                      } else {
                        _agregarComprobante(ingreso.id, 'ingresos');
                      }
                    } else if (value == 'eliminar') {
                      _eliminarIngreso(ingreso);
                    }
                  },
                ),
              ],
            ),
            isThreeLine: ingreso.detalle != null && ingreso.detalle!.isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _buildListaGastos() {
    final gastosFiltrados = _gastos.where((gasto) {
      return gasto.fecha.month == _mesSeleccionado &&
             gasto.fecha.year == _anioSeleccionado;
    }).toList();

    gastosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

    if (gastosFiltrados.isEmpty) {
      return const Center(
        child: Text('No hay gastos registrados en este mes'),
      );
    }

    return ListView.builder(
      itemCount: gastosFiltrados.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final gasto = gastosFiltrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              '${gasto.categoria} - ${gasto.subcategoria}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(gasto.fecha)),
                if (gasto.detalle != null && gasto.detalle!.isNotEmpty)
                  Text(gasto.detalle!),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${gasto.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 61, 56, 245),
                    fontSize: 16,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'comprobante',
                      child: Row(
                        children: [
                          Icon(
                            gasto.comprobante != null && gasto.comprobante!.isNotEmpty
                                ? Icons.receipt_long
                                : Icons.add_photo_alternate,
                            color: gasto.comprobante != null && gasto.comprobante!.isNotEmpty
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gasto.comprobante != null && gasto.comprobante!.isNotEmpty
                                ? 'Ver comprobante'
                                : 'Agregar comprobante',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarGasto(gasto);
                    } else if (value == 'comprobante') {
                      if (gasto.comprobante != null && gasto.comprobante!.isNotEmpty) {
                        _mostrarComprobante(gasto.comprobante, 'gastos');
                      } else {
                        _agregarComprobante(gasto.id, 'gastos');
                      }
                    } else if (value == 'eliminar') {
                      _eliminarGasto(gasto);
                    }
                  },
                ),
              ],
            ),
            isThreeLine: gasto.detalle != null && gasto.detalle!.isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _buildListaAhorros() {
    final ahorrosFiltrados = _ahorros.where((ahorro) {
      return ahorro.fecha.month == _mesSeleccionado &&
             ahorro.fecha.year == _anioSeleccionado;
    }).toList();

    ahorrosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

    if (ahorrosFiltrados.isEmpty) {
      return const Center(
        child: Text('No hay ahorros registrados en este mes'),
      );
    }

    return ListView.builder(
      itemCount: ahorrosFiltrados.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final ahorro = ahorrosFiltrados[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
              '${ahorro.categoria} - ${ahorro.subcategoria}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd/MM/yyyy').format(ahorro.fecha)),
                if (ahorro.detalle != null && ahorro.detalle!.isNotEmpty)
                  Text(ahorro.detalle!),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${ahorro.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 61, 56, 245),
                    fontSize: 16,
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'comprobante',
                      child: Row(
                        children: [
                          Icon(
                            ahorro.comprobante != null && ahorro.comprobante!.isNotEmpty
                                ? Icons.receipt_long
                                : Icons.add_photo_alternate,
                            color: ahorro.comprobante != null && ahorro.comprobante!.isNotEmpty
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ahorro.comprobante != null && ahorro.comprobante!.isNotEmpty
                                ? 'Ver comprobante'
                                : 'Agregar comprobante',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarAhorro(ahorro);
                    } else if (value == 'comprobante') {
                      if (ahorro.comprobante != null && ahorro.comprobante!.isNotEmpty) {
                        _mostrarComprobante(ahorro.comprobante, 'ahorros');
                      } else {
                        _agregarComprobante(ahorro.id, 'ahorros');
                      }
                    } else if (value == 'eliminar') {
                      _eliminarAhorro(ahorro);
                    }
                  },
                ),
              ],
            ),
            isThreeLine: ahorro.detalle != null && ahorro.detalle!.isNotEmpty,
          ),
        );
      },
    );
  }
}
