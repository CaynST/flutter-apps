import 'package:caynst_app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el tema claro y el oscuro usan Material 3', () {
    expect(buildTheme(Brightness.light).useMaterial3, isTrue);
    expect(buildTheme(Brightness.dark).brightness, Brightness.dark);
  });
}
