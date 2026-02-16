import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stateful Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterWidget(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  // Initial counter value
  int _counter = 0;
  final int _maxLimit = 100;

  // Custom increment value (Feature 2)
  final TextEditingController _incrementController =
      TextEditingController(text: '1');
  int _customIncrement = 1;



  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  // Feature 1: Increment with custom step
  void _incrementCounter() {
    if (_counter >= _maxLimit) return;
    setState(() {
      _counter = (_counter + _customIncrement).clamp(0, _maxLimit);
    });
  }

  // Feature 1: Decrement with floor of 0
  void _decrementCounter() {
    if (_counter <= 0) return;
    setState(() {
      _counter = (_counter - _customIncrement).clamp(0, _maxLimit);
    });
  }

  // Feature 1: Reset to 0
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  // Feature 4: Dynamic counter text color
  Color get counterColor {
    if (_counter == 0) return Colors.red;
    if (_counter > 50) return Colors.green;
    return Colors.black;
  }

  // Feature 2: Validate and apply custom increment input
  void _applyCustomIncrement() {
    final parsed = int.tryParse(_incrementController.text.trim());
    if (parsed != null && parsed > 0) {
      setState(() {
        _customIncrement = parsed;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive number.')),
      );
      _incrementController.text = _customIncrement.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool atMax = _counter >= _maxLimit;
    final bool atMin = _counter <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Widget'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Counter Display (Feature 4: color changes) ──
            Center(
              child: Container(
                child: Text(
                  '$_counter',
                  style: TextStyle(fontSize: 50.0, color: counterColor),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Feature 3: Max limit message
            if (atMax)
              const Text(
                'Maximum limit reached!',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            const SizedBox(height: 12),

            // ── Slider ──
            Slider(
              min: 0,
              max: 100,
              value: _counter.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _counter = value.toInt();
                });
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
            ),
            const SizedBox(height: 16),

            // ── Feature 2: Custom increment input ──
            Row(
              children: [
                const Text('Step size:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _incrementController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _applyCustomIncrement(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyCustomIncrement,
                  child: const Text('Set'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Feature 1: Increment, Decrement, Reset Buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: atMin ? null : _decrementCounter,
                  icon: const Icon(Icons.remove),
                  label: Text('-$_customIncrement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: atMax ? null : _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: Text('+$_customIncrement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}