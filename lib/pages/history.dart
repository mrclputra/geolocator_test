import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  // UI
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('History Page'),
      ),
    );
  }
}