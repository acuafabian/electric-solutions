// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/proyecto_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ElectricSolutionsApp());
}

class ElectricSolutionsApp extends StatelessWidget {
  const ElectricSolutionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProyectoProvider(),
      child: MaterialApp(
        title: 'Electric Solutions',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}
