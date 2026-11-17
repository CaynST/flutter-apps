import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saul_camara/main.dart';

void main() {
  testWidgets('muestra el botón del selector de imágenes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Saúl Cámara'), findsOneWidget);
    expect(find.text('Select Image from Gallery and Camera'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Sorry nothing selected!!'), findsOneWidget);
  });

  testWidgets('el botón abre las opciones de galería y cámara',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Photo Library'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
  });
}
