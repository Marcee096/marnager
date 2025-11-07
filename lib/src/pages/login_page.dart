import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marnager/src/pages/home_page.dart';
import 'package:marnager/src/pages/registro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Función para validar si es un email válido
  bool _esEmailValido(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> iniciarSesion() async {
    final usuario = usuarioController.text.trim();
    final pass = passwordController.text.trim();

    // Validar campos vacíos
    if (usuario.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      // Determinar si el usuario es un email válido o no
      String email;
      if (_esEmailValido(usuario)) {
        // Si es un email válido, usar directamente
        email = usuario;
      } else {
        // Si no es un email válido, agregar @app.com
        email = '$usuario@app.com';
      }

      // Intentar iniciar sesión
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      
      print('Inicio de sesión exitoso: ${cred.user?.uid}');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Mostrar SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Navegar al Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

    
      String mensaje = 'Error al iniciar sesión';
      bool mostrarRegistro = false;
      
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'Usuario no registrado. ¡Regístrate para acceder!';
          mostrarRegistro = true;
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta. Intenta nuevamente';
          break;
        case 'invalid-email':
          mensaje = 'El formato del email no es válido';
          break;
        case 'user-disabled':
          mensaje = 'Esta cuenta ha sido deshabilitada';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Intenta más tarde';
          break;
        case 'network-request-failed':
          mensaje = 'Error de conexión. Verifica tu internet';
          break;
        case 'invalid-credential':
          mensaje = 'Usuario o contraseña incorrectos. Verifica tus datos';
          mostrarRegistro = true;
          break;
        case 'configuration-not-found':
          mensaje = 'Firebase no está configurado correctamente';
          break;
        default:
          mensaje = 'Error: ${e.code} - ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: mostrarRegistro ? Colors.orange : Colors.red,
            duration: const Duration(seconds: 4),
            action: mostrarRegistro
                ? SnackBarAction(
                    label: 'Registrarme',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroPage(),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

  

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 61, 56, 245),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 61, 56, 245)),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Email o usuario',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 96, 93, 93),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    helperText: 'Ej: usuario123 o email@ejemplo.com',
                    helperStyle: TextStyle(fontSize: 11),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 96, 93, 93),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad en desarrollo'),
                        ),
                      );
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 20.0,
                  ),
                  backgroundColor: const Color.fromARGB(255, 30, 26, 165),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : iniciarSesion,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistroPage(),
                    ),
                  );
                },
                child: const Text(
                  "Registrarme",
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Indicador de carga en pantalla completa
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
