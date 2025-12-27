import 'package:flutter/material.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OpenPanel
  await Openpanel.instance.initialize(
    options: OpenpanelOptions(
      clientId: 'YOUR_CLIENT_ID',
      clientSecret: 'YOUR_CLIENT_SECRET',
      verbose: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenPanel Demo',
      navigatorObservers: [
        // Track navigation automatically
        OpenpanelObserver(),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'OpenPanel Flutter Demo'),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Track an event
    Openpanel.instance.event(
      name: 'button_clicked',
      properties: {'count': _counter, 'screen': 'home'},
    );

    // Increment a user property
    Openpanel.instance.increment(
      property: 'clicks',
      value: 1,
      eventOptions: const OpenpanelEventOptions(profileId: 'user_123'),
    );
  }

  void _identifyUser() {
    // Identify the user
    Openpanel.instance.setProfileId('user_123');
    Openpanel.instance.updateProfile(
      payload: const UpdateProfilePayload(
        profileId: 'user_123',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        properties: {'plan': 'premium'},
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User Identified')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _identifyUser,
              child: const Text('Identify User'),
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
