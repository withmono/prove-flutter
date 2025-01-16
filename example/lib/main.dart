import 'dart:developer';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final config = ProveConfiguration(
    sessionId: 'PRV...',
    onSuccess: () {
      log('Successfully verified.');
    },
    reference: DateTime.now().millisecondsSinceEpoch.toString(),
    onEvent: (event) {
      log(event.toString());
    },
    onClose: () {
      log('Widget closed.');
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            MonoProve.launch(
              context,
              config: config,
              showLogs: true,
            );
          },
          child: Text('Launch Prove Widget'),
        ),
      ),
    );
  }
}
