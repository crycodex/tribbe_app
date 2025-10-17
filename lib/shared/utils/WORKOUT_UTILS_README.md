# 🎯 Workout Utils - Utilities Compartidas

## 📦 Ubicación

**Antes**: `lib/features/profile/utils/workout_utils.dart`  
**Ahora**: `lib/shared/utils/workout_utils.dart` ✅

## ✨ ¿Por qué se Movió?

Este archivo fue movido a `shared/utils` porque es utilizado por múltiples módulos:
- ✅ **Profile**: Historial de entrenamientos, grid de workouts
- ✅ **Training**: Página de detalle, selector de enfoque
- ✅ **Social**: Cards de posts de entrenamientos

## 🎨 Funcionalidades

### 1. Colores por Tipo de Entrenamiento

```dart
// Obtener color único para cada tipo
final color = WorkoutUtils.getFocusColor('Fuerza');
// Returns: Color(0xFFE53E3E) - Rojo intenso

// Tipos soportados
// Por Objetivo:
- Fuerza → Rojo intenso
- Hipertrofia → Púrpura
- Resistencia → Verde
- Cardio → Azul
- Funcional → Naranja
- CrossFit → Rojo intenso
- Calistenia → Teal

// Por Grupo Muscular:
- Pecho → Rosa
- Espalda → Azul
- Piernas → Verde
- Hombros → Naranja
- Brazos → Púrpura
- Abdomen → Amarillo
- Full Body → Cian
```

### 2. Iconos por Tipo

```dart
// Obtener icono representativo
final icon = WorkoutUtils.getFocusIcon('Fuerza');
// Returns: Icons.fitness_center

// Mapeo completo en el archivo
```

### 3. Gradientes Dinámicos

```dart
// Gradientes con soporte para modo oscuro
final gradientColors = WorkoutUtils.getGradientColors(
  'Fuerza',
  isDark: true,
);
// Returns: [Color(0xFFE53E3E), Color(0xFFC53030)] ajustados para dark mode

// Uso típico
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: WorkoutUtils.getGradientColors(focus, isDark: isDark),
    ),
  ),
)
```

### 4. Formato de Fechas Relativas

```dart
// Fechas humanizadas
final dateStr = WorkoutUtils.formatRelativeDate(workout.createdAt);

// Ejemplos:
- Hoy → "Hoy"
- Ayer → "Ayer"
- 3 días atrás → "Hace 3 días"
- >7 días → "15/10/2025"
```

## 🔧 Cómo Usar

### En tu widget

```dart
import 'package:tribbe_app/shared/utils/workout_utils.dart';

// Ejemplo completo
class WorkoutCard extends StatelessWidget {
  final String focus;
  
  @override
  Widget build(BuildContext context) {
    final color = WorkoutUtils.getFocusColor(focus);
    final icon = WorkoutUtils.getFocusIcon(focus);
    final gradientColors = WorkoutUtils.getGradientColors(
      focus,
      isDark: Theme.of(context).brightness == Brightness.dark,
    );
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          Text(focus, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
```

## 📊 Módulos que lo Utilizan

### 1. Profile
- `workout_history_card.dart` - Cards en historial
- `workout_grid_item.dart` - Grid de workouts
- `workout_summary_image.dart` - Imágenes compartibles

### 2. Training
- `workout_detail_page.dart` - Detalle de entrenamiento
- `training_focus_selector_widget.dart` - Selector de enfoque

### 3. Social
- `workout_post_card.dart` - Posts en feed

## 🎨 Consistencia Visual

Todos los colores e iconos están centralizados para garantizar:
- ✅ **Coherencia**: Mismo color para "Fuerza" en toda la app
- ✅ **Mantenibilidad**: Cambiar un color lo actualiza en todos lados
- ✅ **Escalabilidad**: Fácil agregar nuevos tipos de entrenamiento
- ✅ **Accesibilidad**: Colores con buen contraste

## 🆕 Agregar Nuevo Tipo

```dart
// En workout_utils.dart

// 1. Agregar color
case 'MiNuevoTipo':
  return const Color(0xFF...);

// 2. Agregar icono
case 'MiNuevoTipo':
  return Icons.mi_icono;

// 3. Agregar gradiente
'MiNuevoTipo': [const Color(0xFF...), const Color(0xFF...)],
```

## 📝 Mejoras Futuras

- [ ] Agregar animaciones de transición entre colores
- [ ] Soporte para colores personalizados por usuario
- [ ] Temas alternativos (neón, pastel, etc.)
- [ ] Internacionalización de fechas
- [ ] Cache de gradientes para performance

## 🔗 Archivos Relacionados

- **Selector Modal**: `lib/shared/widgets/focus_selector_modal.dart`
- **Widget de Selector**: `lib/features/training/views/widgets/training_focus_selector_widget.dart`
- **Controller**: `lib/features/training/controllers/training_controller.dart`

---

**Última actualización**: Octubre 2025  
**Ubicación**: `lib/shared/utils/workout_utils.dart`

