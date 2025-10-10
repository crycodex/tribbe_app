import 'package:flutter/material.dart';

/// Página de Entrenamiento
class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Entrenar',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Sistema de entrenamiento irá aquí'),
          ],
        ),
      ),
    );
  }
}
