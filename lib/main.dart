import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: NairaPalApp()));
}

class NairaPalApp extends StatelessWidget {
  const NairaPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NairaPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD4847C)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('NairaPal')),
      ),
    );
  }
}
