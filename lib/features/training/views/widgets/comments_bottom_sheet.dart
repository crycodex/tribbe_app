import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/features/training/controllers/comments_controller.dart';
import 'package:tribbe_app/features/training/models/comment_model.dart';
import 'package:intl/intl.dart';

/// Bottom sheet para mostrar y añadir comentarios a un post
class CommentsBottomSheet extends StatelessWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Usar Get.put para crear una instancia del controlador específica para este bottom sheet
    final CommentsController controller = Get.put(
      CommentsController(postId: postId), // Pasar postId directamente
      tag: postId,
    );

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle para arrastrar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Título
              Text(
                'Comentarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const Divider(height: 24),

              // Lista de comentarios
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingComments.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.comments.isEmpty) {
                    return Center(
                      child: Text(
                        'Sé el primero en comentar',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      final comment = controller.comments[index];
                      return CommentTile(comment: comment, isDark: isDark);
                    },
                  );
                }),
              ),

              // Campo para añadir comentario
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: controller.newCommentText.value,
                        ),
                        onChanged: (value) =>
                            controller.newCommentText.value = value,
                        decoration: InputDecoration(
                          hintText: 'Añade un comentario...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => FloatingActionButton.small(
                        onPressed: controller.isSendingComment.value
                            ? null
                            : controller.sendComment,
                        backgroundColor: Colors.blueAccent,
                        child: controller.isSendingComment.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget para mostrar un comentario individual
class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final bool isDark;

  const CommentTile({super.key, required this.comment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueAccent,
            backgroundImage: comment.userPhotoUrl != null
                ? NetworkImage(comment.userPhotoUrl!)
                : null,
            child: comment.userPhotoUrl == null
                ? Text(
                    comment.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt),
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
