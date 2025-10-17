import 'package:tribbe_app/features/training/models/exercise_model.dart';

/// Base de datos local de ejercicios
class ExercisesData {
  static final List<ExerciseTemplate> exercises = [
    ExerciseTemplate(
      id: 'pecho_2',
      name: 'Press Banca Inclinado',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.hombros],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Ajusta el banco a una inclinación de 30-45 grados.
2. Acuéstate en el banco con los pies firmes en el suelo y las escápulas retraídas.
3. Agarra la barra con un agarre un poco más ancho que los hombros.
4. Saca la barra y bájala de forma controlada hacia la parte superior del pecho (clavicular).
5. Empuja la barra hacia arriba hasta la posición inicial, enfocándote en contraer la parte superior del pectoral.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/2/5/17425.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_3',
      name: 'Press con Mancuernas',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.hombros],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en un banco plano con una mancuerna en cada muslo.
2. Acuéstate y usa tus muslos para ayudar a llevar las mancuernas a la posición inicial, a los lados de tu pecho.
3. Exhala y empuja las mancuernas hacia arriba hasta que tus brazos estén casi extendidos. No dejes que choquen en la parte superior.
4. Inhala y baja las mancuernas de forma controlada hasta que sientas un estiramiento en los pectorales.
5. Mantén los pies firmes en el suelo y la espalda apoyada en el banco durante todo el movimiento.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/2/3/17423.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_4',
      name: 'Aperturas con Mancuernas',
      muscleGroup: MuscleGroups.pecho,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate en un banco plano con una mancuerna en cada mano, con las palmas enfrentadas.
2. Extiende los brazos sobre tu pecho, manteniendo una ligera flexión en los codos.
3. Inhala y baja lentamente las mancuernas hacia los lados en un amplio arco, hasta sentir un estiramiento en el pecho.
4. No bajes las mancuernas por debajo del nivel de los hombros.
5. Exhala y utiliza los músculos del pecho para revertir el movimiento y volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/1/5/17415.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_5',
      name: 'Fondos en Paralelas',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Sujétate de las barras paralelas con los brazos extendidos.
2. Para enfocar el trabajo en el pecho, inclina el torso hacia adelante unos 30 grados.
3. Inhala y baja tu cuerpo flexionando los codos hasta que tus hombros estén ligeramente por debajo de los codos.
4. Mantén los codos relativamente cerca del cuerpo.
5. Exhala y empuja con fuerza para volver a la posición inicial, contrayendo los pectorales.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/9/9/17399.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_6',
      name: 'Cruces en Cables',
      muscleGroup: MuscleGroups.pecho,
      equipment: Equipment.polea,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Coloca las poleas a la altura del pecho o ligeramente por encima.
2. Agarra un maneral en cada mano y da un paso adelante para crear tensión.
3. Inclina ligeramente el torso hacia adelante y extiende los brazos hacia los lados con una ligera flexión en los codos.
4. Exhala y junta las manos frente a tu pecho en un movimiento de arco, contrayendo los pectorales.
5. Inhala y regresa lentamente a la posición inicial, controlando la resistencia.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/9/3/17393.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_7',
      name: 'Flexiones',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps, MuscleGroups.abdomen],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Colócate en posición de plancha alta, con las manos un poco más anchas que los hombros.
2. Mantén el cuerpo en una línea recta desde la cabeza hasta los talones, activando el abdomen y los glúteos.
3. Inhala y baja el cuerpo flexionando los codos, hasta que el pecho casi toque el suelo.
4. Mantén los codos en un ángulo de 45 grados respecto a tu cuerpo.
5. Exhala y empuja el suelo con fuerza para volver a la posición inicial.''',
      imageUrl:
          'https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExM2Z0ZzZxN3ZkZm5jM251ZzVpZ2Z2N290b2M4b2k1a2M2b3V5b29yZyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/g03f4hUoI2iE8/giphy.gif',
    ),

    // ========== ESPALDA ==========
    ExerciseTemplate(
      id: 'espalda_1',
      name: 'Dominadas',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Agarra la barra con un agarre prono (palmas hacia adelante) un poco más ancho que tus hombros.
2. Cuelga de la barra con los brazos completamente extendidos.
3. Inicia el movimiento retrayendo y deprimiendo las escápulas (hombros hacia abajo y atrás).
4. Jala tu cuerpo hacia arriba, llevando el pecho hacia la barra. Piensa en llevar los codos hacia abajo y hacia tus costados.
5. Una vez que tu barbilla sobrepase la barra, baja de forma controlada hasta la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/8/5/17385.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_2',
      name: 'Remo con Barra',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Inclina el torso hacia adelante hasta que esté casi paralelo al suelo, manteniendo la espalda recta y las rodillas flexionadas.
2. Agarra la barra con un agarre prono (palmas hacia abajo) un poco más ancho que los hombros.
3. Manteniendo el torso fijo, exhala y jala la barra hacia la parte superior de tu abdomen.
4. Concéntrate en juntar los omóplatos en la parte superior del movimiento.
5. Inhala y baja la barra de forma controlada hasta la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/8/7/17387.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_3',
      name: 'Remo con Mancuerna',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Coloca una rodilla y la mano del mismo lado sobre un banco plano para apoyarte.
2. Mantén la espalda recta y paralela al suelo. Agarra una mancuerna con la mano libre.
3. Exhala y jala la mancuerna hacia arriba, llevándola hacia tu cadera. Mantén el codo cerca de tu cuerpo.
4. Contraiga los músculos de la espalda en la parte superior del movimiento.
5. Inhala y baja la mancuerna de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/0/9/17409.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_4',
      name: 'Peso Muerto',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.piernas, MuscleGroups.gluteos],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.avanzado,
      instructions:
          '''1. Colócate de pie con los pies al ancho de las caderas y la barra sobre la mitad de tus pies.
