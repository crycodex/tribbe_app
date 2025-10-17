# Training Feature - Refactorización y Mejores Prácticas

## 📋 Resumen de la Refactorización

Este módulo fue refactorizado desde un archivo monolítico de 1717 líneas a una arquitectura modular y mantenible siguiendo los principios SOLID y las mejores prácticas de Flutter.

## 🏗️ Estructura Anterior vs Nueva

### ❌ Antes (training_mode_page.dart - 1717 líneas)
- ✗ Lógica de negocio mezclada con UI
- ✗ Más de 15 métodos privados para construir UI
- ✗ Estado local disperso
- ✗ Difícil de mantener y testear
- ✗ Violación del principio de responsabilidad única

### ✅ Ahora (Arquitectura Modular)

```
features/training/
├── controllers/
│   ├── training_controller.dart                    # Lógica principal de entrenamiento
│   └── training_exercise_editor_controller.dart    # Lógica de edición de ejercicios
├── models/
│   ├── exercise_model.dart
│   └── workout_model.dart
└── views/
    ├── pages/
    │   └── training_mode_page.dart                 # Orquestador (237 líneas)
    └── widgets/
        ├── training_timer_widget.dart              # Timer compacto
        ├── training_stats_row_widget.dart          # Estadísticas
        ├── suggested_exercises_widget.dart         # Ejercicios sugeridos
        ├── exercise_config_panel_widget.dart       # Panel de configuración
        ├── exercise_list_item_widget.dart          # Item de ejercicio
        ├── set_item_widget.dart                    # Item de serie
        ├── exercise_picker_modal.dart              # Modal de selección
        ├── finish_training_modal.dart              # Modal de finalización
        └── cancel_training_dialog.dart             # Diálogo de cancelación
```

## 🎯 Principios Aplicados

### 1. **Separación de Responsabilidades (SRP)**
Cada archivo tiene una única responsabilidad:
- **Controllers**: Lógica de negocio
- **Widgets**: Presentación visual
- **Modals**: Interacciones específicas

### 2. **Reutilización de Código (DRY)**
Widgets genéricos que se pueden usar en otros módulos:
- `TrainingTimerWidget`: Timer reutilizable
- `TrainingStatsRowWidget`: Stats genéricas
- `SetItemWidget`: Componente de serie

### 3. **Composición sobre Herencia**
Widgets pequeños y componibles que se ensamblan para crear interfaces complejas.

### 4. **Single Level of Abstraction**
Cada widget opera en un solo nivel de abstracción.

## 📦 Nuevos Componentes

### Controllers

#### `TrainingExerciseEditorController`
**Responsabilidad**: Manejar la edición y configuración de ejercicios.

**Estado gestionado**:
- `selectedExercise`: Ejercicio seleccionado
- `currentSets`: Series configuradas
- `editingSetIndex`: Índice de serie en edición
- `editingExerciseIndex`: Índice de ejercicio en edición

**Métodos principales**:
```dart
void selectExercise(ExerciseTemplate exercise)
void addOrUpdateSet()
void editSet(int index)
void removeSet(int index)
void editExercise(ExerciseData exercise, int index, List<ExerciseTemplate> available)
ExerciseData? getConfiguredExercise()
```

### Widgets

#### `TrainingTimerWidget`
Widget compacto que muestra el timer del entrenamiento con indicador de pausa.

**Props**: Ninguna (consume `TrainingController` con GetX)

#### `TrainingStatsRowWidget`
Muestra estadísticas en tiempo real: ejercicios, series y volumen.

**Props**: Ninguna (consume `TrainingController` con GetX)

#### `SuggestedExercisesWidget`
Lista horizontal de ejercicios sugeridos para comenzar.

**Props**:
- `exercises`: Lista de ejercicios disponibles
- `onExerciseSelected`: Callback al seleccionar

#### `ExerciseConfigPanelWidget`
Panel completo para configurar un ejercicio (agregar/editar series).

**Props**:
- `onSave`: Callback para guardar
- `onCancel`: Callback para cancelar

**Features**:
- Inputs de peso y reps con validación
- Lista de series con swipe actions
- Indicador de modo edición
- Cálculo de volumen en tiempo real

#### `ExerciseListItemWidget`
Item de ejercicio en la lista con swipe actions.

**Props**:
- `exercise`: Datos del ejercicio
- `isBeingEdited`: Estado de edición
- `onEdit`: Callback para editar
- `onDelete`: Callback para eliminar

**Features**:
- Swipe derecha → Editar (naranja)
- Swipe izquierda → Eliminar (rojo)
- Indicador visual cuando está en edición
- Resumen de series y volumen

#### `SetItemWidget`
Item de serie dentro del panel de configuración.

**Props**:
- `set`: Datos de la serie
- `index`: Índice de la serie
- `isEditing`: Estado de edición
- `onEdit`: Callback para editar
- `onDelete`: Callback para eliminar

