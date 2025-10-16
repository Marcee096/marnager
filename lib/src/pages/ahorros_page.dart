import 'package:flutter/material.dart';
import 'package:marnager/src/pages/gastos_page.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:marnager/src/pages/ingresos_page.dart';

class AhorrosPage extends StatefulWidget {
  const AhorrosPage({super.key});

  @override
  State<AhorrosPage> createState() => _AhorrosPageState();
}

class _AhorrosPageState extends State<AhorrosPage> {

  String? _opcionSeleccionadaDropdown;
  String? ahorroSeleccionado;
  String? cuentaSeleccionada;

  final List<String> _ahorros = [
    //ejemplos, esta lista debe obtenerse de una BD
    'Vacaciones',
    'Cumpleaños',
    'Fondo de Emergencia',
  ];

  final List<String> _cuentas = [
    //ejemplos, esta lista debe obtenerse de una BD
    'Efectivo',
    'Inversion',
    'Vacaciones',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ahorros', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
      ),
      body: ListView(padding: const EdgeInsets.all(8.0), children: [_cardCategoria(), _cardCargaAhorro()]),
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

          // Navegación basada en el índice seleccionado
          switch (index) {
            case 0:
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()));
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

  Widget _cardCategoria() {
    return Card(
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categoria de ahorro'),
            const SizedBox(height: 15.0),
            _crearDropdown(),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var ahorro in _ahorros) {
      lista.add(
        DropdownMenuItem(
          value: ahorro,
          child: Text(
            ahorro,
            style: const TextStyle(color: Colors.white), // Texto blanco en cada opción
          ),
        ),
      );
    }
    return lista;
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
              dropdownColor: const Color.fromARGB(255,61,56,245,), // Color de fondo del menú desplegable
              items: getOpcionesDropdown(),
              onChanged: (opt) {
                setState(() {
                  _opcionSeleccionadaDropdown = opt; // No uses .toString(), usa el valor directamente
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> getOpcionesCuentasDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var cuenta in _cuentas) {
      lista.add(
        DropdownMenuItem(
          value: cuenta,
          child: Text(
            cuenta,
            style: const TextStyle(color: Colors.black), // Texto blanco en cada opción
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
            color: Color.fromARGB(255, 232, 232, 236), // Color de fondo
            borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              value: cuentaSeleccionada,
              hint: const Text(
                'Cuenta',
                style: TextStyle(color: Colors.black),
              ),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black,
              ), // Color del texto seleccionado
              dropdownColor: const Color.fromARGB(255, 61, 56, 245), // Color de fondo del menú desplegable
              items: getOpcionesCuentasDropdown(),
              onChanged: (opt) {
                setState(() {
                  cuentaSeleccionada = opt;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

   Widget _cardCargaAhorro(){
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
