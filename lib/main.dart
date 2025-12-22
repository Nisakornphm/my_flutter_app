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
  
  // Bug 2: Magic number without explanation
  final int MAGIC_NUMBER = 42;

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
  }

  @override
  void dispose() {
    // Bug 3: Comment out dispose - potential memory leak!
    // _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _addToHistory(_counter);
      _animationController.forward().then((_) => _animationController.reverse());
    });
  }
  
  // Bug 4: Potential division by zero
  void _divideCounter() {
    setState(() {
      int result = 100 ~/ _counter; // Division by zero when counter is 0!
      print('Result: $result');
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _addToHistory(_counter);
    });
  }

  void _addToHistory(int value) {
    // Remove any "redo" history if we're not at the end
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(value);
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
    // Bug 5: Duplicate code - should extract to helper method
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
  
  // Bug 6: Code smell - method name doesn't follow convention
  void Do_Something_Wrong() {
    print('Bad naming convention');
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
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 18),
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
                    const Text(
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
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                // Bug 7: Divide button with potential crash
                ElevatedButton.icon(
                  onPressed: _divideCounter,
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
