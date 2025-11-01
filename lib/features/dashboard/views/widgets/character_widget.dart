import 'package:flutter/material.dart';

/// Widget del personaje del usuario en el dashboard
class CharacterWidget extends StatelessWidget {
  const CharacterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/character/home/home.png',
      height: 300,
      fit: BoxFit.contain,
    );
  }
}
