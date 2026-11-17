import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/task.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/profile_menu.dart';
import '../../widgets/task_card.dart';
import '../../widgets/task_form_sheet.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    required this.uid,
    required this.displayName,
    required this.email,
    required this.authService,
    required this.firestoreService,
    required this.storageService,
    this.analytics,
  });

  final String uid;
  final String displayName;
  final String email;
  final AuthService authService;
  final FirestoreService firestoreService;
  final LocalStorageService storageService;
  final AnalyticsService? analytics;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  static const int _pageSize = 20;

  int _limit = _pageSize;
  bool? _filter;
  Uint8List? _avatar;
  bool _busy = false;
  late Stream<List<Task>> _stream;

  @override
  void initState() {
    super.initState();
    widget.analytics?.logScreenView('task_list');
    _listen();
    _loadAvatar();
  }

  void _listen() {
    _stream = widget.firestoreService.streamTasks(
      completedFilter: _filter,
      limit: _limit,
    );
  }

  Future<void> _loadAvatar() async {
    final Uint8List? avatar =
        await widget.storageService.getAvatar(widget.uid);
    if (mounted) setState(() => _avatar = avatar);
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    await widget.storageService.saveAvatar(
      widget.uid,
      bytes,
      contentType: file.mimeType ?? 'image/jpeg',
    );
    await _loadAvatar();
  }

  Future<void> _removeAvatar() async {
    await widget.storageService.deleteAvatar(widget.uid);
    if (mounted) setState(() => _avatar = null);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo completar la acción: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTask() async {
    final TaskDraft? draft = await TaskFormSheet.show(context);
    if (draft == null) return;
    await _run(
      () => widget.firestoreService.addTask(
        title: draft.title,
        description: draft.description,
        tags: draft.tags,
      ),
    );
    await widget.analytics?.logTaskCreated();
  }

  Future<void> _editTask(Task task) async {
    final TaskDraft? draft =
        await TaskFormSheet.show(context, initial: task);
    if (draft == null) return;
    await _run(
      () => widget.firestoreService.updateTask(
        task.id,
        title: draft.title,
        description: draft.description,
        tags: draft.tags,
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => widget.firestoreService.deleteTask(task.id));
    await widget.analytics?.logTaskDeleted();
  }

  Future<void> _toggleTask(Task task, bool value) async {
    await _run(() => widget.firestoreService.toggleTask(task.id, value));
    if (value) await widget.analytics?.logTaskCompleted();
  }

  void _setFilter(bool? value) {
    setState(() {
      _filter = value;
      _limit = _pageSize;
      _listen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: <Widget>[
          ProfileMenu(
            displayName: widget.displayName,
            email: widget.email,
            avatar: _avatar,
            onPickAvatar: _pickAvatar,
            onRemoveAvatar: _removeAvatar,
            onCompleteAll: () => _run(widget.firestoreService.completeAllTasks),
            onSignOut: () => _run(widget.authService.signOut),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filter == null,
                      onSelected: (_) => _setFilter(null),
                    ),
                    ChoiceChip(
                      label: const Text('Pendientes'),
                      selected: _filter == false,
                      onSelected: (_) => _setFilter(false),
                    ),
                    ChoiceChip(
                      label: const Text('Completadas'),
                      selected: _filter == true,
                      onSelected: (_) => _setFilter(true),
                    ),
                  ],
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<List<Task>>(
      stream: _stream,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'No pudimos cargar tus tareas',
            message: '${snapshot.error}',
            actionLabel: 'Reintentar',
            onAction: () => setState(_listen),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<Task> tasks = snapshot.data!;
        if (tasks.isEmpty) {
          return EmptyState(
            icon: Icons.task_alt,
            title: 'No hay tareas todavía',
            message: _filter == null
                ? 'Crea tu primera tarea con el botón de abajo.'
                : 'No hay tareas en este filtro.',
          );
        }
        final bool hasMore = tasks.length >= _limit;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          itemCount: tasks.length + (hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            if (index == tasks.length) {
              return Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _limit += _pageSize;
                    _listen();
                  }),
                  child: const Text('Cargar más'),
                ),
              );
            }
            final Task task = tasks[index];
            return TaskCard(
              task: task,
              onToggle: (bool value) => _toggleTask(task, value),
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
            );
          },
        );
      },
    );
  }
}
