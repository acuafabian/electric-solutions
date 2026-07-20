// lib/screens/nuevo_proyecto_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/proyecto_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'resultados_screen.dart';

class NuevoProyectoScreen extends StatefulWidget {
  const NuevoProyectoScreen({super.key});

  @override
  State<NuevoProyectoScreen> createState() => _NuevoProyectoScreenState();
}

class _NuevoProyectoScreenState extends State<NuevoProyectoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  int _numeroPisos = 1;
  String _nivelPresupuesto = 'medio';
  int _paso = 0; // 0=datos vivienda, 1=puntos eléctricos

  // Controladores por piso
  late List<Map<String, dynamic>> _pisosState;

  @override
  void initState() {
    super.initState();
    _inicializarPisos();
  }

  void _inicializarPisos() {
    _pisosState = List.generate(
      _numeroPisos,
      (i) => {
        'areaCtrl': TextEditingController(text: '60'),
        'tomasCtrl': TextEditingController(text: '8'),
        'cocina': i == 0,
        'lavanderia': i == 0,
        'bano': true,
        'especialCtrl': TextEditingController(text: '0'),
      },
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    for (final p in _pisosState) {
      (p['areaCtrl'] as TextEditingController).dispose();
      (p['tomasCtrl'] as TextEditingController).dispose();
      (p['especialCtrl'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paso == 0 ? 'Nuevo proyecto' : 'Puntos eléctricos'),
        leading: BackButton(onPressed: () {
          if (_paso == 1) {
            setState(() => _paso = 0);
          } else {
            Navigator.pop(context);
          }
        }),
      ),
      body: _paso == 0 ? _paso0() : _paso1(),
    );
  }

  // ─── Paso 0: Datos de la vivienda ─────────────────────────────────────────

  Widget _paso0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paso 1 de 2',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            const Text('Datos de la vivienda',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
            const SizedBox(height: 24),

            // Nombre
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del proyecto'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),

            // Número de pisos
            const Text('Número de pisos',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_numeroPisos > 1) {
                      setState(() {
                        _numeroPisos--;
                        _pisosState.removeLast();
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppTheme.primary,
                ),
                Expanded(
                  child: Center(
                    child: Text('$_numeroPisos',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600)),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_numeroPisos < 6) {
                      setState(() {
                        _numeroPisos++;
                        _pisosState.add({
                          'areaCtrl': TextEditingController(text: '60'),
                          'tomasCtrl': TextEditingController(text: '8'),
                          'cocina': false,
                          'lavanderia': false,
                          'bano': true,
                          'especialCtrl': TextEditingController(text: '0'),
                        });
                      });
                    }
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nivel de presupuesto
            const Text('Nivel de presupuesto',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Row(
              children: ['bajo', 'medio', 'alto'].map((nivel) {
                final sel = nivel == _nivelPresupuesto;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _nivelPresupuesto = nivel),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                          right: nivel != 'alto' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                          width: sel ? 2 : 0.5,
                        ),
                      ),
                      child: Text(
                        nivel[0].toUpperCase() + nivel.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.normal,
                          color: sel ? Colors.white : AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _paso = 1);
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Paso 1: Puntos eléctricos por piso ───────────────────────────────────

  Widget _paso1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paso 2 de 2',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          const Text('Puntos eléctricos',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary)),
          const SizedBox(height: 6),
          const AlertaBanner(
            tipo: TipoAlertaWidget.info,
            mensaje:
                'Iluminación se calcula por m² (33 VA/m², Art. 220-3(b) NTC 2050). '
                'Los circuitos dedicados (cocina, baño, lavandería) son obligatorios '
                'según Art. 210-11(c).',
          ),
          const SizedBox(height: 16),
          ...List.generate(_numeroPisos, (i) => _cardPiso(i)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _calcularYContinuar,
            child: const Text('Calcular instalación'),
          ),
          const SizedBox(height: 8),
          const DescargoBanner(),
        ],
      ),
    );
  }

  Widget _cardPiso(int idx) {
    final p = _pisosState[idx];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Piso ${idx + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.primary)),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Área (m²)',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: p['areaCtrl'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(suffixText: 'm²'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tomacorrientes',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: p['tomasCtrl'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(suffixText: 'uds'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            const Text('Circuitos dedicados obligatorios',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            _checkCircuito(idx, 'cocina', 'Cocina (2×20 A)', 'Art. 210-11(c)(1)'),
            _checkCircuito(idx, 'lavanderia', 'Lavandería (1×20 A)', 'Art. 210-11(c)(2)'),
            _checkCircuito(idx, 'bano', 'Baño GFCI (1×20 A)', 'Art. 210-52(d)'),

            const SizedBox(height: 14),
            const Text('Carga especial (W)',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            const Text('Ducha, A/A, estufa…',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            TextFormField(
              controller: p['especialCtrl'] as TextEditingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                suffixText: 'W',
                hintText: '0',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkCircuito(int idx, String key, String label, String articulo) {
    final p = _pisosState[idx];
    return CheckboxListTile(
      value: p[key] as bool,
      onChanged: (v) => setState(() => p[key] = v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      subtitle: Text(articulo,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppTheme.primary,
    );
  }

  void _calcularYContinuar() {
    final provider = context.read<ProyectoProvider>();

    provider.nuevoProyecto(
      nombre: _nombreCtrl.text.trim(),
      numeroPisos: _numeroPisos,
      nivelPresupuesto: _nivelPresupuesto,
    );

    // Actualizar cada piso con los datos ingresados
    for (int i = 0; i < _numeroPisos; i++) {
      final p = _pisosState[i];
      provider.actualizarPiso(
        DatosPiso(
          numero: i + 1,
          areaMt2:
              double.tryParse((p['areaCtrl'] as TextEditingController).text) ??
                  60,
          tomacorrientes:
              int.tryParse((p['tomasCtrl'] as TextEditingController).text) ?? 8,
          tieneCocina: p['cocina'] as bool,
          tieneLavanderia: p['lavanderia'] as bool,
          tieneBano: p['bano'] as bool,
          cargaEspecialW: double.tryParse(
                  (p['especialCtrl'] as TextEditingController).text) ??
              0,
        ),
      );
    }

    provider.calcular();
    provider.guardarProyectoActual();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultadosScreen()),
    );
  }
}
