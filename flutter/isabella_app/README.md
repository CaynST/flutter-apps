# Isabella

Aplicación Android de tareas con estética de cuaderno de tinta: papel cálido, tinta azul-grafito, bermellón para la acción y sellos circulares.

Comparte el mismo proyecto de Firebase que Caynst: los usuarios y las tareas son los mismos; solo cambia la interfaz.

## APK

`Isabella.apk` (raíz del proyecto) — Android 7.0+, etiqueta **Isabella**.

```bash
adb install -r Isabella.apk
```

## Desarrollo

```bash
flutter run
```

## Compilar

```bash
flutter build apk --release
```

## Funciones

- Login con correo/contraseña (Google disponible solo en web).
- Tareas en tiempo real en `users/{uid}/tasks`.
- Filtros Todas / Pendientes / Hechas y paginación incremental.
- Avatar local por usuario.
- Analytics nativo con `google-services.json`.

## Notas

- El APK está firmado con la clave de debug: instalable, no publicable.
- Package: `com.cayn.isabella_app`.
- La carpeta `web/` existe solo para previsualizar el diseño en escritorio; no forma parte de la entrega.
