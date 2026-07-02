import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final double progress;

  const ProgressWidget({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[300],
        color: Colors.green,
        minHeight: 10,
      ),
    );
  }
}