// lib/services/calculo_electrico.dart
//
// Servicio de cálculo eléctrico según NTC 2050 (Código Eléctrico Colombiano)
// y RETIE (Reglamento Técnico de Instalaciones Eléctricas).
//
// Referencias normativas aplicadas:
//   Art. 210-11(c)  – Circuitos ramales obligatorios en vivienda
//   Art. 210-52(d)  – Tomacorriente GFCI en baños (circuito dedicado 20 A)
//   Art. 210-19     – Capacidad de conductores al 80% de carga continua
//   Art. 220-3(b)   – Carga de aluminación: 33 VA/m²
//   Art. 220-14     – Tomacorrientes uso general: 180 VA por salida
//   Art. 220-11     – Factor de demanda para acometida residencial (Tabla)
//   Art. 310-16     – Ampacidad de conductores (Cu, 75°C en conduit)
//   RETIE Art. 17   – DPS obligatorio en acometida
//   RETIE Art. 10.1 – Diseño simplificado para vivienda unifamiliar

import '../models/models.dart';

class CalculoElectrico {
  static const double _voltaje = 120.0; // V nominal en Colombia (fase-neutro)

  // ─── Tablas NTC 2050 ───────────────────────────────────────────────────────

  /// Tabla 220-3(b): Carga mínima de alumbrado por m² para unidades de vivienda
  static const double _vaPerM2 = 33.0;

  /// Art. 220-14: VA por salida de tomacorriente de uso general
  static const double _vaPerOutlet = 180.0;

  /// Art. 210-19 / 210-20: Circuito de 15 A al 80% → 1440 VA máximo
  static const double _maxVaCircuito15A = 1440.0;

  /// Art. 210-19 / 210-20: Circuito de 20 A al 80% → 1920 VA máximo
  static const double _maxVaCircuito20A = 1920.0;

  /// VA estimado por circuito dedicado de cocina / lavandería (promedio)
  static const double _vaCocinaLavanderia = 1500.0;

  /// Tabla 310-16: Ampacidades de conductores de cobre THW a 75°C en conduit
  /// Formato: {breakerA: 'calibre AWG'}
  static const Map<int, String> _tablaCalibre = {
    15: '14 AWG',
    20: '12 AWG',
    30: '10 AWG',
    40: '8 AWG',
    55: '6 AWG',
    70: '4 AWG',
    95: '2 AWG',
    110: '1 AWG',
    130: '1/0 AWG',
  };

  /// Tabla 220-11: Factor de demanda para alumbrado en viviendas
  /// Primeros 3000 VA → 100%; el resto → 35%
  static double _factorDemanda(double totalVA) {
    if (totalVA <= 3000) return totalVA;
    return 3000 + (totalVA - 3000) * 0.35;
  }

  /// Selecciona el breaker estándar inmediatamente superior a [amperios]
  static int _breakerEstandar(double amperios) {
    const sizes = [15, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 125, 150, 175, 200];
    for (final s in sizes) {
      if (s >= amperios) return s;
    }
    return 200;
  }

  /// Selecciona el calibre AWG según la corriente del breaker
  static String _calibrePara(int breakerA) {
    for (final entry in _tablaCalibre.entries) {
      if (entry.key >= breakerA) return entry.value;
    }
    return '2/0 AWG o mayor (verificar con ingeniero)';
  }

  // ─── Cálculo por piso ─────────────────────────────────────────────────────

