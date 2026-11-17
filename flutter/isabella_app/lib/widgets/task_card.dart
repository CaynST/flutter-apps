import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/task.dart';
import 'task_check.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('dd/MM/yyyy').format(task.createdAt);
    final TextStyle titleStyle = karla(
      size: 16.5,
      weight: 600,
      height: 1.35,
      color: task.isCompleted ? pencil : ink,
    ).copyWith(
      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
      decorationColor: pencil,
    );

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: TaskCheck(
                key: Key('task-check-${task.id}'),
                value: task.isCompleted,
                onChanged: onToggle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(task.title, style: titleStyle),
                  ),
                  if (task.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: karla(size: 14, color: pencil),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        date,
                        style: karla(
                          size: 11.5,
                          weight: 600,
                          color: pencil,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (task.tags.isNotEmpty) ...<Widget>[
                        Text(
                          '  ·  ',
                          style: karla(size: 11.5, color: pencil),
                        ),
                        Flexible(
                          child: Text(
                            task.tags.join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: karla(
                              size: 11.5,
                              weight: 600,
                              color: moss,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Acciones',
              icon: const Icon(Icons.more_vert, size: 20, color: pencil),
              onSelected: (String value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined, size: 20),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, size: 20),
                    title: Text('Eliminar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
