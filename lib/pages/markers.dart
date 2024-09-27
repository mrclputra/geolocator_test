import 'package:flutter/material.dart';

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key});

  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  
  // UI
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Markers Page'),
      ),
    );
  }
}