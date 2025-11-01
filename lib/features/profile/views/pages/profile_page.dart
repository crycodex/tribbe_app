import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';
import 'package:tribbe_app/features/auth/controllers/auth_controller.dart';
import 'package:tribbe_app/features/auth/models/user_model.dart';
import 'package:tribbe_app/features/home/views/pages/home_page.dart';
import 'package:tribbe_app/features/profile/controllers/profile_controller.dart';
import 'package:tribbe_app/features/profile/views/widgets/workout_grid_item.dart';
import 'package:tribbe_app/shared/widgets/credit_card_widget.dart';

/// Página de Perfil - Estilo Instagram Minimalista
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar Get.find() porque HomeBinding ya registró el controller
    final profileController = Get.find<ProfileController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: Obx(() {
        // Mostrar loading mientras se carga el perfil
        if (profileController.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // AppBar con título y settings
                SliverAppBar(
                  backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
                  elevation: 0,
                  pinned: true,
                  title: Obx(() {
                    final username = profileController.nombreUsuario.value;
                    return Text(
                      username.isEmpty ? 'Perfil' : '@$username',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        // Abrir drawer usando el GlobalKey del HomePage
                        homeScaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ];
            },
            body: RefreshIndicator(
              onRefresh: profileController.refreshWorkouts,
              child: CustomScrollView(
                slivers: [
                  // Header del perfil
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Foto de perfil + Stats
                          Row(
                            children: [
                              // Foto de perfil
                              Obx(() {
                                final photoUrl =
                                    profileController.photoUrl.value;
                                return Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                    image: photoUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(photoUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: photoUrl.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 45,
                                          color: isDark
                                              ? Colors.grey.shade600
                                              : Colors.grey.shade500,
                                        )
                                      : null,
                                );
                              }),

                              const SizedBox(width: 24),

                              // Estadísticas
                              Expanded(
                                child: Obx(() {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatColumn(
                                        context,
                                        value: profileController.totalWorkouts
                                            .toString(),
                                        label: 'Posts',
                                        onTap: () {
                                          Get.toNamed(
                                            RoutePaths.workoutHistory,
                                          );
                                        },
                                      ),
                                      _buildStatColumn(
                                        context,
                                        value: profileController.followersCount
                                            .toString(),
                                        label: 'Seguidores',
                                        onTap: () {
                                          Get.toNamed(RoutePaths.social);
                                        },
                                      ),
                                      _buildStatColumn(
                                        context,
                                        value: profileController.followingCount
                                            .toString(),
                                        label: 'Siguiendo',
                                        onTap: () {
                                          Get.toNamed(RoutePaths.social);
                                        },
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Nombre completo
                          Obx(() {
                            final nombre =
                                profileController.nombreCompleto.value;
                            if (nombre.isEmpty) return const SizedBox.shrink();
                            return Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),

                          const SizedBox(height: 4),

                          // Bio
                          Obx(() {
                            final bio = profileController.bio.value;
                            if (bio.isEmpty) return const SizedBox.shrink();
                            return Text(
                              bio,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Get.toNamed(RoutePaths.editProfile);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: BorderSide(
                                      color: isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Editar perfil',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  _showCreditCard(
                                    context,
                                    profileController,
                                    isDark,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(Icons.credit_card, size: 18),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          Divider(
                            height: 1,
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),

                          const SizedBox(height: 16),

                          // Título de entrenamientos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Entrenamientos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Get.toNamed(RoutePaths.workoutHistory);
                                },
                                icon: const Icon(Icons.grid_view, size: 16),
                                label: const Text('Ver todos'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Grilla de entrenamientos
                  Obx(() {
                    if (profileController.isLoadingWorkouts.value) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (profileController.userWorkouts.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sin entrenamientos aún',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '¡Comienza tu primer entrenamiento!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Verificar si debemos cargar más
                            if (index ==
                                    profileController.userWorkouts.length - 1 &&
                                profileController.hasMoreWorkouts.value) {
                              profileController.loadMoreWorkouts();
                            }

                            if (index < profileController.userWorkouts.length) {
                              final post =
                                  profileController.userWorkouts[index];
                              return WorkoutGridItem(
                                post: post,
                                onTap: () {
                                  Get.toNamed(
                                    RoutePaths.workoutDetail.replaceAll(
                                      ':id',
                                      post.workout.id,
                                    ),
                                    arguments: {'workoutPost': post},
                                  );
                                },
                              );
                            } else {
                              // Mostrar loading al final
                              return const Center(
                                child: CupertinoActivityIndicator(),
                              );
                            }
                          },
                          childCount:
                              profileController.userWorkouts.length +
                              (profileController.hasMoreWorkouts.value ? 1 : 0),
                        ),
                      ),
                    );
                  }),

                  // Espacio al final
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Widget para columna de estadística
  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar tarjeta de crédito en un diálogo
  void _showCreditCard(
    BuildContext context,
    ProfileController profileController,
    bool isDark,
  ) {
    final authController = Get.find<AuthController>();
    final userProfile = authController.userProfile.value;

    if (userProfile == null) {
      Get.snackbar(
        'Error',
        'No se pudo cargar el perfil',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Crear UserModel para la tarjeta
    final user = UserModel(
      id: userProfile.uid,
      email: userProfile.email,
      username: userProfile.datosPersonales?.nombreUsuario ?? 'usuario',
    );

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: CreditCardWidget(
            user: user,
            followersCount: profileController.followersCount.value,
            followingCount: profileController.followingCount.value,
            showShareButton: true,
            onTap: () => Get.back(), // Cerrar al tocar la tarjeta
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
