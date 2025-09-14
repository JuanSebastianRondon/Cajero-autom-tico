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
  
  // Array con números de teléfono guardados
  final List<String> _numerosGuardados = [
    '3001234567',
    '3109876543',
  ];
  
  // Denominaciones de billetes disponibles
  final List<int> _denominaciones = [100000, 50000, 20000, 10000];
  
  // Opciones de retiro fijas
  final List<int> _retirosFijos = [
    20000,
    50000,
    100000,
    200000,
    300000,
    500000,
  ];

  // Función para verificar si el número está guardado
  bool _ExisteNumero(String numero) {
    return _numerosGuardados.contains(numero);
  }

  // Función común para validar el número de celular
  String? _validarCelular(String celular) {
    if (!RegExp(r'^\d{10}$').hasMatch(celular)) {
      return "Por favor ingrese un número de celular válido de 10 dígitos.";
    }
    
    if (!_ExisteNumero(celular)) {
      return "Número no existente. Intente de nuevo.";
    }
    
    return null; 
     }

  // Función para calcular billetes necesarios usando método de acarreo
  Map<int, int> _calcularBilletes(int monto) {
    Map<int, int> billetes = {};
    int resto = monto;
    
 
    for (int i = 0; i < _denominaciones.length; i++) {
      int denominacion = _denominaciones[i];
      if (resto >= denominacion) {
        billetes[denominacion] = resto ~/ denominacion; // cantidad de billetes
        resto = resto % denominacion;                   // actualizar el residuo
      }
    }
    
    return billetes;
  }

  // Función para validar si el monto es válido usando método de acarreo
  bool _esMontoValido(int monto) {
    int resto = monto;
    
    // Usar el método de acarreo para validar
    for (int i = 0; i < _denominaciones.length; i++) {
      int denominacion = _denominaciones[i];
      if (resto >= denominacion) {
        resto = resto % denominacion; // actualizar el residuo
      }
    }
    
    // Si el resto es 0, el monto es válido
    return resto == 0;
  }

  void _generarClave() {
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

    // El timer ya está corriendo, no necesitamos crear uno nuevo
    
    // Mostrar mensaje de renovación automática
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

    // Mostrar sistema de retiros integrado
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
                Text("Celular: $celular", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Retiros fijos
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
                
                // Valor libre
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
  // Matriz [denominación, cantidad]
  List<List<int>> billetes = [
    [100000, 0],
    [50000, 0],
    [20000, 0],
    [10000, 0],
  ];

  int resto = monto;

  // Método del acarreo
  for (int i = 0; i < billetes.length; i++) {
    int denominacion = billetes[i][0];
    if (resto >= denominacion) {
      billetes[i][1] = resto ~/ denominacion; // cantidad de billetes
      resto = resto % denominacion;           // actualizar el residuo
    }
  }

  // Verificar si el monto se pudo cubrir exacto
  if (resto != 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("No se puede retirar $monto."),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    return;
  }

  // Construir el reporte de billetes
  String reporte = "✅ Retiro de $monto en billetes:\n";
  for (int i = 0; i < billetes.length; i++) {
    if (billetes[i][1] > 0) {
      reporte += "${billetes[i][1]} billete(s) de ${billetes[i][0]}\n";
    }
  }

  // Mostrar en pantalla con AlertDialog
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Desglose de billetes"),
      content: Text(reporte),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
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
            const Text("✅ Retiro procesado correctamente", 
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
            ).toList(),
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