import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tribbe_app/features/dashboard/views/widgets/character_widget.dart';
import 'package:tribbe_app/features/dashboard/views/widgets/dashboard_header.dart';
import 'package:tribbe_app/features/dashboard/views/widgets/weekly_streak_widget.dart';
import 'package:tribbe_app/features/dashboard/views/widgets/workout_feed_widget.dart';

/// Dashboard principal (Home Tab)
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar Get.find() porque HomeBinding ya registró el controller
    final controller = Get.find<DashboardController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Header completamente transparente
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    floating: true,
                    snap: true,
                    elevation: 0,
                    expandedHeight: 100,
                    collapsedHeight: 70,
                    toolbarHeight: 70,
                    surfaceTintColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        color: Colors.transparent,
                        child: SafeArea(
                          child: Center(child: DashboardHeader()),
                        ),
                      ),
                      titlePadding: EdgeInsets.zero,
                    ),
                  ),

                  // Contenido principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Área del personaje con botón de compartir
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Personaje del usuario
                              const CharacterWidget(),

                              // Botón de compartir en la esquina superior derecha del personaje
                              Positioned(
                                top: 0,
                                right: 0,
                                child: _buildShareButton(context, controller),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Sistema de rachas semanales
                          const WeeklyStreakWidget(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Sección de Feed
                  const SliverToBoxAdapter(child: WorkoutFeedWidget()),

                  // Espacio final
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
    );
  }

  /// Botón simple para compartir personaje y racha
  Widget _buildShareButton(
    BuildContext context,
    DashboardController controller,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.shareCharacterAndStreak(),
        borderRadius: BorderRadius.circular(20),
        child: const Icon(Icons.share_outlined, color: Colors.orange, size: 18),
      ),
    );
  }
}
