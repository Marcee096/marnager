import 'package:flutter/material.dart'; //Se importa el paquete math de flutter para calcular la diagonal y se //le genera un alias
import 'dart:math' as math;

class Responsive {
  //Propiedades privadas en la cual se define el ancho, alto y diagonal
  //del dispositivo
  double _width = 0.0, _height = 0.0, _diagonal = 0.0;
  bool _isTablet = false;
  //Al ser privadas las propiedades de las dimensiones, se debe //establecer los respectivos get para acceder a dichos valores
  double get width => _width;
  double get height => _height;
  double get diagonal =>
      _diagonal; //Función estática que retorna una instancia de la clase responsive
  bool get isTablet => _isTablet;

  static Responsive of(BuildContext context) =>
      Responsive(context); //Se crea el constructor de la clase
  Responsive(BuildContext context) {
    //Se obtiene el tamaño del dispositivo y se extraen cada uno de los //parámetros de medida
    final Size size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
    //La diagonal se obtiene utilizando el teorema de pitágoras
    //Esto es la raíz cuadrada de la suma del cuadrado del ancho más el //cuadrado del alto
    //a=ancho
    //b=alto
    //c2 + a2 + b2 => c = srt(a2 + b2)
    //Valor de la diagonal
    _diagonal = math.sqrt(math.pow(_width, 2) + math.pow(_height, 2));
    _isTablet = size.shortestSide >= 600;
  }
  double wp(double percent) => _width * percent / 100;
  double hp(double percent) => _height * percent / 100;
  double dp(double percent) => _diagonal * percent / 100;
}