import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marnager/src/pages/login_page.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marnager',
      debugShowCheckedModeBanner: false,
      
      // Agregar estas líneas para configurar las localizaciones
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés (opcional)
      ],
      locale: const Locale('es', 'ES'), // Locale por defecto
      
      // ...resto de tu configuración (theme, home, routes, etc.)
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // ...tu tema...
      ),
      home: const LoginPage(),
    );
  }
}