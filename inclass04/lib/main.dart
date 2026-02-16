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

  // Feature 5: Counter history
  List<int> _history = [];

  // Feature 7: Track milestone dialogs
  bool _shownTargetDialog = false;
  bool _shownMaxDialog = false;



  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  // Feature 5: Save current value to history before changing
  void _saveHistory() {
    _history.add(_counter);
  }

  // Feature 7: Check and show milestone dialogs
  void _checkMilestones() {
    if (_counter >= _maxLimit && !_shownMaxDialog) {
      _shownMaxDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog(
            'Maximum Reached!', '🎉 You\'ve hit the maximum limit of $_maxLimit!');
      });
    } else if (_counter >= 50 && !_shownTargetDialog) {
      _shownTargetDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog(
            'Target Reached!', '🎊 Congratulations! You\'ve reached 50!');
      });
    }
  }

  void _showCongratulationsDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Feature 6: Undo
  void _undoCounter() {
    if (_history.isEmpty) return;
    setState(() {
      _counter = _history.removeLast();
      if (_counter < 50) _shownTargetDialog = false;
      if (_counter < _maxLimit) _shownMaxDialog = false;
    });
  }

  // Feature 1: Increment with custom step
  void _incrementCounter() {
    if (_counter >= _maxLimit) return;
    _saveHistory();
    setState(() {
      _counter = (_counter + _customIncrement).clamp(0, _maxLimit);
    });
    _checkMilestones();
  }

  // Feature 1: Decrement with floor of 0
  void _decrementCounter() {
    if (_counter <= 0) return;
    _saveHistory();
    setState(() {
      _counter = (_counter - _customIncrement).clamp(0, _maxLimit);
    });
  }

  // Feature 1: Reset to 0
  void _resetCounter() {
    _saveHistory();
    setState(() {
      _counter = 0;
      _shownTargetDialog = false;
      _shownMaxDialog = false;
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
                _saveHistory();
                setState(() {
                  _counter = value.toInt();
                });
                _checkMilestones();
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
            const SizedBox(height: 12),

            // ── Feature 6: Undo Button ──
            ElevatedButton.icon(
              onPressed: _history.isEmpty ? null : _undoCounter,
              icon: const Icon(Icons.undo),
              label: const Text('Undo'),
            ),
            const SizedBox(height: 20),

            // ── Feature 5: Counter History ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'History (${_history.length} entries):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            _history.isEmpty
                ? const Text('No history yet.',
                    style: TextStyle(color: Colors.grey))
                : Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _history.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final entry = _history[_history.length - 1 - index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              '${_history.length - index}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          title: Text('Counter was: $entry'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}