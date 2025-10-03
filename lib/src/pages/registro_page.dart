import 'package:flutter/material.dart';
import 'package:fluid_dropdown_input/fluid_dropdown_input.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  RegistroPageState createState() => RegistroPageState();
}

class RegistroPageState extends State<RegistroPage> {
  final List<String> _opciones = [
    'Sin dato',
    'Emprendedor',
    'Estudiante',
    'Empleado',
    'Desempleado',
    'Jubilado',
  ];

  final List<Map<String, dynamic>> _localidades = [
    {'id': 1, 'localidad': "25 de Mayo"},
    {'id': 2, 'localidad': "Albardón"},
    {'id': 3, 'localidad': "Angaco"},
    {'id': 4, 'localidad': "Calingasta"},
    {'id': 5, 'localidad': "Capital"},
    {'id': 6, 'localidad': "Caucete"},
    {'id': 7, 'localidad': "Chimbas"},
    {'id': 8, 'localidad': "Iglesia"},
    {'id': 9, 'localidad': "Jáchal"},
    {'id': 10, 'localidad': "9 de Julio"},
    {'id': 11, 'localidad': "Pocito"},
    {'id': 12, 'localidad': "Rawson"},
    {'id': 13, 'localidad': "Rivadavia"},
    {'id': 14, 'localidad': "San Martín"},
    {'id': 15, 'localidad': "Santa Lucía"},
    {'id': 16, 'localidad': "Sarmiento"},
    {'id': 17, 'localidad': "Ullum"},
    {'id': 18, 'localidad': "Valle Fértil"},
    {'id': 19, 'localidad': "Zonda"},
  ];

  int? localidadSeleccionada;
  String _opcionSeleccionadaDropdown = 'Sin dato';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 56, 245),
      appBar: AppBar(backgroundColor: Colors.white),
      body: ListView(
        children: [
          // Figura que ocupa el 30% superior
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3, // 30% de la altura de la pantalla
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  right: -100, // Para que se salga un poco del borde derecho
                  top: -50,      // Pegado arriba
                  child: Container(
                    width: 400,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle, // Cambiar a círculo
                      color: Colors.white,  
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  left: -50, // Para que se salga un poco del borde derecho
                  top: -50, 
                  child: Transform.rotate(
                    angle: -0.2, // Rotar ligeramente en sentido antihorario)
                  child: Container(
                    width: 270,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle, // Cambiar a círculo
                      color: Colors.white,  
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email o usuario',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 96, 93, 93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Contaseña',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 96, 93, 93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Confirmar contaseña',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 96, 93, 93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  _crearDropdown(),
                  const SizedBox(height: 32),
                  _crearFluidDropdown(),
                  const SizedBox(height: 32),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                      backgroundColor: Color.fromARGB(255, 30, 26, 165),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Acción para registrarse
                    },
                    child: Text(
                      "Registrarme",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> getOpcionesDropdown() {
    List<DropdownMenuItem<String>> lista = [];
    for (var opcion in _opciones) {
      lista.add(
        DropdownMenuItem(
          value: opcion,
          child: Text(
            opcion,
            style: const TextStyle(
              color: Colors.white,
            ), // Texto blanco en los items
          ),
        ),
      );
    }
    return lista;
  }

  Widget _crearDropdown() {
    return Row(
      children: <Widget>[
        const Icon (Icons.select_all, color: Colors.white),
        const SizedBox(width: 30.0),
        Expanded(
          child: DropdownButton(
            value: _opcionSeleccionadaDropdown,
            dropdownColor: Color.fromARGB(255, 61, 56, 245), // Color de fondo del dropdown
            items: getOpcionesDropdown(),
            onChanged: (opt) {
              setState(() {
                _opcionSeleccionadaDropdown = opt.toString();
              });
            },
          ),
        ),
      ],
    );
  }

  List<DropdownItem> getLocalidadesDropdown() {
    return _localidades.map((localidad) =>
          DropdownItem(
            id: localidad['id'],
            label: localidad['localidad']
        )
    ).toList();
  }

  InputDecoration _decoration(){
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText:'Localidad',
      labelText: 'Localidad',
      suffixIcon: const Icon(Icons.arrow_drop_down),
      icon: const Icon(Icons.pin_drop_outlined, color: Colors.white), 
      
    );
  }

  Widget _crearFluidDropdown() {
  return Row(
    children: <Widget>[
      Expanded(
        child: FluidDropdownInput(
          decorationBuilder: (d) => _decoration(),
          languageCode: 'es',
          items: getLocalidadesDropdown(),
          valueId: localidadSeleccionada,
          onChanged: (it) => setState(() => localidadSeleccionada = it?.id),
          searchEnabled: true,
        ),
      ),
      const Divider(height: 32),
    ],
  );
}

String? getLocalidad() {
  var localidad = _localidades.firstWhere(
    (l) => l['id'] == localidadSeleccionada,
    orElse: () => {'id': null, 'localidad': null},
  );
  return localidad['localidad'];
}


}
