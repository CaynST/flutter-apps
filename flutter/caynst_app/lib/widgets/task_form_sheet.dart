import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.description,
    required this.tags,
  });

  final String title;
  final String description;
  final List<String> tags;
}

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({super.key, this.initial});

  final Task? initial;

  static Future<TaskDraft?> show(BuildContext context, {Task? initial}) {
    return showModalBottomSheet<TaskDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: TaskFormSheet(initial: initial),
        );
      },
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.initial?.description ?? '');
  late final TextEditingController _tags =
      TextEditingController(text: widget.initial?.tags.join(', ') ?? '');

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final List<String> tags = _tags.text
        .split(',')
        .map((String tag) => tag.trim())
        .where((String tag) => tag.isNotEmpty)
        .take(10)
        .toList(growable: false);
    Navigator.of(context).pop(
      TaskDraft(
        title: _title.text.trim(),
        description: _description.text.trim(),
        tags: tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.initial != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  editing ? 'Editar tarea' : 'Nueva tarea',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('task-title'),
                  controller: _title,
                  autofocus: true,
                  maxLength: 200,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Escribe un título';
                    if (text.length > 200) return 'Máximo 200 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('task-description'),
                  controller: _description,
                  maxLength: 2000,
                  maxLines: 4,
                  minLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('task-tags'),
                  controller: _tags,
                  decoration: const InputDecoration(
                    labelText: 'Etiquetas',
                    helperText: 'Separadas por coma (máximo 10)',
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('task-save'),
                  onPressed: _submit,
                  child: Text(editing ? 'Guardar cambios' : 'Crear tarea'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
