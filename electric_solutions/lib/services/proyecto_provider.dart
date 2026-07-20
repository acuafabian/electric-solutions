// lib/services/proyecto_provider.dart
// Estado global con Provider – gestiona proyectos y cálculos

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'calculo_electrico.dart';

class ProyectoProvider extends ChangeNotifier {
  List<Proyecto> _proyectos = [];
  Proyecto? _proyectoActual;
  ResultadoProyecto? _resultado;
  Presupuesto? _presupuesto;
  bool _cargando = false;

  List<Proyecto> get proyectos => _proyectos;
  Proyecto? get proyectoActual => _proyectoActual;
  ResultadoProyecto? get resultado => _resultado;
  Presupuesto? get presupuesto => _presupuesto;
  bool get cargando => _cargando;

  // ─── Persistencia ──────────────────────────────────────────────────────────

  Future<void> cargarProyectos() async {
    _cargando = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('proyectos') ?? [];
      _proyectos = data
          .map((s) => Proyecto.fromJson(jsonDecode(s) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _proyectos = [];
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> _guardarProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'proyectos',
      _proyectos.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  // ─── CRUD proyectos ────────────────────────────────────────────────────────

  void nuevoProyecto({required String nombre, required int numeroPisos, required String nivelPresupuesto}) {
    final pisos = List.generate(
      numeroPisos,
      (i) => DatosPiso(
        numero: i + 1,
        areaMt2: 60,
        tomacorrientes: 8,
        tieneCocina: i == 0,
        tieneLavanderia: i == 0,
        tieneBano: true,
      ),
    );

    _proyectoActual = Proyecto(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      pisos: pisos,
      nivelPresupuesto: nivelPresupuesto,
      creadoEn: DateTime.now(),
    );
    _resultado = null;
    _presupuesto = null;
    notifyListeners();
  }

  void abrirProyecto(Proyecto proyecto) {
    _proyectoActual = proyecto;
    calcular();
    notifyListeners();
  }

  Future<void> guardarProyectoActual() async {
    if (_proyectoActual == null) return;
    final idx = _proyectos.indexWhere((p) => p.id == _proyectoActual!.id);
    if (idx >= 0) {
      _proyectos[idx] = _proyectoActual!;
    } else {
      _proyectos.add(_proyectoActual!);
    }
    await _guardarProyectos();
    notifyListeners();
  }

  Future<void> eliminarProyecto(String id) async {
    _proyectos.removeWhere((p) => p.id == id);
    await _guardarProyectos();
    notifyListeners();
  }

  // ─── Edición de pisos ──────────────────────────────────────────────────────

  void actualizarPiso(DatosPiso piso) {
    if (_proyectoActual == null) return;
    final nuevos = _proyectoActual!.pisos.map((p) {
      return p.numero == piso.numero ? piso : p;
    }).toList();
    _proyectoActual = _proyectoActual!.copyWith(pisos: nuevos);
    notifyListeners();
  }

  void actualizarNombre(String nombre) {
    _proyectoActual = _proyectoActual?.copyWith(nombre: nombre);
    notifyListeners();
  }

  void actualizarPresupuestoNivel(String nivel) {
    _proyectoActual = _proyectoActual?.copyWith(nivelPresupuesto: nivel);
    if (_resultado != null) calcular();
    notifyListeners();
  }

  // ─── Cálculo ───────────────────────────────────────────────────────────────

  void calcular() {
    if (_proyectoActual == null) return;
    _resultado = CalculoElectrico.calcularProyecto(_proyectoActual!.pisos);
    _presupuesto = CalculoElectrico.calcularPresupuesto(
      resultado: _resultado!,
      pisos: _proyectoActual!.pisos,
      nivel: _proyectoActual!.nivelPresupuesto,
    );
    notifyListeners();
  }
}
