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

## IPA de iOS (GitHub Actions)

El workflow `.github/workflows/ios-ipa.yml` compila las cinco apps en un runner macOS y publica un `.ipa` por app como artefacto descargable (Actions → run → *Artifacts*). Se lanza al modificar esos proyectos o a mano con `workflow_dispatch`.

| App | IPA | Estado en iOS |
| --- | --- | --- |
| `camara/isabella_camara` | `isabella_camara-ipa` | Funcional. |
| `camara/saul_camara` | `saul_camara-ipa` | Funcional. |
| `flutter/caynst_app` | `caynst_app-ipa` | Compila, pero **se cierra al abrir**: falta configurar Firebase para iOS (`flutterfire configure`). |
| `flutter/isabella_app` | `isabella_app-ipa` | Igual que Caynst: falta Firebase para iOS. |
| `flutter-mapas/maps_and_geolocation` | `maps_and_geolocation-ipa` | Funcional. |

El `.ipa` sale **sin firmar**, así que iOS no lo instala directamente: hay que re-firmarlo con Sideloadly o AltStore usando un Apple ID gratuito (la app caduca a los 7 días). Para un `.ipa` instalable por cualquiera o para TestFlight hace falta Apple Developer Program y firma con certificado + provisioning profile.

Los artefactos de compilación (`build/`, `.dart_tool/`), las firmas (`*.jks`, `key.properties`) y los binarios (`*.apk`) no se versionan; ver `.gitignore`.
