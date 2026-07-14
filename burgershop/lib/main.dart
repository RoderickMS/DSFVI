import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '¡Contador Interactivo!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Lista de colores para cambiar el fondo
  final List<Color> _bgColors = [
    Colors.teal.shade50,
    Colors.blue.shade50,
    Colors.amber.shade50,
    Colors.orange.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  // Devuelve un mensaje simpático según el valor del contador
  String _getMoodMessage() {
    if (_counter == 0) return '¡Un lienzo en blanco! Empieza a pulsar.';
    if (_counter > 0 && _counter < 5) return '¡Vamos por buen camino! 🚀';
    if (_counter >= 5 && _counter < 10) return '¡Estás On Fire! 🔥';
    if (_counter >= 10) return '¡Nivel Leyenda alcanzado! 🏆';
    return '¿Hacia atrás? ¡Vamos al revés! 🌀';
  }

  @override
  Widget build(BuildContext context) {
    // Elige un color de fondo basado en el valor absoluto del contador
    final backgroundColor = _bgColors[(_counter.abs()) % _bgColors.length];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _getMoodMessage(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black80,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '$_counter',
                  key: ValueKey<int>(_counter),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: _counter >= 0 ? Colors.teal : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Agrupamos tres botones en la esquina inferior derecha
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrementar',
            backgroundColor: Colors.red.shade100,
            child: const Icon(Icons.remove, color: Colors.red),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _resetCounter,
            tooltip: 'Reiniciar',
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.refresh, color: Colors.black80),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Incrementar',
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.add, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}