2. Incline las caderas hacia atrás y flexione las rodillas para agarrar la barra, manteniendo la espalda recta y el pecho hacia arriba.
3. Inhala, activa el abdomen y levanta la barra empujando el suelo con las piernas.
4. A medida que la barra pasa las rodillas, extiende las caderas hasta estar completamente erguido. Mantén la barra cerca de tu cuerpo.
5. Baja la barra de forma controlada invirtiendo el movimiento.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/8/9/17389.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_5',
      name: 'Jalón al Pecho',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en la máquina y ajusta el soporte de las rodillas.
2. Agarra la barra con un agarre prono (palmas hacia adelante) más ancho que tus hombros.
3. Inclínate ligeramente hacia atrás, saca el pecho y mantén la espalda recta.
4. Exhala y jala la barra hacia la parte superior de su pecho, llevando los codos hacia abajo y hacia atrás.
5. Inhala y regresa lentamente la barra a la posición inicial, permitiendo un estiramiento completo de los dorsales.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/6/1/17461.gif',
    ),

    // ========== PIERNAS ==========
    ExerciseTemplate(
      id: 'piernas_1',
      name: 'Sentadilla',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Coloca la barra sobre tus trapecios, no sobre el cuello.
2. Párate con los pies al ancho de los hombros y las puntas ligeramente hacia afuera.
3. Mantén la espalda recta y el pecho erguido. Inhala y baja las caderas hacia atrás y hacia abajo, como si te sentaras en una silla.
4. Baja hasta que tus muslos estén paralelos al suelo o tan bajo como tu movilidad lo permita.
5. Exhala y empuja a través de los talones para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/7/1/17371.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_2',
      name: 'Sentadilla con Mancuernas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Sostén una mancuerna en cada mano a los lados de tu cuerpo.
2. Párate con los pies al ancho de los hombros y las puntas ligeramente hacia afuera.
3. Mantén la espalda recta y el pecho erguido. Baja las caderas hacia atrás y hacia abajo.
4. Baja hasta que tus muslos estén paralelos al suelo.
5. Empuja con los talones para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/4/9/17549.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_3',
      name: 'Zancadas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Sostén una mancuerna en cada mano y da un paso largo hacia adelante.
2. Baja la cadera hasta que ambas rodillas estén flexionadas en un ángulo de 90 grados. La rodilla delantera no debe sobrepasar el tobillo.
3. La rodilla trasera debe estar cerca del suelo pero sin tocarlo.
4. Mantén el torso erguido y el abdomen contraído.
5. Empuja con el pie delantero para volver a la posición inicial y repite con la otra pierna.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/5/5/17555.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_4',
      name: 'Prensa de Piernas',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en la máquina con la espalda y la cabeza apoyadas en el respaldo.
2. Coloca los pies en la plataforma al ancho de los hombros.
3. Libera los seguros y baja la plataforma de forma controlada flexionando las rodillas.
4. Baja hasta que tus rodillas formen un ángulo de 90 grados.
5. Empuja la plataforma con fuerza para volver a la posición inicial, pero sin bloquear las rodillas.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/9/7/17497.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_5',
      name: 'Curl Femoral',
      muscleGroup: MuscleGroups.piernas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate boca abajo en la máquina y ajusta el rodillo sobre tus tobillos.
2. Sujeta las agarraderas para mantener la estabilidad.
3. Flexiona las rodillas para levantar el peso, llevando los talones hacia tus glúteos.
4. Contrae los isquiotibiales en la parte superior del movimiento.
5. Baja el peso de forma controlada hasta la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/8/9/17489.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_6',
      name: 'Extensión de Cuádriceps',
      muscleGroup: MuscleGroups.piernas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en la máquina con la espalda apoyada y ajusta el rodillo sobre la parte inferior de tus tibias.
2. Sujeta las agarraderas laterales.
3. Extiende las piernas hacia arriba hasta que estén completamente rectas.
4. Contrae los cuádriceps en la parte superior del movimiento durante un segundo.
5. Baja el peso de forma controlada hasta la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/2/0/8/2/2082.gif',
    ),

    // ========== HOMBROS ==========
    ExerciseTemplate(
      id: 'hombros_1',
      name: 'Press Militar',
      muscleGroup: MuscleGroups.hombros,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. De pie, sostén la barra a la altura de la parte superior del pecho, con las manos un poco más anchas que los hombros.
2. Mantén el abdomen y los glúteos contraídos para estabilizar el cuerpo.
3. Exhala y empuja la barra verticalmente hacia arriba hasta que los brazos estén completamente extendidos sobre la cabeza.
4. Mantén el control y no arquees la espalda baja.
5. Inhala y baja la barra de forma controlada a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/4/3/17443.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_2',
      name: 'Press con Mancuernas',
      muscleGroup: MuscleGroups.hombros,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en un banco con respaldo. Sostén una mancuerna en cada mano a la altura de los hombros, con las palmas hacia adelante.
2. Mantén la espalda recta y el abdomen contraído.
3. Exhala y empuja las mancuernas hacia arriba hasta que los brazos estén casi completamente extendidos.
4. No dejes que las mancuernas choquen en la parte superior.
5. Inhala y baja las mancuernas de forma controlada a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/4/5/17445.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_3',
      name: 'Elevaciones Laterales',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie, sostén una mancuerna en cada mano a los lados de tu cuerpo, con las palmas hacia adentro.
2. Mantén una ligera flexión en los codos y el torso recto.
3. Eleva los brazos hacia los lados hasta que estén paralelos al suelo (a la altura de los hombros).
4. Lidera el movimiento con los codos, no con las muñecas.
5. Baja las mancuernas de forma controlada a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/6/5/17565.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_4',
      name: 'Elevaciones Frontales',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie, sostén una mancuerna en cada mano frente a tus muslos, con las palmas hacia abajo o neutras.
2. Mantén el torso recto y los brazos casi extendidos.
3. Eleva una mancuerna hacia adelante hasta que esté a la altura de los hombros.
4. Baja la mancuerna de forma controlada y repite con el otro brazo, o eleva ambas al mismo tiempo.
5. Evita balancear el cuerpo para generar impulso.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/6/3/17563.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_5',
      name: 'Face Pull',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.polea,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Ajusta la polea a la altura del pecho y usa un accesorio de cuerda.
2. Sujeta la cuerda con ambas manos y da un paso atrás para crear tensión.
3. Jala la cuerda hacia tu cara, separando las manos y llevando los codos hacia arriba y hacia afuera.
4. Aprieta los omóplatos en la posición final, con las manos a la altura de las orejas.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/2/0/9/0/2090.gif',
    ),

    // ========== BÍCEPS ==========
    ExerciseTemplate(
      id: 'biceps_1',
      name: 'Curl con Barra',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie, sujeta la barra con un agarre supino (palmas hacia arriba) al ancho de los hombros.
2. Mantén los codos pegados a los costados del cuerpo.
3. Flexiona los codos para levantar la barra hacia tus hombros, contrayendo los bíceps.
4. Mantén el torso recto y evita balancearte.
5. Baja la barra de forma controlada hasta la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/5/1/17451.gif',
    ),
    ExerciseTemplate(
      id: 'biceps_2',
      name: 'Curl con Mancuernas',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie o sentado, sostén una mancuerna en cada mano con agarre supino (palmas hacia arriba).
2. Mantén los codos pegados a los costados.
3. Flexiona un codo para levantar la mancuerna hacia el hombro. Gira la muñeca (supinación) durante el movimiento.
4. Contrae el bíceps en la parte superior.
5. Baja la mancuerna de forma controlada y repite con el otro brazo.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/8/1/17581.gif',
    ),
    ExerciseTemplate(
      id: 'biceps_3',
      name: 'Curl Martillo',
      muscleGroup: MuscleGroups.biceps,
      secondaryMuscles: [MuscleGroups.antebrazos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie, sostén una mancuerna en cada mano con un agarre neutro (palmas enfrentadas), como si sostuvieras un martillo.
2. Mantén los codos pegados a los costados.
3. Flexiona los codos para levantar las mancuernas hacia los hombros.
4. No gires las muñecas durante el movimiento.
5. Baja las mancuernas de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/8/3/17583.gif',
    ),
    ExerciseTemplate(
      id: 'biceps_4',
      name: 'Curl en Banco Scott',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Siéntate en el banco Scott y apoya la parte posterior de tus brazos en el cojín.
2. Sujeta la barra (recta o Z) con un agarre supino.
3. Baja la barra de forma controlada hasta que tus brazos estén casi completamente extendidos.
4. Flexiona los codos para levantar la barra, contrayendo fuertemente los bíceps en la parte superior.
5. Evita levantar los codos del cojín.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/5/5/17455.gif',
    ),

    // ========== TRÍCEPS ==========
    ExerciseTemplate(
      id: 'triceps_1',
      name: 'Press Francés',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Acuéstate en un banco plano y sujeta una barra (recta o Z) sobre tu pecho con los brazos extendidos.
2. Mantén los brazos fijos y flexiona los codos para bajar la barra hacia tu frente.
3. Baja de forma controlada hasta que la barra casi toque tu frente.
4. Usa la fuerza de los tríceps para extender los codos y volver a la posición inicial.
5. No abras los codos hacia los lados.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/3/1/17431.gif',
    ),
    ExerciseTemplate(
      id: 'triceps_2',
      name: 'Extensiones con Mancuerna',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Sentado o de pie, sujeta una mancuerna con ambas manos y elévala sobre tu cabeza.
2. Mantén los brazos cerca de la cabeza y flexiona los codos para bajar la mancuerna por detrás de la cabeza.
3. Siente el estiramiento en los tríceps.
4. Extiende los codos para levantar la mancuerna de nuevo a la posición inicial.
5. Mantén el movimiento controlado.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/9/1/17591.gif',
    ),
    ExerciseTemplate(
      id: 'triceps_3',
      name: 'Fondos en Banco',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.banca,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en el borde de un banco y coloca las manos a los lados de tus caderas.
2. Desliza tu cadera hacia adelante, fuera del banco, y apoya tu peso en tus brazos.
3. Flexiona los codos para bajar tu cuerpo hasta que tus brazos formen un ángulo de 90 grados.
4. Mantén la espalda cerca del banco.
5. Empuja con las manos para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/6/0/1/17601.gif',
    ),
    ExerciseTemplate(
      id: 'triceps_4',
      name: 'Press en Polea',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie frente a una polea alta, sujeta una barra recta o una cuerda con un agarre prono (palmas hacia abajo).
2. Mantén los codos pegados a los costados.
3. Extiende los brazos hacia abajo hasta que estén completamente rectos, contrayendo los tríceps.
4. Mantén el torso recto y no uses el impulso del cuerpo.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/7/5/17475.gif',
    ),

    // ========== ABDOMEN ==========
    ExerciseTemplate(
      id: 'abdomen_1',
      name: 'Plancha',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Apoya los antebrazos y las puntas de los pies en el suelo.
2. Mantén el cuerpo en una línea recta desde la cabeza hasta los talones.
3. Contrae el abdomen y los glúteos para evitar que la cadera se hunda o se eleve demasiado.
4. Mantén la posición durante el tiempo deseado.
5. Respira de manera constante y controlada.''',
      imageUrl:
          'https://media.tenor.com/images/265d5191a3717057a7f59556f749651c/tenor.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_2',
      name: 'Crunches',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate boca arriba con las rodillas flexionadas y los pies en el suelo.
2. Coloca las manos detrás de la cabeza sin entrelazar los dedos, o cruzadas sobre el pecho.
3. Levanta la cabeza y los hombros del suelo, contrayendo el abdomen.
4. Mantén la zona lumbar pegada al suelo.
5. Baja de forma controlada a la posición inicial.''',
      imageUrl: 'https://commons.wikimedia.org/wiki/File:Sit-ups_or_Crunch.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_3',
      name: 'Elevación de Piernas',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Acuéstate boca arriba con las piernas extendidas y las manos debajo de los glúteos para mayor soporte.
2. Mantén las piernas rectas y juntas.
3. Levanta las piernas hacia el techo hasta que formen un ángulo de 90 grados con el suelo.
4. Contrae el abdomen y evita arquear la espalda baja.
5. Baja las piernas de forma lenta y controlada sin que toquen el suelo.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/3/1/17531.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_4',
      name: 'Russian Twist',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.balon,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Siéntate en el suelo con las rodillas flexionadas y los pies elevados.
2. Inclina el torso hacia atrás unos 45 grados, manteniendo la espalda recta.
3. Sostén un balón medicinal o una pesa con ambas manos.
4. Gira el torso de un lado a otro, tocando el suelo a cada lado con el peso.
5. Mantén el abdomen contraído y el movimiento controlado.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/7/9/17379.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_5',
      name: 'Ab Wheel',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.maquina,
      difficulty: Difficulty.avanzado,
      instructions:
          '''1. Arrodíllate en el suelo y sujeta la rueda abdominal con ambas manos.
2. Rueda lentamente hacia adelante, extendiendo el cuerpo en una línea recta.
3. Mantén el abdomen contraído y no arquees la espalda.
4. Extiéndete tan lejos como puedas manteniendo el control.
5. Usa los músculos abdominales para volver a la posición inicial.''',
      imageUrl:
          'https://media.tenor.com/images/e64468b83929493f350f7f70b4352c38/tenor.gif',
    ),

    // ========== GLÚTEOS ==========
    ExerciseTemplate(
      id: 'gluteos_1',
      name: 'Hip Thrust',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Siéntate en el suelo con la parte superior de la espalda apoyada en un banco.
2. Coloca una barra sobre tus caderas. Puedes usar una almohadilla para mayor comodidad.
3. Con las rodillas flexionadas y los pies en el suelo, empuja las caderas hacia arriba hasta que tu cuerpo forme una línea recta desde los hombros hasta las rodillas.
4. Contrae los glúteos fuertemente en la parte superior.
5. Baja las caderas de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/9/1/17391.gif',
    ),
    ExerciseTemplate(
      id: 'gluteos_2',
      name: 'Puente de Glúteos',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate boca arriba con las rodillas flexionadas y los pies apoyados en el suelo, cerca de los glúteos.
2. Coloca los brazos a los lados con las palmas hacia abajo.
3. Levanta las caderas del suelo hasta que tu cuerpo forme una línea recta desde los hombros hasta las rodillas.
4. Contrae los glúteos en la parte superior.
5. Baja las caderas de forma controlada sin tocar el suelo y repite.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/2/1/17521.gif',
    ),
    ExerciseTemplate(
      id: 'gluteos_3',
      name: 'Patada de Glúteo en Cable',
      muscleGroup: MuscleGroups.gluteos,
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions: '''1. Engancha un grillete de tobillo a una polea baja.
2. De cara a la máquina, inclina el torso hacia adelante y sujétate para mantener el equilibrio.
3. Extiende la pierna enganchada hacia atrás y hacia arriba, contrayendo el glúteo.
4. Mantén la espalda recta y evita arquearla.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/8/1/17481.gif',
    ),
    ExerciseTemplate(
      id: 'gluteos_4',
      name: 'Peso Muerto Rumano',
      muscleGroup: MuscleGroups.gluteos,
      secondaryMuscles: [MuscleGroups.piernas],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. De pie, sostén una barra o mancuernas frente a tus muslos.
2. Mantén las piernas casi rectas (con una ligera flexión en las rodillas).
3. Inclina el torso hacia adelante desde las caderas, manteniendo la espalda recta.
4. Baja el peso a lo largo de tus piernas hasta que sientas un estiramiento en los isquiotibiales.
5. Usa los glúteos y los isquiotibiales para volver a la posición erguida.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/9/0/17390.gif',
    ),
    ExerciseTemplate(
      id: 'gluteos_5',
      name: 'Sentadilla Búlgara',
      muscleGroup: MuscleGroups.gluteos,
      secondaryMuscles: [MuscleGroups.piernas],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Coloca el empeine de un pie en un banco detrás de ti.
2. Da un paso hacia adelante con el otro pie.
3. Baja la cadera hasta que el muslo delantero esté paralelo al suelo.
4. Mantén el torso erguido y el equilibrio.
5. Empuja con el pie delantero para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/5/3/17553.gif',
    ),

    // ========== PANTORRILLAS ==========
    ExerciseTemplate(
      id: 'pantorrillas_1',
      name: 'Elevación de Talones de Pie',
      muscleGroup: MuscleGroups.pantorrillas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Colócate en la máquina con los hombros debajo de las almohadillas.
2. Apoya la parte delantera de tus pies en la plataforma, con los talones colgando.
3. Empuja hacia arriba con las puntas de los pies, levantando los talones lo más alto posible.
4. Contrae las pantorrillas en la parte superior.
5. Baja los talones de forma controlada por debajo del nivel de la plataforma para sentir un estiramiento.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/0/7/17507.gif',
    ),
    ExerciseTemplate(
      id: 'pantorrillas_2',
      name: 'Elevación de Talones Sentado',
      muscleGroup: MuscleGroups.pantorrillas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en la máquina y coloca las rodillas debajo de la almohadilla.
2. Apoya la parte delantera de tus pies en la plataforma.
3. Levanta los talones empujando con las puntas de los pies.
4. Contrae las pantorrillas en la parte superior.
5. Baja los talones de forma controlada para estirar el músculo.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/0/9/17509.gif',
    ),
    ExerciseTemplate(
      id: 'pantorrillas_3',
      name: 'Elevación con Mancuernas',
      muscleGroup: MuscleGroups.pantorrillas,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions: '''1. Sostén una mancuerna en cada mano.
2. Párate con los pies apoyados en el suelo o con la parte delantera en un escalón.
3. Levanta los talones lo más alto posible, contrayendo las pantorrillas.
4. Mantén la posición por un segundo.
5. Baja los talones de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/7/5/17575.gif',
    ),
    ExerciseTemplate(
      id: 'pantorrillas_4',
      name: 'Saltos de Pantorrilla',
      muscleGroup: MuscleGroups.pantorrillas,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions: '''1. De pie, con los pies al ancho de los hombros.
2. Realiza un pequeño salto vertical, impulsándote principalmente con las pantorrillas.
3. Aterriza suavemente sobre las puntas de los pies.
4. Mantén las rodillas ligeramente flexionadas durante todo el movimiento.
5. Realiza los saltos de forma continua y rítmica.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/6/1/5/17615.gif',
    ),

    // ========== ANTEBRAZOS ==========
    ExerciseTemplate(
      id: 'antebrazos_1',
      name: 'Curl de Muñeca',
      muscleGroup: MuscleGroups.antebrazos,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en un banco y apoya los antebrazos en tus muslos, con las palmas hacia arriba.
2. Sujeta una mancuerna o barra y deja que la muñeca se extienda hacia abajo.
3. Flexiona la muñeca para levantar el peso.
4. Contrae los músculos del antebrazo en la parte superior.
5. Baja el peso de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/9/7/17597.gif',
    ),
    ExerciseTemplate(
      id: 'antebrazos_2',
      name: 'Curl Inverso de Muñeca',
      muscleGroup: MuscleGroups.antebrazos,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en un banco y apoya los antebrazos en tus muslos, con las palmas hacia abajo.
2. Sujeta una mancuerna o barra.
3. Extiende la muñeca hacia arriba, levantando el peso.
4. Contrae los músculos extensores del antebrazo.
5. Baja el peso de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/9/9/17599.gif',
    ),
    ExerciseTemplate(
      id: 'antebrazos_3',
      name: 'Agarre de Barra',
      muscleGroup: MuscleGroups.antebrazos,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Carga una barra con un peso desafiante.
2. Levanta la barra del suelo como en un peso muerto.
3. Sostén la barra con un agarre fuerte durante el mayor tiempo posible.
4. Mantén la espalda recta y los hombros hacia atrás.
5. Este ejercicio mejora la fuerza de agarre.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/8/9/17389.gif',
    ),
    ExerciseTemplate(
      id: 'antebrazos_4',
      name: 'Farmers Walk',
      muscleGroup: MuscleGroups.antebrazos,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Sujeta una mancuerna pesada en cada mano.
2. Camina una distancia determinada manteniendo la postura erguida.
3. Mantén el abdomen contraído, los hombros hacia atrás y la mirada al frente.
4. No dejes que las pesas te desequilibren.
5. Este ejercicio trabaja la fuerza de agarre y la estabilidad del core.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/6/0/7/17607.gif',
    ),

    // ========== MÁS EJERCICIOS DE PECHO ==========
    ExerciseTemplate(
      id: 'pecho_8',
      name: 'Press Declinado',
      muscleGroup: MuscleGroups.pecho,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Acuéstate en un banco declinado y asegura tus pies.
2. Agarra la barra con un agarre un poco más ancho que los hombros.
3. Baja la barra de forma controlada hacia la parte inferior de tu pecho.
4. Empuja la barra hacia arriba hasta la posición inicial.
5. Este ejercicio se enfoca en la porción inferior del pectoral.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/2/1/17421.gif',
    ),
    ExerciseTemplate(
      id: 'pecho_9',
      name: 'Aperturas en Polea',
      muscleGroup: MuscleGroups.pecho,
      equipment: Equipment.polea,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Coloca las poleas a la altura deseada (alta, media o baja).
2. Agarra los manerales y da un paso adelante.
3. Con los codos ligeramente flexionados, junta las manos frente a tu cuerpo en un movimiento de arco.
4. Contrae el pecho en el punto de máxima contracción.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/9/3/17393.gif',
    ),

    // ========== MÁS EJERCICIOS DE ESPALDA ==========
    ExerciseTemplate(
      id: 'espalda_6',
      name: 'Face Pull con Polea',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.hombros],
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Ajusta la polea a la altura del pecho y usa un accesorio de cuerda.
2. Sujeta la cuerda con ambas manos y da un paso atrás para crear tensión.
3. Jala la cuerda hacia tu cara, separando las manos y llevando los codos hacia arriba y hacia afuera.
4. Aprieta los omóplatos en la posición final, con las manos a la altura de las orejas.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/2/0/9/0/2090.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_7',
      name: 'Pullover con Mancuerna',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.pecho],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Acuéstate de forma transversal en un banco plano, apoyando solo la parte superior de la espalda.
2. Sujeta una mancuerna con ambas manos sobre tu pecho.
3. Con los codos ligeramente flexionados, baja la mancuerna por detrás de tu cabeza en un arco.
4. Siente el estiramiento en los dorsales y el pecho.
5. Regresa la mancuerna a la posición inicial usando la fuerza de la espalda.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/1/3/17413.gif',
    ),
    ExerciseTemplate(
      id: 'espalda_8',
      name: 'Remo en Polea Baja',
      muscleGroup: MuscleGroups.espalda,
      secondaryMuscles: [MuscleGroups.biceps],
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Siéntate en la máquina con los pies en los soportes y las rodillas ligeramente flexionadas.
2. Sujeta el agarre (generalmente un triángulo) con ambas manos.
3. Mantén la espalda recta y jala el agarre hacia tu abdomen.
4. Contrae los músculos de la espalda y junta los omóplatos.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/7/1/17471.gif',
    ),

    // ========== MÁS EJERCICIOS DE HOMBROS ==========
    ExerciseTemplate(
      id: 'hombros_6',
      name: 'Pájaros',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Inclina el torso hacia adelante con la espalda recta, casi paralela al suelo.
2. Sostén una mancuerna en cada mano con los brazos extendidos hacia el suelo.
3. Mantén una ligera flexión en los codos.
4. Eleva los brazos hacia los lados, contrayendo los deltoides posteriores (la parte de atrás del hombro).
5. Baja las mancuernas de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/6/9/17569.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_7',
      name: 'Press Arnold',
      muscleGroup: MuscleGroups.hombros,
      secondaryMuscles: [MuscleGroups.triceps],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Siéntate en un banco y sostén las mancuernas frente a tus hombros con las palmas hacia ti.
2. Inicia el movimiento elevando las mancuernas mientras giras las muñecas, de modo que las palmas terminen mirando hacia adelante en la parte superior.
3. Extiende los brazos completamente sobre la cabeza.
4. Invierte el movimiento de forma controlada para volver a la posición inicial.
5. Mantén el movimiento fluido y sin impulso.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/4/7/17447.gif',
    ),
    ExerciseTemplate(
      id: 'hombros_8',
      name: 'Remo al Cuello',
      muscleGroup: MuscleGroups.hombros,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. De pie, sujeta una barra con un agarre prono, con las manos más juntas que el ancho de los hombros.
2. Levanta la barra verticalmente hasta la altura de tu barbilla, liderando con los codos.
3. Mantén los codos por encima de las manos durante todo el movimiento.
4. Contrae los hombros y trapecios en la parte superior.
5. Baja la barra de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/4/1/17441.gif',
    ),

    // ========== MÁS EJERCICIOS DE BÍCEPS ==========
    ExerciseTemplate(
      id: 'biceps_5',
      name: 'Curl en Polea',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions: '''1. Coloca una barra recta o un maneral en una polea baja.
2. De pie frente a la máquina, sujeta el agarre con las palmas hacia arriba.
3. Mantén los codos pegados a los costados y flexiónalos para levantar el peso.
4. Contrae los bíceps en la parte superior del movimiento.
5. Regresa a la posición inicial de forma controlada, manteniendo la tensión constante.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/7/9/17479.gif',
    ),
    ExerciseTemplate(
      id: 'biceps_6',
      name: 'Curl 21s',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.avanzado,
      instructions:
          '''Este ejercicio se divide en 3 fases de 7 repeticiones cada una, sin descanso entre ellas.
1. Fase 1 (7 reps): Realiza el curl desde la posición inicial (brazos extendidos) hasta la mitad del recorrido (codos a 90 grados).
2. Fase 2 (7 reps): Realiza el curl desde la mitad del recorrido hasta la contracción máxima (hombros).
3. Fase 3 (7 reps): Realiza 7 repeticiones completas del curl de bíceps.''',
      imageUrl: 'https://gymvisual.com/img/p/2/2/8/9/8/22898.gif',
    ),
    ExerciseTemplate(
      id: 'biceps_7',
      name: 'Curl Concentrado',
      muscleGroup: MuscleGroups.biceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions: '''1. Siéntate en un banco e inclínate hacia adelante.
2. Apoya la parte posterior de tu brazo en la parte interna de tu muslo.
3. Sujeta una mancuerna con el brazo extendido.
4. Flexiona el codo para levantar la mancuerna hacia tu pecho, enfocándote en la contracción del bíceps.
5. Baja la mancuerna de forma lenta y controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/8/5/17585.gif',
    ),

    // ========== MÁS EJERCICIOS DE TRÍCEPS ==========
    ExerciseTemplate(
      id: 'triceps_5',
      name: 'Extensión con Polea',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.polea,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. De pie frente a una polea alta, sujeta una cuerda con ambas manos.
2. Mantén los codos pegados a los costados y ligeramente flexionados.
3. Extiende los brazos hacia abajo, separando las manos al final del movimiento para una mayor contracción.
4. Contrae los tríceps en la posición final.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/7/7/17477.gif',
    ),
    ExerciseTemplate(
      id: 'triceps_6',
      name: 'Press Cerrado',
      muscleGroup: MuscleGroups.triceps,
      secondaryMuscles: [MuscleGroups.pecho],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Acuéstate en un banco plano como en un press banca normal.
2. Agarra la barra con las manos juntas, aproximadamente al ancho de los hombros o un poco menos.
3. Baja la barra hacia la parte inferior del pecho, manteniendo los codos pegados al cuerpo.
4. Empuja la barra hacia arriba, enfocando la fuerza en los tríceps.
5. No bloquees los codos en la parte superior.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/2/9/17429.gif',
    ),
    ExerciseTemplate(
      id: 'triceps_7',
      name: 'Patada de Tríceps',
      muscleGroup: MuscleGroups.triceps,
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Inclina el torso hacia adelante con la espalda recta y apoya una mano en un banco.
2. Sostén una mancuerna con la otra mano, con el codo flexionado a 90 grados y el brazo paralelo al suelo.
3. Extiende el brazo hacia atrás hasta que esté completamente recto.
4. Contrae el tríceps en la posición final.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/9/5/17595.gif',
    ),

    // ========== MÁS EJERCICIOS DE PIERNAS ==========
    ExerciseTemplate(
      id: 'piernas_7',
      name: 'Sentadilla Frontal',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.abdomen],
      equipment: Equipment.barraOlimpica,
      difficulty: Difficulty.avanzado,
      instructions:
          '''1. Sostén la barra sobre la parte frontal de tus hombros, cruzando los brazos o con los dedos debajo de la barra.
2. Mantén el torso lo más vertical posible y los codos elevados.
3. Realiza una sentadilla profunda, manteniendo la espalda recta.
4. Este ejercicio pone más énfasis en los cuádriceps y el core.
5. Empuja con fuerza para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/3/7/3/17373.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_8',
      name: 'Hack Squat',
      muscleGroup: MuscleGroups.piernas,
      equipment: Equipment.maquina,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Colócate en la máquina con la espalda apoyada en el respaldo y los hombros debajo de las almohadillas.
2. Pon los pies en la plataforma al ancho de los hombros.
3. Baja de forma controlada flexionando las rodillas, manteniendo la espalda pegada al respaldo.
4. Baja hasta que tus muslos estén paralelos a la plataforma.
5. Empuja con fuerza para volver a la posición inicial.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/9/5/17495.gif',
    ),
    ExerciseTemplate(
      id: 'piernas_9',
      name: 'Step Up',
      muscleGroup: MuscleGroups.piernas,
      secondaryMuscles: [MuscleGroups.gluteos],
      equipment: Equipment.mancuernas,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Párate frente a un banco o cajón resistente, sosteniendo mancuernas si lo deseas.
2. Sube un pie a la plataforma.
3. Empuja con esa pierna para levantar todo tu cuerpo hasta que estés de pie sobre el banco.
4. Baja de forma controlada con la misma pierna.
5. Completa las repeticiones con una pierna antes de cambiar a la otra.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/5/7/17557.gif',
    ),

    // ========== MÁS EJERCICIOS DE ABDOMEN ==========
    ExerciseTemplate(
      id: 'abdomen_6',
      name: 'Bicicleta',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate boca arriba con las manos detrás de la cabeza.
2. Levanta las rodillas a un ángulo de 90 grados.
3. Lleva tu codo derecho hacia tu rodilla izquierda mientras extiendes la pierna derecha.
4. Alterna los lados en un movimiento de pedaleo continuo.
5. Mantén el movimiento controlado y enfócate en la contracción de los oblicuos.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/2/5/17525.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_7',
      name: 'Mountain Climbers',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.intermedio,
      instructions: '''1. Comienza en una posición de plancha alta.
2. Lleva una rodilla hacia tu pecho, manteniendo el abdomen contraído.
3. Rápidamente, alterna las piernas como si estuvieras corriendo en el lugar.
4. Mantén la cadera baja y el cuerpo en una línea recta.
5. Realiza el movimiento de forma explosiva y continua.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/6/1/1/17611.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_8',
      name: 'Crunch en Polea',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.polea,
      difficulty: Difficulty.intermedio,
      instructions:
          '''1. Arrodíllate frente a una polea alta con un accesorio de cuerda.
2. Sujeta la cuerda a cada lado de tu cabeza.
3. Contrae el abdomen para flexionar la columna, llevando los codos hacia las rodillas.
4. Mantén las caderas fijas durante el movimiento.
5. Regresa a la posición inicial de forma controlada.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/4/8/5/17485.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_9',
      name: 'L-Sit',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.avanzado,
      instructions:
          '''1. Siéntate en el suelo con las piernas extendidas y las manos apoyadas a los lados de las caderas.
2. Empuja el suelo con las manos para levantar tu cuerpo y tus piernas.
3. Mantén las piernas rectas y paralelas al suelo, formando una 'L' con tu cuerpo.
4. Sostén la posición el mayor tiempo posible, manteniendo el abdomen y los brazos contraídos.
5. Este es un ejercicio isométrico avanzado.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/3/5/17535.gif',
    ),
    ExerciseTemplate(
      id: 'abdomen_10',
      name: 'Plancha Lateral',
      muscleGroup: MuscleGroups.abdomen,
      equipment: Equipment.pesoCorporal,
      difficulty: Difficulty.principiante,
      instructions:
          '''1. Acuéstate de lado y apoya tu peso sobre un antebrazo, con el codo directamente debajo del hombro.
2. Levanta las caderas hasta que tu cuerpo forme una línea recta desde la cabeza hasta los pies.
3. Mantén el abdomen contraído y no dejes que la cadera caiga.
4. Sostén la posición durante el tiempo deseado y luego cambia de lado.
5. Para mayor dificultad, puedes levantar la pierna superior.''',
      imageUrl: 'https://gymvisual.com/img/p/1/7/5/4/1/17541.gif',
    ),
  ];

  /// Obtener ejercicios filtrados por grupo muscular y equipamiento
  static List<ExerciseTemplate> getFiltered({
    String? muscleGroup,
    List<String>? equipment,
  }) {
    return exercises.where((exercise) {
      // Filtro por grupo muscular
      if (muscleGroup != null && muscleGroup.isNotEmpty) {
        if (exercise.muscleGroup != muscleGroup &&
            !exercise.secondaryMuscles.contains(muscleGroup)) {
          return false;
        }
      }

      // Filtro por equipamiento
      if (equipment != null && equipment.isNotEmpty) {
        if (!equipment.contains(exercise.equipment)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Buscar ejercicios por nombre
  static List<ExerciseTemplate> search(String query) {
    if (query.isEmpty) return exercises;

    final lowerQuery = query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(lowerQuery) ||
          exercise.muscleGroup.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
