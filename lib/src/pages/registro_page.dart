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
        // Si ya contiene @, usar como email directamente
        email = usuario;
      } else {
        // Si no, agregar @app.com
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
        // Mostrar SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

       

        // Esperar un momento para que se vea el SnackBar
        await Future.delayed(const Duration(seconds: 1));

        // Redirigir al Login
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
      appBar: AppBar(backgroundColor: Colors.white),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 96, 93, 93),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    TextField(
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
                    const SizedBox(height: 16),
                    TextField(
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmController,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 96, 93, 93),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                        backgroundColor: const Color.fromARGB(255, 30, 26, 165),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : registrarUsuario,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Registrarme",
                              style: TextStyle(fontSize: 16),
                            ),
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
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
