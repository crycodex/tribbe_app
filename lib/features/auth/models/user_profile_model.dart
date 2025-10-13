/// Modelo para el perfil completo del usuario en Firestore
class UserProfileModel {
  UserProfileModel({
    required this.uid,
    required this.email,
    this.datosPersonales,
    this.preferencias,
    this.informacion,
    this.personaje,
    this.medidas,
    this.hasCompletedPersonalization = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final DatosPersonales? datosPersonales;
  final Preferencias? preferencias;
  final Informacion? informacion;
  final Personaje? personaje;
  final Medidas? medidas;
  final bool hasCompletedPersonalization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Crea una instancia desde JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      datosPersonales: json['datos_personales'] != null
          ? DatosPersonales.fromJson(
              json['datos_personales'] as Map<String, dynamic>,
            )
          : null,
      preferencias: json['preferencias'] != null
          ? Preferencias.fromJson(json['preferencias'] as Map<String, dynamic>)
          : null,
      informacion: json['informacion'] != null
          ? Informacion.fromJson(json['informacion'] as Map<String, dynamic>)
          : null,
      personaje: json['personaje'] != null
          ? Personaje.fromJson(json['personaje'] as Map<String, dynamic>)
          : null,
      medidas: json['medidas'] != null
          ? Medidas.fromJson(json['medidas'] as Map<String, dynamic>)
          : null,
      hasCompletedPersonalization:
          json['has_completed_personalization'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'datos_personales': datosPersonales?.toJson(),
      'preferencias': preferencias?.toJson(),
      'informacion': informacion?.toJson(),
      'personaje': personaje?.toJson(),
      'medidas': medidas?.toJson(),
      'has_completed_personalization': hasCompletedPersonalization,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia con campos modificados
  UserProfileModel copyWith({
    String? uid,
    String? email,
    DatosPersonales? datosPersonales,
    Preferencias? preferencias,
    Informacion? informacion,
    Personaje? personaje,
    Medidas? medidas,
    bool? hasCompletedPersonalization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      datosPersonales: datosPersonales ?? this.datosPersonales,
      preferencias: preferencias ?? this.preferencias,
      informacion: informacion ?? this.informacion,
      personaje: personaje ?? this.personaje,
      medidas: medidas ?? this.medidas,
      hasCompletedPersonalization:
          hasCompletedPersonalization ?? this.hasCompletedPersonalization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Datos personales del usuario
class DatosPersonales {
  DatosPersonales({
    this.nombreCompleto,
    this.nombreUsuario,
    this.fechaNacimiento,
    this.ubicacion,
  });

  final String? nombreCompleto;
  final String? nombreUsuario;
  final String? fechaNacimiento;
  final Ubicacion? ubicacion;

  factory DatosPersonales.fromJson(Map<String, dynamic> json) {
    return DatosPersonales(
      nombreCompleto: json['nombre_completo'] as String?,
      nombreUsuario: json['nombre_usuario'] as String?,
      fechaNacimiento: json['fecha_nacimiento'] as String?,
      ubicacion: json['ubicacion'] != null
          ? Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_completo': nombreCompleto,
      'nombre_usuario': nombreUsuario,
      'fecha_nacimiento': fechaNacimiento,
      'ubicacion': ubicacion?.toJson(),
    };
  }
}

/// Ubicación del usuario
class Ubicacion {
  Ubicacion({
    this.pais,
    this.provincia,
    this.ciudad,
    this.latitud,
    this.longitud,
  });

  final String? pais;
  final String? provincia;
  final String? ciudad;
  final double? latitud;
  final double? longitud;

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      pais: json['pais'] as String?,
      provincia: json['provincia'] as String?,
      ciudad: json['ciudad'] as String?,
      latitud: json['latitud'] != null
          ? (json['latitud'] as num).toDouble()
          : null,
      longitud: json['longitud'] != null
          ? (json['longitud'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pais': pais,
      'provincia': provincia,
      'ciudad': ciudad,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}

/// Preferencias del usuario
class Preferencias {
  Preferencias({this.tema, this.unidades, this.idioma, this.genero});

  final String? tema;
  final Unidades? unidades;
  final String? idioma;
  final String? genero;

  factory Preferencias.fromJson(Map<String, dynamic> json) {
    return Preferencias(
      tema: json['tema'] as String?,
      unidades: json['unidades'] != null
          ? Unidades.fromJson(json['unidades'] as Map<String, dynamic>)
          : null,
      idioma: json['idioma'] as String?,
      genero: json['genero'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tema': tema,
      'unidades': unidades?.toJson(),
      'idioma': idioma,
      'genero': genero,
    };
  }
}

/// Unidades de medida
class Unidades {
  Unidades({this.medida, this.peso});

  final String? medida;
  final String? peso;

  factory Unidades.fromJson(Map<String, dynamic> json) {
    return Unidades(
      medida: json['medida'] as String?,
      peso: json['peso'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'medida': medida, 'peso': peso};
  }
}

/// Información fitness del usuario
class Informacion {
  Informacion({
    this.proposito,
    this.metaFitness,
    this.lesiones,
    this.nivelExperiencia,
    this.condicionFisicaActual,
  });

  final String? proposito;
  final String? metaFitness;
  final List<String>? lesiones;
  final String? nivelExperiencia;
  final int? condicionFisicaActual;

  factory Informacion.fromJson(Map<String, dynamic> json) {
    return Informacion(
      proposito: json['proposito'] as String?,
      metaFitness: json['meta_fitness'] as String?,
      lesiones: json['lesiones'] != null
          ? List<String>.from(json['lesiones'] as List)
          : null,
      nivelExperiencia: json['nivel_experiencia'] as String?,
      condicionFisicaActual: json['condicion_fisica_actual'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proposito': proposito,
      'meta_fitness': metaFitness,
      'lesiones': lesiones,
      'nivel_experiencia': nivelExperiencia,
      'condicion_fisica_actual': condicionFisicaActual,
    };
  }
}

/// Personaje/Avatar del usuario
class Personaje {
  Personaje({this.genero, this.tonoPiel, this.avatarUrl});

  final String? genero;
  final String? tonoPiel;
  final String? avatarUrl;

  factory Personaje.fromJson(Map<String, dynamic> json) {
    return Personaje(
      genero: json['genero'] as String?,
      tonoPiel: json['tono_piel'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'genero': genero, 'tono_piel': tonoPiel, 'avatar_url': avatarUrl};
  }
}

/// Medidas corporales del usuario
class Medidas {
  Medidas({
    this.alturaCm,
    this.pesoKg,
    this.porcentajeGrasaCorporal,
    this.medidasEspecificasCm,
  });

  final double? alturaCm;
  final double? pesoKg;
  final double? porcentajeGrasaCorporal;
  final MedidasEspecificas? medidasEspecificasCm;

  factory Medidas.fromJson(Map<String, dynamic> json) {
    return Medidas(
      alturaCm: json['altura_cm'] != null
          ? (json['altura_cm'] as num).toDouble()
          : null,
      pesoKg: json['peso_kg'] != null
          ? (json['peso_kg'] as num).toDouble()
          : null,
      porcentajeGrasaCorporal: json['porcentaje_grasa_corporal'] != null
          ? (json['porcentaje_grasa_corporal'] as num).toDouble()
          : null,
      medidasEspecificasCm: json['medidas_especificas_cm'] != null
          ? MedidasEspecificas.fromJson(
              json['medidas_especificas_cm'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'altura_cm': alturaCm,
      'peso_kg': pesoKg,
      'porcentaje_grasa_corporal': porcentajeGrasaCorporal,
      'medidas_especificas_cm': medidasEspecificasCm?.toJson(),
    };
  }
}

/// Medidas específicas del cuerpo
class MedidasEspecificas {
  MedidasEspecificas({
    this.cuello,
    this.hombro,
    this.brazoIzquierdo,
    this.brazoDerecho,
    this.antebrazoIzquierdo,
    this.antebrazoDerecho,
    this.pecho,
    this.espalda,
    this.cintura,
    this.cuadricepIzquierdo,
    this.cuadricepDerecho,
    this.pantorrillaIzquierda,
    this.pantorrillaDerecha,
  });

  final double? cuello;
  final double? hombro;
  final double? brazoIzquierdo;
  final double? brazoDerecho;
  final double? antebrazoIzquierdo;
  final double? antebrazoDerecho;
  final double? pecho;
  final double? espalda;
  final double? cintura;
  final double? cuadricepIzquierdo;
  final double? cuadricepDerecho;
  final double? pantorrillaIzquierda;
  final double? pantorrillaDerecha;

  factory MedidasEspecificas.fromJson(Map<String, dynamic> json) {
    return MedidasEspecificas(
      cuello: json['cuello'] != null
          ? (json['cuello'] as num).toDouble()
          : null,
      hombro: json['hombro'] != null
          ? (json['hombro'] as num).toDouble()
          : null,
      brazoIzquierdo: json['brazo_izquierdo'] != null
          ? (json['brazo_izquierdo'] as num).toDouble()
          : null,
      brazoDerecho: json['brazo_derecho'] != null
          ? (json['brazo_derecho'] as num).toDouble()
          : null,
      antebrazoIzquierdo: json['antebrazo_izquierdo'] != null
          ? (json['antebrazo_izquierdo'] as num).toDouble()
          : null,
      antebrazoDerecho: json['antebrazo_derecho'] != null
          ? (json['antebrazo_derecho'] as num).toDouble()
          : null,
      pecho: json['pecho'] != null ? (json['pecho'] as num).toDouble() : null,
      espalda: json['espalda'] != null
          ? (json['espalda'] as num).toDouble()
          : null,
      cintura: json['cintura'] != null
          ? (json['cintura'] as num).toDouble()
          : null,
      cuadricepIzquierdo: json['cuadricep_izquierdo'] != null
          ? (json['cuadricep_izquierdo'] as num).toDouble()
          : null,
      cuadricepDerecho: json['cuadricep_derecho'] != null
          ? (json['cuadricep_derecho'] as num).toDouble()
          : null,
      pantorrillaIzquierda: json['pantorrilla_izquierda'] != null
          ? (json['pantorrilla_izquierda'] as num).toDouble()
          : null,
      pantorrillaDerecha: json['pantorrilla_derecha'] != null
          ? (json['pantorrilla_derecha'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cuello': cuello,
      'hombro': hombro,
      'brazo_izquierdo': brazoIzquierdo,
      'brazo_derecho': brazoDerecho,
      'antebrazo_izquierdo': antebrazoIzquierdo,
      'antebrazo_derecho': antebrazoDerecho,
      'pecho': pecho,
      'espalda': espalda,
      'cintura': cintura,
      'cuadricep_izquierdo': cuadricepIzquierdo,
      'cuadricep_derecho': cuadricepDerecho,
      'pantorrilla_izquierda': pantorrillaIzquierda,
      'pantorrilla_derecha': pantorrillaDerecha,
    };
  }
}
