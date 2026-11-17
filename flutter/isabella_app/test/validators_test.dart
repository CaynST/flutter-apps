import 'package:isabella_app/core/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emailValidator rechaza vacíos y formatos inválidos', () {
    expect(emailValidator(''), isNotNull);
    expect(emailValidator('sin-arroba'), isNotNull);
    expect(emailValidator('a@b'), isNotNull);
    expect(emailValidator('a@b.com'), isNull);
    expect(emailValidator('  a@b.com  '), isNull);
  });

  test('passwordValidator exige seis caracteres', () {
    expect(passwordValidator('12345'), isNotNull);
    expect(passwordValidator('123456'), isNull);
    expect(passwordValidator(null), isNotNull);
  });

  test('requiredValidator permite personalizar el mensaje', () {
    expect(requiredValidator('  ', message: 'Falta'), 'Falta');
    expect(requiredValidator('ok'), isNull);
  });
}
