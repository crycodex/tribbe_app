import 'package:flutter/cupertino.dart';
import 'package:tribbe_app/shared/models/exercise_model.dart';

/// Modal mejorado para seleccionar ejercicio con búsqueda y filtros
class ExercisePickerModal extends StatefulWidget {
  final List<ExerciseTemplate> exercises;
  final Function(ExerciseTemplate) onExerciseSelected;

  const ExercisePickerModal({
    super.key,
    required this.exercises,
    required this.onExerciseSelected,
  });

  static void show({
    required BuildContext context,
    required List<ExerciseTemplate> exercises,
    required Function(ExerciseTemplate) onExerciseSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ExercisePickerModal(
        exercises: exercises,
        onExerciseSelected: onExerciseSelected,
      ),
    );
  }

  @override
  State<ExercisePickerModal> createState() => _ExercisePickerModalState();
}

class _ExercisePickerModalState extends State<ExercisePickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMuscleGroup;
  String? _selectedEquipment;
  String? _selectedDifficulty;
  List<ExerciseTemplate> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _filteredExercises = widget.exercises;
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredExercises = widget.exercises.where((exercise) {
        // Filtro de búsqueda
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            searchQuery.isEmpty ||
            exercise.name.toLowerCase().contains(searchQuery) ||
            exercise.muscleGroup.toLowerCase().contains(searchQuery);

        // Filtro de grupo muscular
        final matchesMuscleGroup =
            _selectedMuscleGroup == null ||
            exercise.muscleGroup == _selectedMuscleGroup ||
            exercise.secondaryMuscles.contains(_selectedMuscleGroup);

        // Filtro de equipamiento
        final matchesEquipment =
            _selectedEquipment == null ||
            exercise.equipment == _selectedEquipment;

        // Filtro de dificultad
        final matchesDifficulty =
            _selectedDifficulty == null ||
            exercise.difficulty == _selectedDifficulty;

        return matchesSearch &&
            matchesMuscleGroup &&
            matchesEquipment &&
            matchesDifficulty;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedMuscleGroup = null;
      _selectedEquipment = null;
      _selectedDifficulty = null;
      _filteredExercises = widget.exercises;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark),
          _buildSearchBar(isDark),
          _buildFilters(isDark),
          Expanded(
            child: _filteredExercises.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return _buildExerciseItem(context, exercise, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Seleccionar Ejercicio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: 'Buscar ejercicio...',
        style: TextStyle(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
        placeholderStyle: TextStyle(
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
        backgroundColor: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6,
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    final hasActiveFilters =
        _selectedMuscleGroup != null ||
        _selectedEquipment != null ||
        _selectedDifficulty != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2,
                ),
              ),
              if (hasActiveFilters)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _clearFilters,
                  child: const Text('Limpiar', style: TextStyle(fontSize: 13)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip(
                label: _selectedMuscleGroup ?? 'Músculo',
                isActive: _selectedMuscleGroup != null,
                onTap: () => _showMuscleGroupPicker(isDark),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: _selectedEquipment ?? 'Equipamiento',
                isActive: _selectedEquipment != null,
                onTap: () => _showEquipmentPicker(isDark),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: _selectedDifficulty ?? 'Dificultad',
                isActive: _selectedDifficulty != null,
                onTap: () => _showDifficultyPicker(isDark),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey5,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? CupertinoColors.activeBlue
              : (isDark
                    ? CupertinoColors.systemGrey6.darkColor
                    : CupertinoColors.systemGrey6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? CupertinoColors.activeBlue
                : (isDark
                      ? CupertinoColors.systemGrey4
                      : CupertinoColors.systemGrey5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? CupertinoColors.white
                    : (isDark ? CupertinoColors.white : CupertinoColors.black),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive ? CupertinoIcons.xmark : CupertinoIcons.chevron_down,
              size: 14,
              color: isActive
                  ? CupertinoColors.white
                  : (isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(
    BuildContext context,
    ExerciseTemplate exercise,
    bool isDark,
  ) {
    return CupertinoListTile(
      title: Text(
        exercise.name,
        style: TextStyle(
          color: isDark ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
      subtitle: Text(
        '${exercise.muscleGroup} • ${exercise.equipment} • ${exercise.difficulty}',
        style: TextStyle(
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
      ),
      trailing: const Icon(
        CupertinoIcons.add_circled,
        color: CupertinoColors.activeBlue,
      ),
      onTap: () {
        Navigator.pop(context);
        widget.onExerciseSelected(exercise);
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 64,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron ejercicios',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros filtros o términos de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 14,
                color: isDark
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.systemGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMuscleGroupPicker(bool isDark) {
    if (_selectedMuscleGroup != null) {
      setState(() {
        _selectedMuscleGroup = null;
        _applyFilters();
      });
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar Grupo Muscular'),
        actions: MuscleGroups.all.map((muscleGroup) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedMuscleGroup = muscleGroup;
                _applyFilters();
              });
            },
            child: Text(muscleGroup),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showEquipmentPicker(bool isDark) {
    if (_selectedEquipment != null) {
      setState(() {
        _selectedEquipment = null;
        _applyFilters();
      });
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar Equipamiento'),
        actions: Equipment.all.map((equipment) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedEquipment = equipment;
                _applyFilters();
              });
            },
            child: Text(equipment),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  void _showDifficultyPicker(bool isDark) {
    if (_selectedDifficulty != null) {
      setState(() {
        _selectedDifficulty = null;
        _applyFilters();
      });
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Seleccionar Dificultad'),
        actions: Difficulty.all.map((difficulty) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedDifficulty = difficulty;
                _applyFilters();
              });
            },
            child: Text(difficulty),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancelar'),
        ),
      ),
    );
  }
}