### Modals

#### `ExercisePickerModal`
Modal para seleccionar ejercicio de la lista completa.

**Uso**:
```dart
ExercisePickerModal.show(
  context: context,
  exercises: availableExercises,
  onExerciseSelected: (exercise) => ...,
);
```

#### `FinishTrainingModal`
Modal minimalista para finalizar entrenamiento con campo de comentario.

**Uso**:
```dart
FinishTrainingModal.show(context);
```

#### `CancelTrainingDialog`
Diálogo de confirmación para cancelar entrenamiento.

**Uso**:
```dart
CancelTrainingDialog.show(context);
```

## 🔄 Flujo de Datos

```
TrainingModePage (Orquestador)
    ↓
    ├─→ TrainingController (Estado global del entrenamiento)
    │       ↓
    │       └─→ exercises: List<ExerciseData>
    │
    ├─→ TrainingExerciseEditorController (Estado de edición)
    │       ↓
    │       ├─→ selectedExercise
    │       ├─→ currentSets
    │       └─→ editingIndexes
    │
    └─→ Widgets (Presentación)
            ├─→ TimerWidget (lee TrainingController)
            ├─→ StatsWidget (lee TrainingController)
            ├─→ ConfigPanel (lee/escribe EditorController)
            └─→ ExerciseList (lee TrainingController, edita via EditorController)
```

## 🧪 Ventajas para Testing

### Antes
```dart
// Difícil de testear: lógica mezclada con UI
testWidgets('Should add exercise', (tester) async {
  // Necesita montar todo el widget tree de 1717 líneas
  await tester.pumpWidget(TrainingModePage());
  // Difícil acceder a métodos privados
});
```

### Ahora
```dart
// Fácil de testear: controllers aislados
test('Should add set correctly', () {
  final controller = TrainingExerciseEditorController();
  controller.weightController.text = '80';
  controller.repsController.text = '10';
  
  controller.addOrUpdateSet();
  
  expect(controller.currentSets.length, 1);
  expect(controller.currentSets.first.weight, 80);
});

// Widgets testables independientemente
testWidgets('SetItemWidget displays correctly', (tester) async {
  await tester.pumpWidget(
    SetItemWidget(
      set: SetModel(weight: 80, reps: 10),
      index: 0,
      isEditing: false,
      onEdit: () {},
      onDelete: () {},
    ),
  );
  
  expect(find.text('80.0 kg × 10 reps'), findsOneWidget);
});
```

## 📊 Métricas de Mejora

| Métrica | Antes | Ahora | Mejora |
|---------|-------|-------|--------|
| Líneas por archivo | 1717 | ~237 max | -86% |
| Métodos por clase | 25+ | 4-8 | -68% |
| Nivel de anidamiento | 8-10 | 3-4 | -60% |
| Archivos | 1 | 11 | +1000% modularidad |
| Testabilidad | Baja | Alta | ++ |
| Reusabilidad | Baja | Alta | ++ |

## 🚀 Cómo Usar

### Agregar un nuevo widget
```dart
// 1. Crear archivo en views/widgets/
// lib/features/training/views/widgets/my_widget.dart

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Implementación
  }
}

// 2. Importar en training_mode_page.dart
import 'package:tribbe_app/features/training/views/widgets/my_widget.dart';

// 3. Usar en el CustomScrollView
MyWidget(),
```

### Extender el EditorController
```dart
// En training_exercise_editor_controller.dart
void myNewMethod() {
  // Lógica de negocio
  // Actualizar observables
  currentSets.add(...);
}

// Usar desde widget
final controller = Get.find<TrainingExerciseEditorController>();
controller.myNewMethod();
```

## 🎨 Patrones de Diseño Utilizados

1. **Controller Pattern**: Separación de lógica de UI
2. **Observer Pattern**: Reactive UI con GetX Observables
3. **Facade Pattern**: Página principal como fachada simple
4. **Factory Pattern**: Modals con métodos estáticos `.show()`
5. **Composite Pattern**: Widgets componibles

## 📝 Convenciones de Nombres

- **Widgets**: `*Widget` o `*Modal` o `*Dialog`
- **Controllers**: `*Controller`
- **Callbacks**: `on*` (onSave, onEdit, onDelete)
- **Estados**: Observables con `.obs`
- **Métodos privados**: `_methodName`
- **Widgets internos**: `_WidgetName` (privado al archivo)

## 🔧 Próximas Mejoras Sugeridas

1. ✅ **Testing**: Agregar tests unitarios para controllers
2. ✅ **Animaciones**: Smooth transitions entre estados
3. ✅ **Validaciones**: Input validators más robustos
4. ✅ **Accesibilidad**: Semantic labels y screen reader support
5. ✅ **Localización**: Strings externalizados para i18n

## 📚 Referencias

- [Flutter Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [GetX State Management](https://pub.dev/packages/get)
- Tribbe App - Documento de Reglas del Proyecto

