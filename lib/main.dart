import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _result = 0.0;
  bool _isProcessing = false;
  List<int> _numbers = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  
  // Bug: Division that can cause infinity
  void _divideByZero() {
    setState(() {
      _result = _counter / 0; // Will produce Infinity
    });
  }
  
  // Bug: Unreachable if-else condition
  String _checkStatus() {
    if (_counter > 0) {
      return 'Positive';
    } else if (_counter < 0) {
      return 'Negative';
    } else if (_counter == 0) {
      return 'Zero';
    } else if (_counter > 10) { // This will never be reached!
      return 'Greater than 10';
    }
    return 'Unknown';
  }
  
  // Performance issue: Inefficient loop that could be optimized
  int _calculateSumSlow() {
    int sum = 0;
    for (int i = 0; i < _counter; i++) {
      for (int j = 0; j < 100; j++) {
        sum = sum + 1; // Nested loop doing unnecessary work
      }
    }
    return sum;
  }
  
  // Simple bug: Missing null check
  void _addNumber(int? number) {
    _numbers.add(number!); // Will crash if number is null
  }
  
  // Hard bug: Race condition with async operation
  Future<void> _complexAsyncOperation() async {
    _isProcessing = true;
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _counter = _counter * 2;
      _isProcessing = false; // Bug: setState after dispose possible
    });
  }
  
  // Bug: Should use different loop type
  void _populateList() {
    _numbers.clear();
    int i = 0;
    while (i < _counter) { // Should use for loop instead
      _numbers.add(i);
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              
              // Display result (may show Infinity)
              Text(
                'Result: $_result',
                style: TextStyle(
                  color: _result.isInfinite ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              
              // Display status
              Text('Status: ${_checkStatus()}'),
              const SizedBox(height: 20),
              
              // Buttons
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: _divideByZero,
                    child: const Text('Divide by Zero'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _calculateSumSlow(); // Performance issue
                      });
                    },
                    child: const Text('Calculate Slow'),
                  ),
                  ElevatedButton(
                    onPressed: () => _addNumber(null), // Will crash
                    child: const Text('Add Null'),
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _complexAsyncOperation,
                    child: Text(_isProcessing ? 'Processing...' : 'Async Op'),
                  ),
                  ElevatedButton(
                    onPressed: _populateList,
                    child: const Text('Populate List'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Display list
              if (_numbers.isNotEmpty)
                Text('List has ${_numbers.length} items'),
            ],
          ),
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
