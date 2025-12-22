import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  final List<int> _history = [0];
  int _historyIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final _streamController = StreamController<int>(); // Bug 13: Never disposed!
  
  // Bug 1: Unused variables
  final String unusedVariable = 'This is never used';
  final double unusedDouble = 3.14159;
  String? nullableString; // Bug: Never initialized, can be null
  
  // Bug 2: Magic number without explanation
  final int MAGIC_NUMBER = 42;
  static const hardcodedValue = 999; // Bug: Another magic number

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Start the async operation once after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _performAsyncOperation(this.context);
    });
  }

  @override
  void dispose() {
    // Bug 3: Memory leak - AnimationController not disposed!
    // _animationController.dispose();
    _streamController.close(); // Fix Bug 13: Dispose StreamController to prevent memory leak
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _addToHistory(_counter);
      _animationController.forward().then((_) {
        _animationController.reverse();
        // Bug 6: Using context in callback without checking mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Counter: $_counter')),
        );
      });
    });
  }
  
  // Bug 4: Async operation without mounted check
  // Bug 5: Division by zero if counter is 0
  Future<void> _divideCounter() async {
    await Future.delayed(Duration(milliseconds: 100));
    // Missing: if (!mounted) return;
    setState(() {
      int result = 100 ~/ _counter; // Can crash if _counter = 0!
      print('Result: $result');
    });
  }
  
  // Bug 14: Comparing floating point with ==
  bool _isStatisticsValid() {
    if (_history.isEmpty) {
      return false;
    }
    var avg = _history.reduce((a, b) => a + b) / _history.length;
    const double epsilon = 1e-9;
    return avg.abs() < epsilon; // Use tolerance-based comparison instead of direct ==
  }
  
  // Bug 15: String comparison case-sensitive
  bool _checkTitle(String input) {
    // เปรียบเทียบแบบไม่สนใจตัวพิมพ์เล็ก/ใหญ่ โดย normalize ทั้งสองด้าน
    return input.toLowerCase() == 'flutter demo'.toLowerCase();
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _addToHistory(_counter);
    });
  }
  
  // Bug 8: Using nullable without null check (using ! is unsafe)
  void _printNullableString() {
    print(nullableString!.length); // Bug: Using ! without checking - will crash if null!
  }
  
  // Bug 9: Inefficient loop
  int _calculateSum() {
    int sum = 0;
    for (int i = 0; i < _history.length; i++) {
      sum += _history[i]; // Use += for clearer accumulation
    }
    return sum;
  }

  void _addToHistory(int value) {
    // Bug 10: Race condition - modifying list during iteration elsewhere
    // Bug 11: Not checking if value is different from last entry
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(value); // Bug 12: No limit on history size - memory leak!
    _historyIndex = _history.length - 1;
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _counter = _history[_historyIndex];
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _counter = _history[_historyIndex];
      });
    }
  }

  Map<String, dynamic> _getStatistics() {
    // Bug 7: Performance issue - calculating on EVERY build!
    // Should cache or use computed property
    if (_history.isEmpty) return {'avg': 0, 'max': 0, 'min': 0};

    int sum = 0;
    int min = _history.first;
    int max = _history.first;

    for (final value in _history) {
      sum += value;
      if (value < min) {
        min = value;
      }
      if (value > max) {
        max = value;
      }
    }

    final String avg = (sum / _history.length).toStringAsFixed(1);

    return {
      'avg': avg,
      'max': max,
      'min': min,
    };
  }
  
  Future<void> _performAsyncOperation(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    // Safely use the context only if the widget is still mounted after the async gap.
    if (!context.mounted) {
      return;
    }

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Async operation completed',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  // Fixed: Method now modifies state inside setState
  void _unsafeStateModification() {
    setState(() {
      _counter++; // State change is now correctly wrapped in setState
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _historyIndex > 0 ? _undo : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _historyIndex < _history.length - 1 ? _redo : null,
            tooltip: 'Redo',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text( // Bug 16: Missing const
              'Counter Value:',
              style: TextStyle(fontSize: 18), // Bug 17: This TextStyle should be const too
            ),
            const SizedBox(height: 10),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                '$_counter',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text( // Bug 18: Missing const - causes unnecessary rebuilds
                      'Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'Average', value: stats['avg'].toString()),
                        _StatItem(label: 'Max', value: stats['max'].toString()),
                        _StatItem(label: 'Min', value: stats['min'].toString()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'History: ${_history.length} entries',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Bug 19: Hardcoded color
                    foregroundColor: Colors.white,   // Bug 20: Should use theme colors
                  ),
                ),
                const SizedBox(width: 10),
                // Bug 7: Divide button with potential crash
                ElevatedButton.icon(
                  onPressed: _counter != 0 ? _divideCounter : null,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Divide'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _history.length > 1
                      ? () {
                          setState(() {
                            _history.clear();
                            _history.add(_counter);
                            _historyIndex = 0;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear History'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
