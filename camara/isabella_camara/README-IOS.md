# Instalar "Isabella Cámara" en tu iPhone (gratis, con tu Mac)

La app ya está preparada: bundle id `com.example.isabellaCamara`, nombre visible
**Isabella Cámara** y permisos de cámara/galería en `ios/Runner/Info.plist`.

Con un Apple ID gratuito la app funciona en tu iPhone durante **7 días**; después
hay que volver a ejecutarla desde Xcode para renovarla.

## Requisitos en el Mac

- macOS con **Xcode** instalado (App Store) y abierto al menos una vez para aceptar la licencia.
- **CocoaPods**: `sudo gem install cocoapods` (o `brew install cocoapods`).
- **Flutter** en el `PATH` (`flutter --version` debe responder).
- El iPhone y un cable USB (o depuración inalámbrica ya emparejada).

## Pasos

1. Copia esta carpeta `isabella_camara` al Mac.

2. En Terminal, dentro de la carpeta:

   ```bash
   flutter pub get
   cd ios
   pod install
   ```

3. Abre el workspace (no el `.xcodeproj`):

   ```bash
   open Runner.xcworkspace
   ```

4. En Xcode:
   - Selecciona el proyecto **Runner** en el navegador izquierdo.
   - Pestaña **Signing & Capabilities**.
   - Marca **Automatically manage signing**.
   - En **Team** elige tu Apple ID. Si no aparece: *Xcode → Settings → Accounts → + → Apple ID*.

5. En el iPhone, activa el **Modo de desarrollador** (obligatorio desde iOS 16):
   *Ajustes → Privacidad y seguridad → Modo de desarrollador* → activar → reiniciar → confirmar.

6. Conecta el iPhone, elígelo como destino en la barra superior de Xcode y pulsa **Run** (▶).

7. La primera vez iOS bloquea la app. Ve a:
   *Ajustes → General → VPN y gestión de dispositivos → Desarrollador: tu Apple ID → Confiar*.

## Si algo falla

| Síntoma | Causa / solución |
|---|---|
| "Failed to register bundle identifier" | El id `com.example.isabellaCamara` ya está usado por otra cuenta. Cámbialo en *Signing & Capabilities → Bundle Identifier*, por ejemplo a `com.tunombre.isabellaCamara`. |
| "No signing certificate found" | Falta añadir el Apple ID en *Xcode → Settings → Accounts*. |
| La app se cierra al pulsar Camera o Photo Library | Faltan las claves de permiso en `Info.plist`; ya están puestas, pero si editas el archivo, no las borres. |
| "Untrusted Developer" | Paso 7 (confiar en el desarrollador). |
| `pod install` falla | `cd ios && pod repo update && pod install`. |
| La app deja de abrirse a los 7 días | Vuelve a pulsar Run desde Xcode. |

## Nota sobre distribución

Esto instala la app en **tu** iPhone. Para que otra persona la instale en el suyo
por WhatsApp hace falta firmarla con su Apple ID (Sideloadly en un PC/Mac) o usar
TestFlight/Ad Hoc con una cuenta Apple Developer de pago. Un `.ipa` enviado por
WhatsApp no se instala solo en iOS.
