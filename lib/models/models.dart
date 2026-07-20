// lib/models/models.dart
// Modelos de datos de Electric Solutions
// Todos los cálculos siguen NTC 2050 / RETIE

/// Datos de entrada de un piso de la vivienda
class DatosPiso {
  final int numero;
  final double areaMt2;         // m² del piso (para carga de iluminación 33 VA/m²)
  final int tomacorrientes;     // Tomacorrientes de uso general (180 VA c/u, Art. 220-14)
  final bool tieneCocina;       // 2 circuitos dedicados 20 A (Art. 210-11(c)(1))
  final bool tieneLavanderia;   // 1 circuito dedicado 20 A  (Art. 210-11(c)(2))
  final bool tieneBano;         // 1 circuito dedicado 20 A GFCI (Art. 210-52(d))
  final double cargaEspecialW;  // Duchas, A/A, motores, etc. (100% de demanda)

  const DatosPiso({
    required this.numero,
    required this.areaMt2,
    required this.tomacorrientes,
    this.tieneCocina = false,
    this.tieneLavanderia = false,
    this.tieneBano = true,
    this.cargaEspecialW = 0,
  });

  DatosPiso copyWith({
    int? numero,
    double? areaMt2,
    int? tomacorrientes,
    bool? tieneCocina,
    bool? tieneLavanderia,
    bool? tieneBano,
    double? cargaEspecialW,
  }) {
    return DatosPiso(
      numero: numero ?? this.numero,
      areaMt2: areaMt2 ?? this.areaMt2,
      tomacorrientes: tomacorrientes ?? this.tomacorrientes,
      tieneCocina: tieneCocina ?? this.tieneCocina,
      tieneLavanderia: tieneLavanderia ?? this.tieneLavanderia,
      tieneBano: tieneBano ?? this.tieneBano,
      cargaEspecialW: cargaEspecialW ?? this.cargaEspecialW,
    );
  }

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'areaMt2': areaMt2,
        'tomacorrientes': tomacorrientes,
        'tieneCocina': tieneCocina,
        'tieneLavanderia': tieneLavanderia,
        'tieneBano': tieneBano,
        'cargaEspecialW': cargaEspecialW,
      };

  factory DatosPiso.fromJson(Map<String, dynamic> j) => DatosPiso(
        numero: j['numero'] as int,
        areaMt2: (j['areaMt2'] as num).toDouble(),
        tomacorrientes: j['tomacorrientes'] as int,
        tieneCocina: j['tieneCocina'] as bool,
        tieneLavanderia: j['tieneLavanderia'] as bool,
        tieneBano: j['tieneBano'] as bool,
        cargaEspecialW: (j['cargaEspecialW'] as num).toDouble(),
      );
}

/// Resultado de cálculo para un piso individual
class ResultadoPiso {
  final int numero;
  final double iluminacionVA;       // 33 VA/m² (Tabla 220-3(b))
  final double tomacorrientesVA;    // outlets × 180 VA
  final int circuitosIluminacion;   // al 80% de 15 A → máx 1440 VA por circuito
  final int circuitosTomacorriente; // al 80% de 20 A → máx 1920 VA por circuito
  final int circuitosDedicados;     // cocina, lavandería, baño
  final int circuitosEspeciales;    // 1 por carga especial
  final double breaker15A;
  final double breaker20A;
  final String calibreGeneral;      // 14 AWG o 12 AWG según circuito
  final String calibreEspecial;     // según carga especial
  final List<String> alertas;
  final List<String> circuitosDedicadosDesc;

  int get totalCircuitos =>
      circuitosIluminacion +
      circuitosTomacorriente +
      circuitosDedicados +
      circuitosEspeciales;

  double get cargaTotalVA =>
      iluminacionVA + tomacorrientesVA + (circuitosDedicados * 1500);

  const ResultadoPiso({
    required this.numero,
    required this.iluminacionVA,
    required this.tomacorrientesVA,
    required this.circuitosIluminacion,
    required this.circuitosTomacorriente,
    required this.circuitosDedicados,
    required this.circuitosEspeciales,
    required this.breaker15A,
    required this.breaker20A,
    required this.calibreGeneral,
    required this.calibreEspecial,
    required this.alertas,
    required this.circuitosDedicadosDesc,
  });
}

/// Resultado global del proyecto
class ResultadoProyecto {
  final double cargaInstaladaVA;  // Suma bruta de todos los pisos
  final double demandaVA;         // Aplicando factor de demanda Tabla 220-11
  final double corrienteA;        // demandaVA / 120 V
  final int breakerPrincipalA;    // corrienteA × 1.25, redondeado a estándar
  final String calibreAcometida;  // Según Tabla 310-16 (Cu, 75°C)
  final int totalCircuitos;
  final List<ResultadoPiso> porPiso;
  final List<String> alertasGlobales;

  const ResultadoProyecto({
    required this.cargaInstaladaVA,
    required this.demandaVA,
    required this.corrienteA,
    required this.breakerPrincipalA,
    required this.calibreAcometida,
    required this.totalCircuitos,
    required this.porPiso,
    required this.alertasGlobales,
  });
}

/// Presupuesto estimado según nivel
class Presupuesto {
  final String nivel; // bajo / medio / alto
  final double cable;
  final double tablero;
  final double luminarias;
  final double manoObra;
  double get total => cable + tablero + luminarias + manoObra;

  const Presupuesto({
    required this.nivel,
    required this.cable,
    required this.tablero,
    required this.luminarias,
    required this.manoObra,
  });
}

/// Proyecto completo
class Proyecto {
  final String id;
  final String nombre;
  final List<DatosPiso> pisos;
  final String nivelPresupuesto; // bajo / medio / alto
  final DateTime creadoEn;

  const Proyecto({
    required this.id,
    required this.nombre,
    required this.pisos,
    required this.nivelPresupuesto,
    required this.creadoEn,
  });

  Proyecto copyWith({
    String? nombre,
    List<DatosPiso>? pisos,
    String? nivelPresupuesto,
  }) {
    return Proyecto(
      id: id,
      nombre: nombre ?? this.nombre,
      pisos: pisos ?? this.pisos,
      nivelPresupuesto: nivelPresupuesto ?? this.nivelPresupuesto,
      creadoEn: creadoEn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'pisos': pisos.map((p) => p.toJson()).toList(),
        'nivelPresupuesto': nivelPresupuesto,
        'creadoEn': creadoEn.toIso8601String(),
      };

  factory Proyecto.fromJson(Map<String, dynamic> j) => Proyecto(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        pisos: (j['pisos'] as List)
            .map((p) => DatosPiso.fromJson(p as Map<String, dynamic>))
            .toList(),
        nivelPresupuesto: j['nivelPresupuesto'] as String,
        creadoEn: DateTime.parse(j['creadoEn'] as String),
      );
}

/// Alerta de cumplimiento RETIE / NTC 2050
class AlertaRetie {
  final TipoAlerta tipo;
  final String articulo; // Referencia normativa
  final String mensaje;

  const AlertaRetie({
    required this.tipo,
    required this.articulo,
    required this.mensaje,
  });
}

enum TipoAlerta { error, advertencia, info }
