import 'package:cajero/Retiros/ahorro_mano.dart';
import 'package:cajero/Retiros/cuenta_ahorro.dart';
import 'package:cajero/Retiros/nequi.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cajeros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SeleccionRetiro(),
    );
  }
}

class SeleccionRetiro extends StatelessWidget {
  const SeleccionRetiro({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de la pantalla
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cajero Automático"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 15.0 : 20.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: isSmallScreen ? 60 : 80,
                color: Colors.blue,
              ),
              SizedBox(height: isSmallScreen ? 20 : 30),
              Text(
                "¿Dónde prefiere retirar?",
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: isSmallScreen ? 25 : 40),
              
              // Botón para NEQUI
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 50 : 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NequiRetiro(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "NEQUI",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 15 : 20),
              
              // Botón para Ahorro a la Mano
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 50 : 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RetiroCuenta(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.savings, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Ahorro a la Mano",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 15 : 20),
              
              // Botón Cuenta de Ahorro
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 50 : 60,
                child: ElevatedButton(
                 onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AhorroRetiro(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Cuenta de Ahorro",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 25 : 40),
              
              // Espacio adicional para pantallas pequeñas
              SizedBox(height: isSmallScreen ? 15 : 20),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      "Seleccione una opción para continuar con su retiro",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}