  static ResultadoPiso calcularPiso(DatosPiso datos) {
    final alertas = <String>[];
    final dedicadosDesc = <String>[];

    // 1. Carga de iluminación (Art. 220-3(b)): 33 VA/m²
    final iluminacionVA = datos.areaMt2 * _vaPerM2;

    // 2. Carga de tomacorrientes generales (Art. 220-14): 180 VA/salida
    final tomacorrientesVA = datos.tomacorrientes * _vaPerOutlet;

    // 3. Número de circuitos ramales generales
    //    Alumbrado: circuitos de 15 A al 80% (1440 VA max)
    final circuitosIlum = (iluminacionVA / _maxVaCircuito15A).ceil();
    //    Tomacorrientes: circuitos de 20 A al 80% (1920 VA max)
    final circuitosTomas = datos.tomacorrientes > 0
        ? (tomacorrientesVA / _maxVaCircuito20A).ceil()
        : 0;

    // 4. Circuitos dedicados obligatorios (Art. 210-11(c))
    int circuitosDedicados = 0;

    if (datos.tieneCocina) {
      // Art. 210-11(c)(1): mínimo 2 circuitos de 20 A para la cocina
      circuitosDedicados += 2;
      dedicadosDesc.add('2 × 20 A cocina (Art. 210-11(c)(1))');
    }
    if (datos.tieneLavanderia) {
      // Art. 210-11(c)(2): 1 circuito de 20 A para lavandería
      circuitosDedicados += 1;
      dedicadosDesc.add('1 × 20 A lavandería (Art. 210-11(c)(2))');
    }
    if (datos.tieneBano) {
      // Art. 210-52(d): circuito 20 A con protección GFCI para baño
      circuitosDedicados += 1;
      dedicadosDesc.add('1 × 20 A baño – GFCI obligatorio (Art. 210-52(d))');
    }

    // 5. Circuito especial (ducha eléctrica, A/A, etc.)
    int circuitosEsp = 0;
    String calibreEsp = 'N/A';
    if (datos.cargaEspecialW > 0) {
      circuitosEsp = 1;
      final corrEsp = datos.cargaEspecialW / _voltaje;
      final breakerEsp = _breakerEstandar(corrEsp * 1.25);
      calibreEsp = _calibrePara(breakerEsp);

      if (datos.cargaEspecialW >= 3600) {
        // Ducha eléctrica: Art. RETIE 20.15 – circuito ≥ 30 A
        alertas.add(
          'Piso ${datos.numero}: carga especial ≥ 3600 W. '
          'Si es ducha eléctrica, el circuito debe ser ≥ 30 A '
          '(RETIE Art. 20.15). Calibre sugerido: $calibreEsp.',
        );
      }
      if (datos.cargaEspecialW > 7200) {
        alertas.add(
          'Piso ${datos.numero}: carga especial > 7200 W. '
          'Considera circuito trifásico o revisión con ingeniero.',
        );
      }
    }

    // 6. Verificación distribución de tomacorrientes (Art. 210-52(a))
    //    Ningún punto de la pared debe estar a más de 1.8 m de un toma
    //    Regla práctica: mínimo 1 toma cada 12 m² de área habitable
    final tomasMinimos = (datos.areaMt2 / 12).ceil();
    if (datos.tomacorrientes < tomasMinimos) {
      alertas.add(
        'Piso ${datos.numero}: se recomiendan al menos $tomasMinimos tomacorrientes '
        'para un área de ${datos.areaMt2.toStringAsFixed(0)} m² '
        '(Art. 210-52(a): ningún punto a más de 1.8 m de un toma).',
      );
    }

    // 7. Calibre para circuitos generales
    const calibreGeneral = '14 AWG (ilum.) / 12 AWG (tomas 20 A)';

    return ResultadoPiso(
      numero: datos.numero,
      iluminacionVA: iluminacionVA,
      tomacorrientesVA: tomacorrientesVA,
      circuitosIluminacion: circuitosIlum,
      circuitosTomacorriente: circuitosTomas,
      circuitosDedicados: circuitosDedicados,
      circuitosEspeciales: circuitosEsp,
      breaker15A: 15,
      breaker20A: 20,
      calibreGeneral: calibreGeneral,
      calibreEspecial: calibreEsp,
      alertas: alertas,
      circuitosDedicadosDesc: dedicadosDesc,
    );
  }

  // ─── Cálculo global del proyecto ──────────────────────────────────────────

