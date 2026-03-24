import 'package:flutter/material.dart';

void main() {
  runApp(const PensaApp());
}

class PensaApp extends StatelessWidget {
  const PensaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pensa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pensa - Expenses')),
      body: const Center(
        child: Text('No expenses yet'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // will connect later
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}