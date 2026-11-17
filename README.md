# flutter-apps

Proyectos Flutter de la materia **Diseño de Interfaces**.

| Proyecto | Ruta | Descripción |
| --- | --- | --- |
| Saul Cámara | `camara/saul_camara` | App de cámara (Flutter). |
| Isabella Cámara | `camara/isabella_camara` | App de cámara con soporte iOS (Flutter). |
| Caynst | `flutter/caynst_app` | App web/Android de gestión de tareas con Flutter y Firebase. |
| Isabella | `flutter/isabella_app` | App Android de tareas con estética de cuaderno de tinta (Flutter + Firebase). |
| Maps and Geolocation | `flutter-mapas/maps_and_geolocation` | Mapa de OpenStreetMap con `flutter_map` y geolocalización. |

## Ejecutar un proyecto

```bash
cd camara/saul_camara   # o cualquiera de las rutas de la tabla
flutter pub get
flutter run
```

Los artefactos de compilación (`build/`, `.dart_tool/`), las firmas (`*.jks`, `key.properties`) y los binarios (`*.apk`) no se versionan; ver `.gitignore`.
