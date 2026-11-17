import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> tags;

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Task.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      title: (data['title'] as String?) ?? 'Sin título',
      description: (data['description'] as String?) ?? '',
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      createdAt: _toDate(data['createdAt']),
      completedAt:
          data['completedAt'] == null ? null : _toDate(data['completedAt']),
      tags: (data['tags'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
    );
  }

  static DateTime _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'tags': tags,
    };
  }
}
