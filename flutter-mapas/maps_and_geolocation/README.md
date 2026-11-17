# Maps and Geolocation (Flutter + OpenStreetMap)

Implementación de la actividad **"Integrating Maps and Geolocation Services Flutter"**
(documento `maps (1).pdf` de GeeksforGeeks).

La app muestra un mapa de OpenStreetMap con `flutter_map`, centrado inicialmente en
Nueva Delhi, y un botón flotante que obtiene la ubicación real del dispositivo con
`geolocator` y mueve el mapa + el marcador a esa posición.

## Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^7.0.0
  latlong2: ^0.9.1
  geolocator: ^12.0.0
```

Instalar con:

```bash
flutter pub get
```

## Estructura

```
maps_and_geolocation/
├── lib/
│   ├── main.dart        # Punto de entrada + MaterialApp
│   └── map_screen.dart  # StatefulWidget con el mapa y la geolocalización
├── test/
│   └── widget_test.dart # Prueba de humo de la pantalla del mapa
└── pubspec.yaml
```

## Permisos configurados

- **Android** (`android/app/src/main/AndroidManifest.xml`):
  `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`.
- **iOS** (`ios/Runner/Info.plist`): `NSLocationWhenInUseUsageDescription`.

> El artículo no los menciona, pero sin ellos el mapa no carga los tiles
> (INTERNET) y `geolocator` no puede leer la ubicación.

## Ejecutar

```bash
flutter run              # Android / iOS
flutter run -d chrome    # Web (funciona en localhost)
```

## Comportamiento

1. Al abrir, el mapa se centra en `LatLng(28.6139, 77.2090)` (Nueva Delhi) con zoom 13.
2. El `FloatingActionButton` (`Icons.my_location`) ejecuta `_getCurrentLocation()`, que:
   - comprueba si el servicio de ubicación está activo,
   - consulta/solicita el permiso (`denied` y `deniedForever` se manejan con `SnackBar`),
   - obtiene la posición con `Geolocator.getCurrentPosition()`,
   - actualiza el estado y hace `_mapController.move(...)` a la nueva ubicación.
3. El marcador rojo (`Icons.location_on`) se dibuja en la posición actual (`MarkerLayer`).

## APKs generados

| Archivo | Nombre en el dispositivo | applicationId |
|---|---|---|
| `dist/saul_map.apk` | **Saúl Map** | `com.example.maps_and_geolocation.saul` |
| `dist/isabella_map.apk` | **Isabella Map** | `com.example.maps_and_geolocation.isabella` |

Al tener `applicationId` distinto, ambas se pueden instalar al mismo tiempo.
Están firmadas con la clave de depuración (sirven para instalar/probar, no para
Google Play).

Para regenerarlas:

```bash
APP_DISPLAY_NAME="Saúl Map"    APP_ID_SUFFIX="saul"     flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk dist/saul_map.apk

APP_DISPLAY_NAME="Isabella Map" APP_ID_SUFFIX="isabella" flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk dist/isabella_map.apk
```

> Ojo: la variable debe llamarse `APP_DISPLAY_NAME` y no `APP_NAME`, porque el
> script `android/gradlew` define `APP_NAME="Gradle"` y sobrescribiría el valor.

## Notas sobre versiones

- El fragmento del "Step 4" del PDF usa `MapOptions(center:, zoom:)`, API de
  `flutter_map` 5. Aquí se usa el código completo del artículo (`initialCenter` /
  `initialZoom`), que es el correcto para `flutter_map` 6/7.
- En `flutter_map` 7 el `Marker` recibe `child:` (no `builder:`), por eso el
  marcador usa `child: Icon(...)`.
