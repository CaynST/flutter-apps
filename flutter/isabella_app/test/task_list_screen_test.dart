import 'package:isabella_app/models/task.dart';
import 'package:isabella_app/screens/home/task_list_screen.dart';
import 'package:isabella_app/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Task buildTask({required String id, required String title, bool done = false}) {
  return Task(
    id: id,
    title: title,
    createdAt: DateTime.utc(2026, 1, 1),
    isCompleted: done,
  );
}

Widget wrap(TaskListScreen screen) => MaterialApp(home: screen);

void main() {
  testWidgets('muestra las tareas y el estado vacío',
      (WidgetTester tester) async {
    final FakeFirestoreService firestore =
        FakeFirestoreService(<Task>[buildTask(id: '1', title: 'Comprar pan')]);

    await tester.pumpWidget(wrap(TaskListScreen(
      uid: 'u1',
      displayName: 'Ana',
      email: 'ana@test.com',
      authService: FakeAuthService(),
      firestoreService: firestore,
      storageService: FakeLocalStorageService(),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Comprar pan'), findsOneWidget);
    expect(find.byType(TaskCard), findsOneWidget);
    expect(firestore.lastLimit, 20);
  });

  testWidgets('el filtro de pendientes reinicia la consulta',
      (WidgetTester tester) async {
    final FakeFirestoreService firestore = FakeFirestoreService(<Task>[
      buildTask(id: '1', title: 'Pendiente'),
      buildTask(id: '2', title: 'Hecha', done: true),
    ]);

    await tester.pumpWidget(wrap(TaskListScreen(
      uid: 'u1',
      displayName: 'Ana',
      email: 'ana@test.com',
      authService: FakeAuthService(),
      firestoreService: firestore,
      storageService: FakeLocalStorageService(),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();

    expect(firestore.lastFilter, isFalse);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Hecha'), findsNothing);
  });

  testWidgets('marcar una tarea llama a toggleTask',
      (WidgetTester tester) async {
    final FakeFirestoreService firestore =
        FakeFirestoreService(<Task>[buildTask(id: 't1', title: 'Tarea')]);

    await tester.pumpWidget(wrap(TaskListScreen(
      uid: 'u1',
      displayName: 'Ana',
      email: 'ana@test.com',
      authService: FakeAuthService(),
      firestoreService: firestore,
      storageService: FakeLocalStorageService(),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('task-check-t1')));
    await tester.pumpAndSettle();

    expect(firestore.toggledId, 't1');
    expect(firestore.toggledValue, isTrue);
  });

  testWidgets('muestra el estado vacío sin tareas', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(TaskListScreen(
      uid: 'u1',
      displayName: 'Ana',
      email: 'ana@test.com',
      authService: FakeAuthService(),
      firestoreService: FakeFirestoreService(<Task>[]),
      storageService: FakeLocalStorageService(),
    )));
    await tester.pumpAndSettle();

    expect(find.text('La página está en blanco'), findsOneWidget);
  });
}