  static ResultadoProyecto calcularProyecto(List<DatosPiso> pisos) {
    final resultadosPisos = pisos.map(calcularPiso).toList();
    final alertasGlobales = <String>[];

    // Suma de cargas instaladas (sin factor de demanda)
    double totalIlumTomas = 0;
    double totalEspecial = 0;
    int totalCircuitos = 0;

    for (final r in resultadosPisos) {
      totalIlumTomas += r.iluminacionVA + r.tomacorrientesVA;
      // Carga de circuitos dedicados al 100% (son cargas específicas)
      totalIlumTomas += r.circuitosDedicados * _vaCocinaLavanderia;
      // Cargas especiales al 100% (no se aplica factor de demanda)
      totalEspecial += pisos[r.numero - 1].cargaEspecialW;
      totalCircuitos += r.totalCircuitos;
    }

    final cargaInstaladaVA = totalIlumTomas + totalEspecial;

    // Factor de demanda: Tabla 220-11 NTC 2050
    // Solo aplica sobre iluminación y tomas generales; especiales al 100%
    final demandaBase = _factorDemanda(totalIlumTomas);
    final demandaVA = demandaBase + totalEspecial;

    // Corriente de la acometida
    final corrienteA = demandaVA / _voltaje;

    // Breaker principal (corriente × 1.25 para protección)
    final breakerPrincipalA = _breakerEstandar(corrienteA * 1.25);

    // Calibre de la acometida
    final calibreAcometida = _calibrePara(breakerPrincipalA);

    // Alertas globales
    if (breakerPrincipalA < 30) {
      alertasGlobales.add(
        'Breaker principal calculado en $breakerPrincipalA A. '
        'Verifica la capacidad mínima exigida por tu operador de red local.',
      );
    }

    // RETIE Art. 17 + NTC 4552: DPS obligatorio en toda acometida residencial
    alertasGlobales.add(
      'RETIE Art. 17 / NTC 4552: Instala un DPS (Dispositivo de Protección '
      'contra Sobretensiones) en el tablero principal.',
    );

    // Verificar que el tablero tenga espacio para futuros circuitos
    if (totalCircuitos > 20) {
      alertasGlobales.add(
        'El proyecto supera 20 circuitos ramales. Usa un tablero de ≥ 24 polos '
        'y deja espacio para ampliaciones futuras (RETIE 17.9).',
      );
    }

    // Alertas individuales por piso
    for (final r in resultadosPisos) {
      alertasGlobales.addAll(r.alertas);
    }

    return ResultadoProyecto(
      cargaInstaladaVA: cargaInstaladaVA,
      demandaVA: demandaVA,
      corrienteA: corrienteA,
      breakerPrincipalA: breakerPrincipalA,
      calibreAcometida: calibreAcometida,
      totalCircuitos: totalCircuitos,
      porPiso: resultadosPisos,
      alertasGlobales: alertasGlobales,
    );
  }

  // ─── Presupuesto estimado ─────────────────────────────────────────────────

  /// Genera presupuesto estimado en COP según nivel (bajo / medio / alto).
  /// Los valores unitarios son referencias de mercado colombiano (2025).
  static Presupuesto calcularPresupuesto({
    required ResultadoProyecto resultado,
    required List<DatosPiso> pisos,
    required String nivel, // 'bajo' | 'medio' | 'alto'
  }) {
    final factor = nivel == 'bajo' ? 0.80 : nivel == 'alto' ? 1.45 : 1.0;

    // Área total
    final areaTotalM2 = pisos.fold(0.0, (s, p) => s + p.areaMt2);

    // Cable + tubería: metros estimados = área × 3.5 (promedio instalación)
    final metrosCable = areaTotalM2 * 3.5;
    // Precio por metro de cable + conduit (promedio THW + tubería PVC)
    const precioMetroCable = 5200.0; // COP/m
    final cable = metrosCable * precioMetroCable * factor;

    // Tablero + breakers
    // Tablero vacío + breaker principal + circuitos ramales
    const precioTablero = 220000.0;
    const precioBreaker15A = 28000.0;
    const precioBreaker20A = 32000.0;
    // Estimado: 60% circuitos de 20 A, 40% de 15 A
    final tablero = (precioTablero +
            resultado.totalCircuitos * 0.4 * precioBreaker15A +
            resultado.totalCircuitos * 0.6 * precioBreaker20A) *
        factor;

    // Luminarias y accesorios (tomas, interruptores, tapas)
    // Promedio: 1 luminaria por cada 8 m² + costo tomas
    final luminarias = (areaTotalM2 / 8 * 35000 +
            pisos.fold(0.0, (s, p) => s + p.tomacorrientes) * 18000) *
        factor;

    // Mano de obra: por circuito + por piso
    const jornalCircuito = 48000.0;
    const jornalPiso = 85000.0;
    final manoObra =
        (resultado.totalCircuitos * jornalCircuito + pisos.length * jornalPiso) *
            factor;

    return Presupuesto(
      nivel: nivel,
      cable: cable,
      tablero: tablero,
      luminarias: luminarias,
      manoObra: manoObra,
    );
  }
}
