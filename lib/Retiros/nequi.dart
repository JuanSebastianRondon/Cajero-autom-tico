import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class NequiRetiro extends StatefulWidget {
  const NequiRetiro({super.key});

  @override
  _NequiRetiroState createState() => _NequiRetiroState();
}

class _NequiRetiroState extends State<NequiRetiro> {
  final TextEditingController _celularController = TextEditingController();
  String? claveTemporal;
  Timer? _timer;
  int tiempoRestante = 0;
  bool _claveRenovada = false;
  bool _celularValidado = false;
  
  // Variables para el sistema de retiros
  final TextEditingController _montoController = TextEditingController();
  int? _montoSeleccionado;
  Map<int, int> _billetesCalculados = {};
  int _totalBilletes = 0;
  
  final List<String> _numerosGuardados = [
    '3001234567',
    '3109876543',
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

  void _generarClave() {
    String celular = _celularController.text;
    
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

    final random = Random();
    final clave = List.generate(6, (_) => random.nextInt(10)).join();

    setState(() {
      claveTemporal = clave;
      tiempoRestante = 60;
      _claveRenovada = false;
      _celularValidado = true; // Marcar celular como validado
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        tiempoRestante--;
        if (tiempoRestante <= 0 && _celularValidado) {
          // Generar nueva clave automáticamente solo si el celular fue validado
          _generarNuevaClave();
        } else if (tiempoRestante <= 0 && !_celularValidado) {
          // Si no está validado, solo limpiar la clave
        timer.cancel();
          claveTemporal = null;
          tiempoRestante = 0;
        }
      });
    });
  }

  // Función para resetear el estado cuando cambie el celular
  void _resetearEstado() {
    _timer?.cancel();
    setState(() {
      claveTemporal = null;
      tiempoRestante = 0;
      _claveRenovada = false;
      _celularValidado = false;
    });
  }

  // Función para generar nueva clave automáticamente (sin validar celular)
  void _generarNuevaClave() {
    final random = Random();
    final clave = List.generate(6, (_) => random.nextInt(10)).join();

    setState(() {
      claveTemporal = clave;
      tiempoRestante = 60;
      _claveRenovada = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(" Clave se renovará automáticamente"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
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
    _mostrarSistemaRetiros(celular);
  }

  // Función principal del sistema de retiros
  void _mostrarSistemaRetiros(String celular) {
      showDialog(
        context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Sistema de Retiros"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Celular: 0$celular", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                const Text("Retiros Fijos:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _retirosFijos.map((monto) => 
                    GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _montoSeleccionado = monto;
                          _montoController.text = monto.toString();
                          _calcularYMostrarBilletes(monto);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _montoSeleccionado == monto ? Colors.green : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _montoSeleccionado == monto ? Colors.green : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          "\$${monto.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                            (Match m) => '${m[1]}.'
                          )}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _montoSeleccionado == monto ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 16),
                
                const Text("Valor Libre:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _montoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Ingrese monto",
                    hintText: "Ej: 75000",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setDialogState(() {
                        _montoSeleccionado = null;
                      });
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          int monto = _montoSeleccionado ?? int.tryParse(_montoController.text) ?? 0;
                          if (monto > 0) {
                            setDialogState(() {
                              _calcularYMostrarBilletes(monto);
                            });
                          }
                        },
                        child: const Text("Retirar"),
                      ),
                    ),
                
                  ],
                ),
                
                // Resultado de billetes
                if (_billetesCalculados.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Billetes a Dispensar:", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._billetesCalculados.entries.map((entry) => 
                          Text("• ${entry.value} billete(s) de \$${entry.key.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                            (Match m) => '${m[1]}.'
                          )}")
                        ).toList(),
                        const SizedBox(height: 8),
                        Text("Total billetes: $_totalBilletes", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _montoController.clear();
                _montoSeleccionado = null;
                _billetesCalculados.clear();
                _totalBilletes = 0;
                Navigator.pop(context);
              },
              child: const Text("Cerrar"),
            ),
            if (_billetesCalculados.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _procesarRetiro(celular);
                  Navigator.pop(context);
                },
                child: const Text("Procesar Retiro"),
              ),
          ],
        ),
      ),
    );
  }

