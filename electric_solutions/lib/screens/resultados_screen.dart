// lib/screens/resultados_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/proyecto_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class ResultadosScreen extends StatelessWidget {
  const ResultadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProyectoProvider>();
    final resultado = provider.resultado;
    final presupuesto = provider.presupuesto;
    final proyecto = provider.proyectoActual;

    if (resultado == null || proyecto == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tieneErrores = resultado.alertasGlobales
        .any((a) => a.toLowerCase().contains('error') ||
            a.toLowerCase().contains('incumplimiento'));

    return Scaffold(
      appBar: AppBar(
        title: Text(proyecto.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar',
            onPressed: () {
              provider.guardarProyectoActual();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proyecto guardado')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Alertas ───────────────────────────────────────────────────
            if (tieneErrores)
              const AlertaBanner(
                tipo: TipoAlertaWidget.error,
                mensaje: 'Hay incumplimientos de la NTC 2050. Revisa las alertas.',
              )
            else
              const AlertaBanner(
                tipo: TipoAlertaWidget.ok,
                mensaje: 'Diseño dentro de los parámetros de la NTC 2050.',
              ),

            ...resultado.alertasGlobales.map((a) {
              final isDPS = a.contains('DPS') || a.contains('RETIE Art. 17');
              return AlertaBanner(
                tipo: isDPS ? TipoAlertaWidget.info : TipoAlertaWidget.advertencia,
                mensaje: a,
              );
            }),

            const SizedBox(height: 8),

            // ── Métricas globales ─────────────────────────────────────────
            SeccionTitulo(
              titulo: 'Resumen de la acometida',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Carga instalada',
                          value:
                              '${resultado.cargaInstaladaVA.toStringAsFixed(0)} VA',
                          sublabel: 'Suma total bruta',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Demanda (Tabla 220-11)',
                          value:
                              '${resultado.demandaVA.toStringAsFixed(0)} VA',
                          sublabel: 'Con factor de demanda',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Corriente acometida',
                          value:
                              '${resultado.corrienteA.toStringAsFixed(1)} A',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Breaker principal',
                          value: '${resultado.breakerPrincipalA} A',
                          valueColor: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: 'Calibre acometida',
                          value: resultado.calibreAcometida,
                          sublabel: 'Cu THW 75°C (Tabla 310-16)',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          label: 'Total circuitos',
                          value: '${resultado.totalCircuitos}',
                          sublabel: 'Ramales',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Detalle por piso ──────────────────────────────────────────
            SeccionTitulo(
              titulo: 'Circuitos por piso',
              child: Column(
                children: resultado.porPiso.map((r) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Piso ${r.numero}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.primary)),
                          const SizedBox(height: 10),
                          DatoFila(
                            etiqueta: 'Iluminación',
                            valor:
                                '${r.iluminacionVA.toStringAsFixed(0)} VA → ${r.circuitosIluminacion} circ. 15 A',
                          ),
                          DatoFila(
                            etiqueta: 'Tomacorrientes',
                            valor:
                                '${r.tomacorrientesVA.toStringAsFixed(0)} VA → ${r.circuitosTomacorriente} circ. 20 A',
                          ),
                          DatoFila(
                            etiqueta: 'Calibre general',
                            valor: r.calibreGeneral,
                          ),
                          if (r.circuitosDedicadosDesc.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Circuitos dedicados:',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted)),
                            const SizedBox(height: 4),
                            ...r.circuitosDedicadosDesc
                                .map((d) => ChipCircuito(texto: d)),
                          ],
                          if (r.circuitosEspeciales > 0) ...[
                            const SizedBox(height: 4),
                            DatoFila(
                              etiqueta: 'Carga especial',
                              valor:
                                  '${r.circuitosEspeciales} circ. – calibre ${r.calibreEspecial}',
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: DatoFila(
                              etiqueta: 'Total circuitos',
                              valor: '${r.totalCircuitos}',
                              destacado: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Presupuesto ───────────────────────────────────────────────
            if (presupuesto != null)
              SeccionTitulo(
                titulo: 'Presupuesto estimado (${presupuesto.nivel})',
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DatoFila(
                          etiqueta: 'Conductores y tubería',
                          valor: _cop(presupuesto.cable),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        DatoFila(
                          etiqueta: 'Tablero y breakers',
                          valor: _cop(presupuesto.tablero),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        DatoFila(
                          etiqueta: 'Luminarias y accesorios',
                          valor: _cop(presupuesto.luminarias),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        DatoFila(
                          etiqueta: 'Mano de obra',
                          valor: _cop(presupuesto.manoObra),
                        ),
                        const Divider(height: 2, thickness: 0.5),
                        DatoFila(
                          etiqueta: 'Total estimado',
                          valor: _cop(presupuesto.total),
                          destacado: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const DescargoBanner(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _cop(double value) {
    final n = value.round();
    return '\$${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
