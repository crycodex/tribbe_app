import 'package:flutter/material.dart';

/// Página de Tienda
class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Store',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Tienda de productos irá aquí'),
          ],
        ),
      ),
    );
  }
}
