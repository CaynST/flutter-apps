import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
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
    final TaskDraft? draft = await TaskFormSheet.show(context, initial: task);
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
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        title: Text('Eliminar tarea', style: fraunces(size: 20)),
        content: Text('¿Eliminar "${task.title}"?', style: karla()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Eliminar',
              style: karla(weight: 700, color: errorInk),
            ),
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

  String get _today {
    const List<String> weekdays = <String>[
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const List<String> months = <String>[
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final DateTime now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Isabella', style: fraunces(size: 27)),
            const SizedBox(height: 2),
            Text(
              _today,
              style: karla(size: 12, weight: 500, color: pencil),
            ),
          ],
        ),
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
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: <Widget>[
                    _filterTab('Todas', null),
                    _filterTab('Pendientes', false),
                    _filterTab('Hechas', true),
                  ],
                ),
              ),
              if (_busy)
                const LinearProgressIndicator(minHeight: 1.5)
              else
                const Divider(),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Nueva tarea',
        child: const Icon(Icons.add, size: 26),
      ),
    );
  }

  Widget _filterTab(String label, bool? value) {
    final bool selected = _filter == value;
    return InkWell(
      onTap: () => _setFilter(value),
      child: Padding(
        padding: const EdgeInsets.only(right: 22, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: karla(
                size: 13.5,
                weight: selected ? 700 : 500,
                color: selected ? ink : pencil,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 2,
              width: selected ? 18 : 0,
              color: coral,
            ),
          ],
        ),
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
            title: _filter == null
                ? 'La página está en blanco'
                : 'Nada en esta lista',
            message: _filter == null
                ? 'Apunta tu primera tarea con el botón de abajo.'
                : 'Cuando haya tareas aquí, aparecerán en esta página.',
          );
        }
        final bool hasMore = tasks.length >= _limit;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 96),
          itemCount: tasks.length + (hasMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index == tasks.length) {
              return Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _limit += _pageSize;
                    _listen();
                  }),
                  child: const Text('Ver más'),
                ),
              );
            }
            final Task task = tasks[index];
            return Column(
              children: <Widget>[
                TaskCard(
                  task: task,
                  onToggle: (bool value) => _toggleTask(task, value),
                  onEdit: () => _editTask(task),
                  onDelete: () => _deleteTask(task),
                ),
                if (index < tasks.length - 1) const Divider(),
              ],
            );
          },
        );
      },
    );
  }
}
