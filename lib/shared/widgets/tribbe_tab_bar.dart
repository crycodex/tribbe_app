import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Tab Bar compartido de Tribbe con soporte para long press
class TribbeTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterLongPress;

  const TribbeTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tab Bar base
        CNTabBar(
          items: const [
            CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
            CNTabBarItem(label: 'Gimnasios', icon: CNSymbol('building.2.fill')),
            CNTabBarItem(label: 'Entrenar', icon: CNSymbol('bolt.circle.fill')),
            CNTabBarItem(label: 'Store', icon: CNSymbol('bag.fill')),
            CNTabBarItem(label: 'Perfil', icon: CNSymbol('person.circle.fill')),
          ],
          currentIndex: currentIndex,
          onTap: onTap,
        ),

        // Detector de long press sobre el tab central
        if (onCenterLongPress != null)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.4,
            right: MediaQuery.of(context).size.width * 0.4,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onLongPress: onCenterLongPress,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}
