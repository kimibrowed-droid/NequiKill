# Splash Animation - Nequi Kill

## ✅ Instalación Completada

Se ha configurado correctamente el splash screen con la animación Lottie original de Nequi.

## 📁 Archivos Creados

- `lib/screens/splashanimacion.dart` - Widget del splash con animación Lottie
- `assets/splash_animation.json` - Archivo de animación Lottie (123KB)
- Actualizado `pubspec.yaml` con dependencia `lottie: ^3.0.0`
- Actualizado `lib/main.dart` para mostrar el splash al iniciar

## 🔧 Flutter Configurado

Se desinstaló Flutter de snap (que tenía problemas) y ahora se usa la instalación manual en:
- **Ruta:** `/home/sxngre/flutter`
- **Versión:** Flutter 3.38.3 (stable)
- **Dart:** 3.10.1

## 🚀 Comandos Disponibles

```bash
# Instalar dependencias (ya ejecutado)
flutter pub get

# Analizar código
flutter analyze

# Ejecutar en dispositivo/emulador
flutter run

# Compilar APK
flutter build apk

# Compilar APK de release
flutter build apk --release
```

## 📱 Funcionamiento del Splash

1. Al iniciar la app, se muestra el splash con la animación Lottie
2. La animación se reproduce una sola vez (no loop)
3. Al terminar, navega automáticamente a la pantalla de PIN
4. Fondo blanco como en la app original

## 🎨 Personalización

Si quieres modificar el comportamiento del splash, edita `lib/screens/splashanimacion.dart`:

- **Cambiar duración:** La duración se toma automáticamente del archivo JSON
- **Cambiar destino:** Modifica el callback `onAnimationComplete` en `main.dart`
- **Cambiar fondo:** Modifica `backgroundColor` en el Scaffold

## ⚠️ Nota

El proyecto tiene algunos errores en otros archivos (home_screen.dart, pin_screen.dart) relacionados con versiones de dependencias, pero el splash funciona correctamente.
