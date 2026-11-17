import 'package:caynst_app/models/app_user.dart';
import 'package:caynst_app/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Widget wrap(AuthGate gate) => MaterialApp(home: gate);

void main() {
  testWidgets('sin sesión muestra el login', (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService();
    await tester.pumpWidget(wrap(AuthGate(
      authService: auth,
      firestoreService: FakeFirestoreService(const []),
      storageService: FakeLocalStorageService(),
      analytics: FakeAnalyticsService(),
    )));

    auth.emit(null);
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsWidgets);
    expect(find.byKey(const Key('login-google')), findsOneWidget);
  });

  testWidgets('con sesión muestra la lista de tareas',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService();
    await tester.pumpWidget(wrap(AuthGate(
      authService: auth,
      firestoreService: FakeFirestoreService(const []),
      storageService: FakeLocalStorageService(),
      analytics: FakeAnalyticsService(),
    )));

    auth.emit(const AppUser(uid: 'u1', displayName: 'Ana', email: 'a@b.com'));
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.text('No hay tareas todavía'), findsOneWidget);
  });

  testWidgets('el login envía correo y contraseña al servicio',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService();
    await tester.pumpWidget(MaterialApp(home: LoginHarness(auth: auth)));

    await tester.enterText(find.byKey(const Key('login-email')), 'ana@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), '123456');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(auth.lastEmail, 'ana@test.com');
    expect(auth.lastPassword, '123456');
  });

  testWidgets('el popup cerrado de Google muestra un mensaje claro',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService()..googleThrows = true;
    await tester.pumpWidget(MaterialApp(home: LoginHarness(auth: auth)));

    await tester.tap(find.byKey(const Key('login-google')));
    await tester.pumpAndSettle();

    expect(find.text('Se cerró la ventana de Google.'), findsOneWidget);
  });

  testWidgets('las credenciales inválidas muestran el error del servicio',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService()..signInThrows = true;
    await tester.pumpWidget(MaterialApp(home: LoginHarness(auth: auth)));

    await tester.enterText(find.byKey(const Key('login-email')), 'ana@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), '123456');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('en móvil el botón de Google explica que es solo web',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService();
    await tester.pumpWidget(MaterialApp(
      home: LoginHarness(auth: auth, googleSignInAvailable: false),
    ));

    await tester.tap(find.byKey(const Key('login-google')));
    await tester.pumpAndSettle();

    expect(
      find.text('El acceso con Google está disponible en la versión web.'),
      findsOneWidget,
    );
  });

  testWidgets('un error no-Auth muestra un mensaje en español',
      (WidgetTester tester) async {
    final FakeAuthService auth = FakeAuthService()..signInThrowsGeneric = true;
    await tester.pumpWidget(MaterialApp(home: LoginHarness(auth: auth)));

    await tester.enterText(find.byKey(const Key('login-email')), 'ana@test.com');
    await tester.enterText(find.byKey(const Key('login-password')), '123456');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo completar la operación. Inténtalo de nuevo.'),
      findsOneWidget,
    );
  });
}
