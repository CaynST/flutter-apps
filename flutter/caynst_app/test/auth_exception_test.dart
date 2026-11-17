import 'package:caynst_app/core/auth_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('traduce los códigos conocidos', () {
    expect(authErrorMessage('weak-password'), contains('6 caracteres'));
    expect(authErrorMessage('email-already-in-use'), contains('Ya existe'));
    expect(authErrorMessage('invalid-credential'), contains('incorrectos'));
    expect(
      authErrorMessage('popup-closed-by-user'),
      contains('ventana de Google'),
    );
  });

  test('mapea el popup bloqueado por el navegador', () {
    expect(authErrorMessage('popup-blocked'), contains('bloqueó'));
    expect(authErrorMessage('cancelled-popup-request'), contains('Google'));
  });

  test('usa un mensaje genérico para códigos desconocidos', () {
    expect(authErrorMessage('codigo-raro'), contains('Inténtalo de nuevo'));
  });

  test('AuthException expone su mensaje en toString', () {
    expect(const AuthException('falló').toString(), 'falló');
  });
}
