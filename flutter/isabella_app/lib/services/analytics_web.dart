import 'dart:js_interop';

@JS('__isabellaGtag')
external void _gtag(JSString command, JSString action, JSObject parameters);

void logEvent(String name, [Map<String, Object?>? parameters]) {
  _gtag(
    'event'.toJS,
    name.toJS,
    (parameters ?? const <String, Object?>{}).jsify() as JSObject,
  );
}

void setUserProperty(String name, String value) {
  _gtag(
    'set'.toJS,
    'user_properties'.toJS,
    <String, Object?>{name: value}.jsify() as JSObject,
  );
}
