import 'package:flutter/material.dart';
import 'package:marnager/pages/login_page.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 29, 5, 163)),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}