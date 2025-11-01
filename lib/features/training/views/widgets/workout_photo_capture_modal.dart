import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tribbe_app/shared/services/firebase_storage_service.dart';

/// Modal para capturar foto del entrenamiento (estilo Instagram)
/// Permite tomar foto, seleccionar de galería o skipear
class WorkoutPhotoCaptureModal extends StatefulWidget {
  final VoidCallback onSkip;
  final Function(File) onPhotoSelected;

  const WorkoutPhotoCaptureModal({
    super.key,
    required this.onSkip,
    required this.onPhotoSelected,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onSkip,
    required Function(File) onPhotoSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => WorkoutPhotoCaptureModal(
        onSkip: onSkip,
        onPhotoSelected: onPhotoSelected,
      ),
    );
  }

  @override
  State<WorkoutPhotoCaptureModal> createState() =>
      _WorkoutPhotoCaptureModalState();
}

class _WorkoutPhotoCaptureModalState extends State<WorkoutPhotoCaptureModal> {
  File? _selectedImage;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: _selectedImage != null
                ? _buildPreview(isDark)
                : _buildInitialView(isDark),
          ),
        ],
      ),
    );
  }

  /// Header con botón de cerrar/skip
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
              widget.onSkip();
            },
            child: Text(
              'Omitir',
              style: TextStyle(
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            'Agregar Foto',
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          // Espacio para balancear el header
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  /// Vista inicial - opciones de tomar foto o galería
  Widget _buildInitialView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.camera,
          size: 80,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
        const SizedBox(height: 24),
        Text(
          'Comparte tu entrenamiento',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toma una foto o selecciona de tu galería',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            decoration: TextDecoration.none,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey2,
          ),
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              // Botón de cámara
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _takePhoto,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.camera_fill),
                      SizedBox(width: 8),
                      Text('Tomar Foto'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botón de galería
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: isDark
                      ? CupertinoColors.systemGrey3
                      : CupertinoColors.systemGrey5,
                  onPressed: _pickFromGallery,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.photo,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Seleccionar de Galería',
                        style: TextStyle(
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Vista de preview de la imagen seleccionada
  Widget _buildPreview(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Botón de cambiar foto
              Expanded(
                child: CupertinoButton(
                  color: isDark
                      ? CupertinoColors.systemGrey3
                      : CupertinoColors.systemGrey5,
                  onPressed: _changePhoto,
                  child: Text(
                    'Cambiar',
                    style: TextStyle(
                      color: isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón de usar foto
              Expanded(
                flex: 2,
                child: CupertinoButton.filled(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onPhotoSelected(_selectedImage!);
                  },
                  child: const Text('Usar esta Foto'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Tomar foto con la cámara
  Future<void> _takePhoto() async {
    try {
      final file = await _storageService.takePhoto();
      if (file != null) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo tomar la foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Seleccionar de galería
  Future<void> _pickFromGallery() async {
    try {
      final file = await _storageService.pickFromGallery();
      if (file != null) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Cambiar foto
  void _changePhoto() {
    setState(() => _selectedImage = null);
  }
}
