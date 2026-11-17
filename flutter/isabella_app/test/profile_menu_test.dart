import 'dart:typed_data';

import 'package:isabella_app/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('un avatar con bytes inválidos cae a las iniciales',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            ProfileMenu(
              displayName: 'Ana',
              email: 'ana@test.com',
              avatar: Uint8List.fromList(<int>[1, 2, 3, 4]),
              onPickAvatar: () {},
              onRemoveAvatar: () {},
              onCompleteAll: () {},
              onSignOut: () {},
            ),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
