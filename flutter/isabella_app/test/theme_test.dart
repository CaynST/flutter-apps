import 'package:isabella_app/core/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el tema usa Material 3 y la paleta de papel', () {
    expect(buildTheme().useMaterial3, isTrue);
    expect(buildTheme().scaffoldBackgroundColor, paper);
  });
}
