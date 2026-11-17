# Caynst

App web de gestión de tareas con Flutter y Firebase (plan Spark).

## Primera puesta en marcha

1. En la consola de Firebase, habilitar Authentication → Correo/contraseña y Google.
2. Crear Firestore Database en edición Standard.
3. Desplegar reglas e índices:

```bash
firebase deploy --only firestore:rules,firestore:indexes --project caynst-flutter-app
```

## Desarrollo

```bash
firebase emulators:start --only auth,firestore --project caynst-flutter-app
flutter run -d chrome --dart-define=USE_EMULATOR=true
```

## Demo con el proyecto real

```bash
flutter run -d chrome
```

## Funciones

- Login con correo/contraseña y Google.
- Tareas en tiempo real en `users/{uid}/tasks`.
- Filtros Todas/Pendientes/Completadas y paginación incremental.
- Avatar guardado localmente en el navegador.
- Analytics de pantallas y eventos de tareas.

## Android (APK)

```bash
flutter build apk --release
```

El APK queda en `Saúl.apk` (raíz del proyecto) y en `build/app/outputs/flutter-apk/` (firmado con la clave de debug; sirve para instalar, no para publicar).

Requisitos: Android 7.0+ (`minSdk 24`). El login con Google usa `signInWithPopup`, que solo existe en web: en Android se muestra un aviso y se usa correo/contraseña.

## Analytics

- **Web:** GA4 (`G-T3XE7CH4RR`). `web/index.html` configura `gtag` y expone una referencia sin envolver; `lib/services/analytics_web.dart` envía los eventos directamente. Es un puente necesario porque el SDK web de Firebase no propaga el `measurementId` en este entorno.
- **Android:** SDK nativo de Firebase Analytics mediante `google-services.json`.
- **Brave** bloquea Google Analytics con Shields activado. Para ver eventos en GA4 DebugView, desactiva Shields para `localhost` o usa Chrome.

## Fuera de alcance

Cloud Storage, Cloud Functions y Crashlytics requieren Blaze o no existen para web.
