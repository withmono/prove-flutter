import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mono_prove/mono_prove.dart';

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
      home: const MyHomePage(title: 'Mono Prove Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showProveWidget(context),
          child: Text('Launch Prove Widget'),
        ),
      ),
    );
  }

  void _showProveWidget(BuildContext context) {
    MonoProve().launch(
      context,
      'PRV...', // sessionId
      onSuccess: () {
        logger('Successfully verified.');
      },
      showLogs: true,
      reference: DateTime.now().millisecondsSinceEpoch.toString(),
      onEvent: (event) {
        logger(event);
      },
      onClose: () {
        logger('Widget closed.');
      },
    );
  }

  void logger(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }
}
