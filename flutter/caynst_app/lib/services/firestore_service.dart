import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final User? user = _auth.currentUser;
    if (user == null) throw StateError('No hay usuario autenticado');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksRef =>
      _db.collection('users').doc(_uid).collection('tasks');

  Stream<List<Task>> streamTasks({bool? completedFilter, int limit = 20}) {
    Query<Map<String, dynamic>> query =
        _tasksRef.orderBy('createdAt', descending: true).limit(limit);

    if (completedFilter != null) {
      query = _tasksRef
          .where('isCompleted', isEqualTo: completedFilter)
          .orderBy('createdAt', descending: true)
          .limit(limit);
    }

    return query.snapshots().map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(Task.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<String> addTask({
    required String title,
    String description = '',
    List<String> tags = const <String>[],
  }) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _tasksRef.add(<String, dynamic>{
      'title': title.trim(),
      'description': description.trim(),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
      'tags': tags,
    });
    return doc.id;
  }

  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    List<String>? tags,
  }) async {
    final Map<String, dynamic> updates = <String, dynamic>{};
    if (title != null) updates['title'] = title.trim();
    if (description != null) updates['description'] = description.trim();
    if (tags != null) updates['tags'] = tags;
    if (updates.isEmpty) return;
    await _tasksRef.doc(taskId).update(updates);
  }

  Future<void> toggleTask(String taskId, bool isCompleted) {
    return _tasksRef.doc(taskId).update(<String, dynamic>{
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> deleteTask(String taskId) => _tasksRef.doc(taskId).delete();

  Future<void> completeAllTasks() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _tasksRef.where('isCompleted', isEqualTo: false).get();
    if (snapshot.docs.isEmpty) return;

    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      batch.update(doc.reference, <String, dynamic>{
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
