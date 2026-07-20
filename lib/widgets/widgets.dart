// lib/widgets/widgets.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Tarjeta métrica ──────────────────────────────────────────────────────────

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.sublabel,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.primary,
            ),
          ),
          if (sublabel != null)
            Text(sublabel!, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

// ─── Banner de alerta ─────────────────────────────────────────────────────────

class AlertaBanner extends StatelessWidget {
  final String mensaje;
  final TipoAlertaWidget tipo;
  final String? articulo;

  const AlertaBanner({
    super.key,
    required this.mensaje,
    this.tipo = TipoAlertaWidget.advertencia,
    this.articulo,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icono) = switch (tipo) {
      TipoAlertaWidget.error => (
          const Color(0xFFFCEBEB),
          AppTheme.danger,
          Icons.cancel_outlined,
        ),
      TipoAlertaWidget.advertencia => (
          const Color(0xFFFAEEDA),
          AppTheme.warning,
          Icons.warning_amber_rounded,
        ),
      TipoAlertaWidget.info => (
          const Color(0xFFE1F5EE),
          AppTheme.success,
          Icons.info_outline,
        ),
      TipoAlertaWidget.ok => (
          const Color(0xFFE1F5EE),
          AppTheme.success,
          Icons.check_circle_outline,
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: fg, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (articulo != null)
                  Text(
                    articulo!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                Text(mensaje, style: TextStyle(fontSize: 13, color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TipoAlertaWidget { error, advertencia, info, ok }

// ─── Fila de dato ─────────────────────────────────────────────────────────────

class DatoFila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool destacado;

  const DatoFila({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 13,
              color: destacado ? AppTheme.primary : AppTheme.textMuted,
              fontWeight: destacado ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sección con título ───────────────────────────────────────────────────────

class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final Widget child;

  const SeccionTitulo({super.key, required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary)),
        const SizedBox(height: 10),
        child,
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─── Chip de circuito dedicado ────────────────────────────────────────────────

class ChipCircuito extends StatelessWidget {
  final String texto;
  const ChipCircuito({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: Color(0xFF0C447C)),
      ),
    );
  }
}

// ─── Descargo de responsabilidad RETIE ───────────────────────────────────────

class DescargoBanner extends StatelessWidget {
  const DescargoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: const Text(
        'Este cálculo es orientativo (diseño simplificado, RETIE Art. 10.1). '
        'Para proyectos que requieran certificación, el diseño debe ser '
        'firmado por un ingeniero electricista matriculado.',
        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
      ),
    );
  }
}
