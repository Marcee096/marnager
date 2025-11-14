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
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 61, 56, 245),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo centrado
                    Center(
                      child: ClipRRect(
                        child: Image.asset(
                          'assets/images/logologuin.png',
                          width: 160,  
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.account_balance_wallet,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                    
                    // Campo de usuario
                    TextField(
                      controller: usuarioController,
                      decoration: InputDecoration(
                        labelText: 'Email o usuario',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 96, 93, 93),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        helperText: 'Ej: usuario123 o email@ejemplo.com',
                        helperStyle: const TextStyle(
                          fontSize: 11, 
                          color: Color.fromARGB(214, 226, 223, 223)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color.fromARGB(255, 61, 56, 245),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de contraseña
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 96, 93, 93),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Color.fromARGB(255, 61, 56, 245),
                        ),
                      ),
                      obscureText: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Olvidaste tu contraseña
                    Align(
                      alignment: Alignment.centerRight,
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
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 30, 26, 165),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _isLoading ? null : iniciarSesion,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // No tienes cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿No tienes cuenta? ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Indicador de carga en pantalla completa
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Iniciando sesión...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
