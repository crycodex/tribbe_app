import 'package:flutter/material.dart';

/// Widget para generar la imagen compartible del personaje y racha
/// con fondo transparente
class CharacterStreakShareImage extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final Key shareKey;

  const CharacterStreakShareImage({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.shareKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: shareKey,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 800,
          height: 1000,
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Personaje
              Image.asset(
                'assets/images/character/home/home.png',
                height: 400,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 60),
              // Racha actual
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '$currentStreak',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'días',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Récord personal
              Text(
                'Récord: $longestStreak días',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Hashtag
              Text(
                '#TribbeApp',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
