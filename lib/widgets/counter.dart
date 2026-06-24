import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  final String label;
  final Function(int) onCountChanged; // Callback para notificar el cambio
  final int initialValue;

  const Counter({
    super.key,
    required this.label,
    required this.onCountChanged,
    this.initialValue = 0,
  });

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _count;

  @override
  void initState() {
    super.initState();
    // 3. INICIALIZAMOS EL CONTADOR CON EL VALOR RECIBIDO
    _count = widget.initialValue;
  }

  // 4. MÉTODO CLAVE PARA ACTUALIZAR EL CONTADOR DESDE FUERA
  // Se ejecuta cuando el widget padre se reconstruye con nuevos datos (ej. al cambiar de fecha)
  @override
  void didUpdateWidget(Counter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el nuevo valor inicial es diferente al que teníamos, actualizamos el estado.
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _count = widget.initialValue;
      });
    }
  }

  void _increment() {
    setState(() {
      _count++;
      widget.onCountChanged(_count); // Notificar al padre del cambio
    });
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
        widget.onCountChanged(_count); // Notificar al padre del cambio
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          // Altura mínima (no fija) para no recortar con escalado de texto.
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: _decrement,
                tooltip: 'Disminuir ${widget.label}',
                // Objetivo táctil de 48dp (accesibilidad).
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$_count',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: _increment,
                tooltip: 'Aumentar ${widget.label}',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
