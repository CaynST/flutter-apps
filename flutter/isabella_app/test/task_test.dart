import 'package:isabella_app/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromMap convierte Timestamp y aplica valores por defecto', () {
    final DateTime date = DateTime.utc(2026, 1, 2, 3, 4, 5);
    final Task task = Task.fromMap('abc', <String, dynamic>{
      'title': 'Comprar pan',
      'isCompleted': true,
      'createdAt': Timestamp.fromDate(date),
      'completedAt': Timestamp.fromDate(date.add(const Duration(hours: 1))),
      'tags': <dynamic>['casa', 42],
    });

    expect(task.id, 'abc');
    expect(task.title, 'Comprar pan');
    expect(task.isCompleted, isTrue);
    expect(task.createdAt.isAtSameMomentAs(date), isTrue);
    expect(
      task.completedAt!.isAtSameMomentAs(date.add(const Duration(hours: 1))),
      isTrue,
    );
    expect(task.tags, <String>['casa']);
  });

  test('fromMap tolera documentos incompletos y corruptos', () {
    final Task task = Task.fromMap('x', <String, dynamic>{
      'createdAt': 'no-es-fecha',
    });

    expect(task.title, 'Sin título');
    expect(task.description, '');
    expect(task.isCompleted, isFalse);
    expect(task.completedAt, isNull);
    expect(task.tags, isEmpty);
    expect(task.createdAt.millisecondsSinceEpoch, 0);
  });

  test('toFirestore devuelve solo los campos del modelo', () {
    final Task task = Task(
      id: '1',
      title: 'T',
      description: 'D',
      isCompleted: false,
      createdAt: DateTime.utc(2026, 5, 1),
      tags: const <String>['a'],
    );

    final Map<String, dynamic> map = task.toFirestore();
    expect(map['title'], 'T');
    expect(map['description'], 'D');
    expect(map['isCompleted'], isFalse);
    expect(map['tags'], <String>['a']);
    expect(map['createdAt'], isA<Timestamp>());
    expect(map.containsKey('completedAt'), isFalse);
  });
}