void _calcularYMostrarBilletes(int monto) {
  if (monto % 10000 != 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("No se puede retirar \$${_formatearMonto(monto)}."),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    return;
  }
  _billetesCalculados.clear();
  
  Map<int, int> billetes = {
    100000: 0,
    50000: 0,
    20000: 0,
    10000: 0,
  };

  int resto = monto;
  
  List<int> denominaciones = [100000, 50000, 20000, 10000];
  
  for (int denominacion in denominaciones) {
    if (resto >= denominacion) {
      billetes[denominacion] = resto ~/ denominacion; // Cantidad de billetes
      resto = resto % denominacion;                   // Actualizar el residuo
    }
  }

  if (resto != 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "No se puede retirar \$${_formatearMonto(monto)}. "
          "Solo disponemos de billetes de \$10.000, \$20.000, \$50.000 y \$100.000"
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    return;
  }

  _billetesCalculados = billetes;
  _totalBilletes = billetes.values.fold(0, (sum, cantidad) => sum + cantidad);
  _montoSeleccionado = monto;

  String reporte = "Retiro de \$${_formatearMonto(monto)}\n\n";
  reporte += "Billetes dispensados:\n";
  
  bool hayBilletes = false;
  for (MapEntry<int, int> entry in billetes.entries) {
    if (entry.value > 0) {
      reporte += "• ${entry.value} billete(s) de \$${_formatearMonto(entry.key)}\n";
      hayBilletes = true;
    }
  }
  
  if (!hayBilletes) {
    reporte += "Error en el cálculo de billetes";
  } else {
    reporte += "\nTotal de billetes: $_totalBilletes";
    
    // Calcular retiros restantes estimados
    int retirosRestantes = _calcularRetirosRestantes();
    reporte += "\nRetiros estimados restantes: $retirosRestantes";
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Desglose de Billetes"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_wallet, size: 40, color: Colors.green),
            const SizedBox(height: 10),
            Text(
              reporte,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Aquí puedes llamar a _procesarRetiro si quieres proceder
            _mostrarConfirmacionRetiro();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirmar Retiro"),
        ),
      ],
    ),
  );
}


String _formatearMonto(int monto) {
  return monto.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]}.'
  );
}

int _calcularRetirosRestantes() {
  // Inventario simulado del cajero
  int inventario100k = 50;
  int inventario50k = 100;
  int inventario20k = 150;
  int inventario10k = 200;
  
  // Calcular dinero total disponible
  int totalDisponible = (inventario100k * 100000) + 
                       (inventario50k * 50000) + 
                       (inventario20k * 20000) + 
                       (inventario10k * 10000);
  
  // Estimar retiros promedio de $100,000
  return totalDisponible ~/ 100000;
}

// Método para mostrar confirmación antes del retiro final
void _mostrarConfirmacionRetiro() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirmar Transacción"),
      content: Text(
        "¿Confirma que desea retirar \$${_formatearMonto(_montoSeleccionado!)}?\n\n"
        "Se dispensarán $_totalBilletes billetes."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Aquí llamarías a tu método _procesarRetiro original
            _procesarRetiro(_celularController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text("Confirmar"),
        ),
      ],
    ),
  );
}
  void _procesarRetiro(String celular) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Retiro Exitoso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(" Retiro procesado correctamente", 
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Celular: $celular"),
            const SizedBox(height: 8),
            Text("Monto: \$${(_montoSeleccionado ?? int.parse(_montoController.text)).toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
              (Match m) => '${m[1]}.'
            )}"),
            const SizedBox(height: 8),
            const Text("Billetes dispensados:", style: TextStyle(fontWeight: FontWeight.bold)),
            ..._billetesCalculados.entries.map((entry) => 
              Text("• ${entry.value} billete(s) de \$${entry.key.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                (Match m) => '${m[1]}.'
              )}")
            ),
            const SizedBox(height: 8),
            Text("Total billetes: $_totalBilletes", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _montoController.clear();
              _montoSeleccionado = null;
              _billetesCalculados.clear();
              _totalBilletes = 0;
              Navigator.pop(context);
            },
            child: const Text("Nuevo Retiro"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celularController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Retiro NEQUI")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _celularController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                // Resetear estado cuando cambie el número
                if (_celularValidado) {
                  _resetearEstado();
                }
              },
              decoration: const InputDecoration(
                labelText: "Número de celular",
                hintText: "Ingrese su número de celular",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: _generarClave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Clave Dinamica"),
              ),
            ),
            if (claveTemporal != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        const Text(
                          "Clave Dinamica",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (_claveRenovada) ...[ 
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.autorenew,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      claveTemporal!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tiempo restante: $tiempoRestante segundos",
                      style: TextStyle(
                        color: tiempoRestante <= 10 ? Colors.red : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
              onPressed: _validarYMostrarReporte,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Ir a Retiros"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}