// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/proyecto_provider.dart';
import '../theme/app_theme.dart';
import 'nuevo_proyecto_screen.dart';
import 'resultados_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProyectoProvider>().cargarProyectos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProyectoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: AppTheme.accent, size: 20),
            const SizedBox(width: 8),
            const Text('Electric Solutions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => _mostrarInfo(context),
          ),
        ],
      ),
      body: provider.cargando
          ? const Center(child: CircularProgressIndicator())
          : provider.proyectos.isEmpty
              ? _emptyState(context)
              : _lista(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proyecto'),
        onPressed: () => _irANuevoProyecto(context),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.electric_bolt_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Sin proyectos aún',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary)),
          const SizedBox(height: 8),
          const Text('Crea tu primer proyecto para empezar.',
              style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _lista(BuildContext context, ProyectoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.proyectos.length,
      itemBuilder: (_, i) {
        final p = provider.proyectos[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFAEEDA),
              child: const Icon(Icons.home_outlined, color: AppTheme.warning),
            ),
            title: Text(p.nombre,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 15)),
            subtitle: Text(
              '${p.pisos.length} piso${p.pisos.length > 1 ? 's' : ''} · '
              'Presupuesto ${p.nivelPresupuesto}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.grey.shade400,
                  onPressed: () => _confirmarEliminar(context, provider, p.id),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textMuted, size: 20),
              ],
            ),
            onTap: () {
              provider.abrirProyecto(p);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ResultadosScreen()),
              );
            },
          ),
        );
      },
    );
  }

  void _irANuevoProyecto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NuevoProyectoScreen()),
    );
  }

  void _confirmarEliminar(
      BuildContext context, ProyectoProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.eliminarProyecto(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _mostrarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Electric Solutions'),
        content: const Text(
          'Cálculos basados en NTC 2050 (Código Eléctrico Colombiano) '
          'y RETIE (Reglamento Técnico de Instalaciones Eléctricas).\n\n'
          'Este diseño es simplificado según RETIE Art. 10.1. '
          'Para instalaciones que requieran certificación, consulta '
          'con un ingeniero electricista matriculado.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido')),
        ],
      ),
    );
  }
}
