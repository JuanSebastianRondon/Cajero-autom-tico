import 'package:flutter/material.dart';

class RetiroCuenta extends StatefulWidget {
  const RetiroCuenta({super.key});

  @override
  _RetiroCuentaState createState() => _RetiroCuentaState();
}

class _RetiroCuentaState extends State<RetiroCuenta> {
   final TextEditingController _celularController = TextEditingController();
  String? claveTemporal;

  

final List<String> _numerosGuardados = [
    '13001234567',
    '03101234567',
  ];
   final List<int> _retirosFijos = [
    20000,
    50000,
    100000,
    200000,
    300000,
    500000,
  ];
   bool _existeNumero(String numero) {
    return _numerosGuardados.contains(numero);
  }

  String? _validarCelular(String celular) {
    if (!RegExp(r'^\d{10}$').hasMatch(celular)) {
      return "Por favor ingrese un número de celular válido de 10 dígitos.";
    }
      if (!_existeNumero(celular)) {
        return "Número no existente. Intente de nuevo.";
      }
      return null; 
    }
     void _validarYMostrarReporte() {
    String celular = _celularController.text;

    // Validar el número de celular
    String? error = _validarCelular(celular);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: error.contains("existente") ? Colors.red : null,
        ),
      );
      return;
    }
     }
     
       @override
       Widget build(BuildContext context) {
         // TODO: implement build
         throw UnimplementedError();
       }
}