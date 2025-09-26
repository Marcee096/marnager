import 'package:flutter/material.dart';

class IngresosPage extends StatefulWidget {
  const IngresosPage({super.key});

  @override
  State<IngresosPage> createState() => _IngresosPageState();
}

class _IngresosPageState extends State<IngresosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
      ),
      body: const Center(
        child: Text('Bienvenido a la página de Ingresos'),
      ),
    );
  }
}