import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Tab Bar compartido de Tribbe con botón central de entrenamiento
class TribbeTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onTrainingTap;

  const TribbeTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onTrainingTap,
  });

  @override
  Widget build(BuildContext context) {
    return CNTabBar(
      items: const [
        CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
        CNTabBarItem(label: 'Gimnasios', icon: CNSymbol('building.2.fill')),
        CNTabBarItem(
          label: 'Entrenar',
          icon: CNSymbol('figure.strengthtraining.traditional'),
        ),
        CNTabBarItem(label: 'Store', icon: CNSymbol('bag.fill')),
        CNTabBarItem(label: 'Perfil', icon: CNSymbol('person.circle.fill')),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        // Si toca el botón central (índice 2), ejecutar acción especial
        if (index == 2 && onTrainingTap != null) {
          onTrainingTap!();
        } else {
          onTap(index);
        }
      },
    );
  }
}
