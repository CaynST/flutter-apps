// Prueba de humo: verifica que la pantalla del mapa se construye
// y muestra el título de la AppBar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maps_and_geolocation/main.dart';

void main() {
  testWidgets('La pantalla del mapa se renderiza', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('GeeksforGeeks Maps'), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
