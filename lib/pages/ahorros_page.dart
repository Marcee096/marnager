import 'package:flutter/material.dart';

class AhorrosPage extends StatefulWidget {
  const AhorrosPage({super.key});

  @override
  State<AhorrosPage> createState() => _AhorrosPageState();
}

class _AhorrosPageState extends State<AhorrosPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorros'),
      ),
      body: const Center(
        child: Text('Bienvenido a la página de Ahorros'),
      ),
    );
  }
}
