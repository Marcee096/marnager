import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  RegistroPageState createState() => RegistroPageState();
}

class RegistroPageState extends State<RegistroPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  void dispose() {
    nombreController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final usuario = usuarioController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // Validar campos vacíos
    if (nombre.isEmpty || usuario.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    // Validar que las contraseñas coincidan
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    // Validar longitud mínima de contraseña
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determinar si el usuario ya es un email o no
      String email;
      if (usuario.contains('@')) {
        email = usuario;
      } else {
        email = '$usuario@app.com';
      }
      
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // Guardar datos en Firestore
      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'nombre': nombre,
        'usuario': usuario,
        'email': email,
        'password': pass,
        'creadoEn': Timestamp.now(),
      });

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String mensaje = 'Error al registrar';
      
      switch (e.code) {
        case 'weak-password':
          mensaje = 'La contraseña es muy débil (mínimo 6 caracteres)';
          break;
        case 'email-already-in-use':
          mensaje = 'El email/usuario ya está en uso';
          break;
        case 'invalid-email':
          mensaje = 'El formato del email no es válido';
          break;
        case 'operation-not-allowed':
          mensaje = 'Operación no permitida. Verifica la configuración de Firebase';
          break;
        case 'network-request-failed':
          mensaje = 'Error de conexión. Verifica tu internet';
          break;
        case 'configuration-not-found':
          mensaje = 'Firebase no está configurado correctamente. Verifica google-services.json';
          break;
        default:
          mensaje = 'Error: ${e.code} - ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on FirebaseException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de Firebase: ${e.code} - ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              // Figura que ocupa el 30% superior
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Figuras blancas de fondo
                    Positioned(
                      right: -100,
                      top: -50,
                      child: Container(
                        width: 400,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -50,
                      top: -50,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Container(
                          width: 270,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    
                    // Imagen a la derecha sin contenedor ni bordes
                    Positioned(
                      right: 20,
                      top: 50,
                      child: Image.asset(
                        'assets/images/logoregister.png',
                        width: 140,
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 80,
                            color: Color.fromARGB(255, 61, 56, 245),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de nombre
                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
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
                          Icons.person_outline,
                          color: Color.fromARGB(255, 61, 56, 245),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                          color: Color.fromARGB(214, 226, 223, 223),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color.fromARGB(255, 61, 56, 245),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Campo de confirmar contraseña
                    TextField(
                      controller: confirmController,
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de registrarse
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
                        onPressed: _isLoading ? null : registrarUsuario,
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
                                'Registrarme',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Ya tienes cuenta
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿Ya tienes cuenta? ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Iniciar sesión",
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
            ],
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
                      'Registrando usuario...',
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
