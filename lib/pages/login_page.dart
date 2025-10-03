import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 56, 245),
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 61, 56, 245)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
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
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
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
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  // Acción para recuperar contraseña
                  // Navigator.pushNamed(context, '/forgot-password');
                },
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Colors.white,
                    decoration:
                        TextDecoration.underline, // Subrayado para parecer link
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              backgroundColor: Color.fromARGB(255, 30, 26, 165),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón
            },
            child: const Text('Iniciar sesión'),
          ),
          const SizedBox(height: 16),
          // Convertir "Regístrate" en link
          GestureDetector(
            onTap: () {
              // Acción para registrarse
              // Navigator.pushNamed(context, '/register');
            },
            child: Text(
              "Registrarme",
              style: TextStyle(
                color: Colors.white,
                decoration:
                    TextDecoration.underline, // Subrayado para parecer link
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
