import 'package:flutter/material.dart';

/// Página de Gimnasios
class GymPage extends StatelessWidget {
  const GymPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Gimnasios',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Lista de gimnasios irá aquí'),
          ],
        ),
      ),
    );
  }
}
