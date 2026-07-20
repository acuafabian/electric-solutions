# Electric Solutions – App Android

App móvil para diseño, cálculo y presupuesto de instalaciones eléctricas residenciales según **NTC 2050 / RETIE** (Colombia).

---

## Tecnologías

| Capa | Stack |
|---|---|
| App móvil | Flutter (Dart) – Android |
| Estado | Provider |
| Persistencia local | shared_preferences |
| Backend (futuro) | FastAPI + Firebase / Supabase |

---

## Estructura del proyecto

```
lib/
├── main.dart                    ← Punto de entrada
├── models/
│   └── models.dart              ← DatosPiso, Proyecto, ResultadoProyecto, Presupuesto
├── services/
│   ├── calculo_electrico.dart   ← Motor de cálculo NTC 2050
│   └── proyecto_provider.dart   ← Estado global (ChangeNotifier)
├── screens/
│   ├── home_screen.dart         ← Lista de proyectos
│   ├── nuevo_proyecto_screen.dart ← Wizard de 2 pasos
│   └── resultados_screen.dart   ← Resultados, circuitos y presupuesto
├── widgets/
│   └── widgets.dart             ← MetricCard, AlertaBanner, DatoFila, etc.
└── theme/
    └── app_theme.dart           ← Paleta y tipografía
```

---

## Normativa aplicada

| Artículo | Aplicación |
|---|---|
| NTC 2050 Art. 220-3(b) | Carga de iluminación: 33 VA/m² |
| NTC 2050 Art. 220-14 | Tomacorrientes: 180 VA por salida |
| NTC 2050 Art. 210-11(c) | Circuitos dedicados obligatorios (cocina, lavandería) |
| NTC 2050 Art. 210-52(d) | Circuito 20 A GFCI para baño |
| NTC 2050 Art. 210-19 | Carga al 80% de capacidad (carga continua) |
| NTC 2050 Tabla 220-11 | Factor de demanda: primeros 3000 VA al 100%, resto al 35% |
| NTC 2050 Tabla 310-16 | Ampacidad Cu THW 75°C para selección de calibre AWG |
| RETIE Art. 10.1 | Diseño simplificado para vivienda unifamiliar |
| RETIE Art. 17 / NTC 4552 | DPS obligatorio en acometida residencial |
| RETIE Art. 20.15 | Duchas eléctricas: circuito ≥ 30 A |

---

## Instalación y ejecución

### Requisitos
- Flutter SDK ≥ 3.0.0
- Android Studio o VS Code con extensión Flutter
- Dispositivo Android o emulador (API 21+)

### Pasos

```bash
# 1. Clonar o descomprimir el proyecto
cd electric_solutions

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run

# 4. Compilar APK de release
flutter build apk --release
```

El APK quedará en `build/app/outputs/flutter-apk/app-release.apk`.

---

## Próximos pasos (escalabilidad)

- [ ] Backend FastAPI con endpoint `/calcular` para que las reglas RETIE se actualicen sin reinstalar la app
- [ ] Firebase Auth (login de técnicos)
- [ ] Firebase Firestore (historial de proyectos en la nube)
- [ ] Exportar PDF del reporte (módulo `pdf` ya incluido en pubspec)
- [ ] Escaneo de planos con OpenCV (Módulo C del documento maestro)
- [ ] Cálculo trifásico
- [ ] Modo cliente (vista simplificada para el dueño de la obra)

---

## Descargo de responsabilidad

Este cálculo es orientativo (diseño simplificado, RETIE Art. 10.1).  
Para proyectos que requieran certificación, el diseño debe ser firmado por un ingeniero electricista matriculado.
