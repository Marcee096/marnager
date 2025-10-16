import 'package:flutter/material.dart';
import 'package:marnager/src/pages/ahorros_page.dart' show AhorrosPage;
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';

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
        children: [_cardFuente(), _cardCargaIngreso()],
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

  Widget _cardCargaIngreso() {
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            const Text('Carga de datos'),
            const SizedBox(height: 15.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                hintText: 'Adjuntar comprobante',
                hintStyle: const TextStyle(color: Colors.black),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.black),
                  onPressed: () {
                    // Acción para adjuntar archivo
                  },
                 
                ),
                
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15.0),
            const Text('Carga manual'),
            const SizedBox(height: 15.0),
            _crearDropdownCuentas(),
            const SizedBox(height: 15.0),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                hintText: 'Monto',
                hintStyle: const TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 15.0),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                hintText: 'Detalle (opcional)',
                hintStyle: const TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
