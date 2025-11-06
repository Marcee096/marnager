import 'package:flutter/material.dart';


class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  RegistroPageState createState() => RegistroPageState();
}

class RegistroPageState extends State<RegistroPage> {

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
                      labelText: 'Nombre',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 96, 93, 93),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
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



}
