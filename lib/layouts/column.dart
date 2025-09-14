import 'package:flutter/material.dart';

class Columna extends StatelessWidget {
  const Columna({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(144, 65, 148, 232),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hola Mundo'),
      ]
    )
    );
  }
}