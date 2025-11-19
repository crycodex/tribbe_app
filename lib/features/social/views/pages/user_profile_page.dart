import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/social/controllers/social_controller.dart';
import 'package:tribbe_app/features/messages/views/pages/chat_page.dart';
import 'package:tribbe_app/features/training/models/workout_post_model.dart';
import 'package:tribbe_app/app/routes/route_paths.dart';

/// Página de perfil de usuario - Estilo Instagram Minimalista
class UserProfilePage extends StatefulWidget {
  final String userId;
  final String username;
  final String? displayName;
  final String? photoUrl;

  const UserProfilePage({
    super.key,
    required this.userId,
    required this.username,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del perfil cuando se abre la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.put(SocialController());
      controller.loadUserProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    // Limpiar datos cuando se cierra la página
    final controller = Get.put(SocialController());
    controller.clearVisitedUserProfile();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SocialController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // AppBar con nombre de usuario y botón de seguir
              SliverAppBar(
                backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
                title: Text(
                  '@${widget.username}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  // Menú de opciones (tres puntos) - Estilo Cupertino
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => _showCupertinoActionSheet(
                      context,
                      controller,
                      widget.userId,
                      widget.username,
                      isDark,
                    ),
                  ),
                  // Botón de seguir/dejar de seguir
                  FutureBuilder<bool>(
                    future: controller.isFollowingUser(widget.userId),
                    builder: (context, snapshot) {
                      final isFollowing = snapshot.data ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            if (isFollowing) {
                              controller.unfollowUser(
                                widget.userId,
                                widget.username,
                              );
                            } else {
                              controller.followUser(widget.userId);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isFollowing
                                  ? (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.05))
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                              border: isFollowing
                                  ? Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.1),
                                      width: 0.5,
                                    )
                                  : null,
                            ),
                            child: Text(
                              isFollowing ? 'Siguiendo' : 'Seguir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isFollowing
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.loadUserProfile(widget.userId);
            },
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
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color:
                                    widget.photoUrl == null ||
                                        widget.photoUrl!.isEmpty
                                    ? _getAvatarColor(widget.userId, isDark)
                                    : null,
                                shape: BoxShape.circle,
                                image:
                                    widget.photoUrl != null &&
                                        widget.photoUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(widget.photoUrl!),
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
                              child:
                                  widget.photoUrl == null ||
                                      widget.photoUrl!.isEmpty
                                  ? Center(
                                      child: Text(
                                        widget.username.isNotEmpty
                                            ? widget.username[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: _getAvatarTextColor(
                                            widget.userId,
                                            isDark,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 24),

                            // Estadísticas
                            Expanded(
                              child: Obx(() {
                                final stats = controller.visitedUserStats.value;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      context,
                                      value:
                                          '${controller.visitedUserPosts.length}',
                                      label: 'Posts',
                                    ),
                                    _buildStatColumn(
                                      context,
                                      value: '${stats?.followersCount ?? 0}',
                                      label: 'Seguidores',
                                    ),
                                    _buildStatColumn(
                                      context,
                                      value: '${stats?.followingCount ?? 0}',
                                      label: 'Siguiendo',
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Nombre completo
                        if (widget.displayName != null &&
                            widget.displayName!.isNotEmpty)
                          Text(
                            widget.displayName!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 4),

                        const SizedBox(height: 20),

                        // Botones de acción
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navegar a chat
                                  Get.to(
                                    () => ChatPage(
                                      otherUserId: widget.userId,
                                      otherUsername: widget.username,
                                      otherUserPhotoUrl: widget.photoUrl,
                                      otherUserDisplayName: widget.displayName,
                                    ),
                                    transition: Transition.cupertino,
                                    duration: const Duration(milliseconds: 300),
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
                                child: const Text(
                                  'Mensaje',
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
                                // TODO: Compartir perfil
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
                              child: const Icon(Icons.share, size: 18),
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
                        const Text(
                          'Entrenamientos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Grilla de entrenamientos del usuario
                Obx(() {
                  if (controller.isLoadingUserProfile.value) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final posts = controller.visitedUserPosts;

                  if (posts.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildEmptyWorkoutCard(isDark),
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
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final post = posts[index];
                        return _buildWorkoutGridItem(context, post, isDark);
                      }, childCount: posts.length),
                    ),
                  );
                }),

                // Espacio al final
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para columna de estadística
  Widget _buildStatColumn(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Padding(
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
    );
  }

  /// Widget para card de entrenamiento vacío
  Widget _buildEmptyWorkoutCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 32,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin entrenamientos',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar Action Sheet estilo Cupertino
  void _showCupertinoActionSheet(
    BuildContext context,
    SocialController controller,
    String userId,
    String username,
    bool isDark,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          '@$username',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              controller.blockUser(userId, username);
            },
            child: const Text(
              'Bloquear usuario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// Widget para item de la grilla de entrenamientos
  Widget _buildWorkoutGridItem(
    BuildContext context,
    WorkoutPostModel post,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          RoutePaths.workoutDetail.replaceAll(':id', post.workout.id),
          arguments: {'workoutPost': post},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto del entrenamiento o placeholder
              if (post.workoutPhotoUrl != null &&
                  post.workoutPhotoUrl!.isNotEmpty)
                Image.network(
                  post.workoutPhotoUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder(isDark);
                  },
                )
              else
                _buildPlaceholder(isDark),
              // Overlay con info del entrenamiento
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget placeholder cuando no hay foto
  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 32,
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
      ),
    );
  }

  /// Obtener color de avatar basado en el userId (consistente)
  Color _getAvatarColor(String userId, bool isDark) {
    // Paleta de colores vibrantes para avatares
    final colors = isDark
        ? [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF8B5CF6), // Violet
            const Color(0xFFEC4899), // Pink
            const Color(0xFFEF4444), // Red
            const Color(0xFFF59E0B), // Amber
            const Color(0xFF10B981), // Emerald
            const Color(0xFF06B6D4), // Cyan
            const Color(0xFF3B82F6), // Blue
          ]
        : [
            const Color(0xFF6366F1), // Indigo
            const Color(0xFF8B5CF6), // Violet
            const Color(0xFFEC4899), // Pink
            const Color(0xFFEF4444), // Red
            const Color(0xFFF59E0B), // Amber
            const Color(0xFF10B981), // Emerald
            const Color(0xFF06B6D4), // Cyan
            const Color(0xFF3B82F6), // Blue
          ];

    // Generar índice basado en el hash del userId
    final hash = userId.hashCode;
    final index = hash.abs() % colors.length;
    return colors[index];
  }

  /// Obtener color del texto del avatar (blanco o negro según contraste)
  Color _getAvatarTextColor(String userId, bool isDark) {
    final bgColor = _getAvatarColor(userId, isDark);
    // Calcular luminosidad del color de fondo
    final luminance = bgColor.computeLuminance();
    // Si la luminosidad es alta, usar texto oscuro, si es baja, usar texto claro
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
