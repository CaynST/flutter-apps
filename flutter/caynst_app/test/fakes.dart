import 'dart:async';
import 'dart:typed_data';

import 'package:caynst_app/core/auth_exception.dart';
import 'package:caynst_app/models/app_user.dart';
import 'package:caynst_app/models/task.dart';
import 'package:caynst_app/screens/auth/login_screen.dart';
import 'package:caynst_app/services/analytics_service.dart';
import 'package:caynst_app/services/auth_service.dart';
import 'package:caynst_app/services/firestore_service.dart';
import 'package:caynst_app/services/local_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FakeAuthService implements AuthService {
  final StreamController<AppUser?> controller =
      StreamController<AppUser?>.broadcast();

  String? lastEmail;
  String? lastPassword;
  bool googleThrows = false;
  bool signInThrows = false;
  bool signInThrowsGeneric = false;
  bool signedOut = false;

  @override
  Stream<AppUser?> get authStateChanges => controller.stream;

  @override
  AppUser? get currentUser => null;

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    if (signInThrows) {
      throw const AuthException('Correo o contraseña incorrectos.');
    }
    if (signInThrowsGeneric) {
      throw Exception('boom');
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    if (googleThrows) {
      throw const AuthException('Se cerró la ventana de Google.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> ensureUserProfile(
    User user, {
    bool createIfMissing = false,
  }) async {}

  void emit(AppUser? user) => controller.add(user);

  Future<void> dispose() => controller.close();
}

class FakeFirestoreService implements FirestoreService {
  FakeFirestoreService(this.tasks);

  final List<Task> tasks;
  bool? lastFilter;
  int lastLimit = 0;
  bool completedAll = false;
  String? deletedId;
  String? toggledId;
  bool? toggledValue;

  @override
  Stream<List<Task>> streamTasks({bool? completedFilter, int limit = 20}) {
    lastFilter = completedFilter;
    lastLimit = limit;
    final List<Task> filtered = tasks
        .where((Task t) =>
            completedFilter == null || t.isCompleted == completedFilter)
        .take(limit)
        .toList(growable: false);
    return Stream<List<Task>>.value(filtered);
  }

  @override
  Future<String> addTask({
    required String title,
    String description = '',
    List<String> tags = const <String>[],
  }) async {
    return 'nuevo-id';
  }

  @override
  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    List<String>? tags,
  }) async {}

  @override
  Future<void> toggleTask(String taskId, bool isCompleted) async {
    toggledId = taskId;
    toggledValue = isCompleted;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    deletedId = taskId;
  }

  @override
  Future<void> completeAllTasks() async {
    completedAll = true;
  }
}

class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Uint8List> avatars = <String, Uint8List>{};

  @override
  Future<void> saveAvatar(
    String uid,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    avatars[uid] = bytes;
  }

  @override
  Future<Uint8List?> getAvatar(String uid) async => avatars[uid];

  @override
  Future<void> deleteAvatar(String uid) async {
    avatars.remove(uid);
  }

  @override
  Future<List<String>> listAvatarUids() async => avatars.keys.toList();
}

class FakeAnalyticsService implements AnalyticsService {
  final List<String> events = <String>[];

  @override
  Future<void> logScreenView(String screenName) async {
    events.add('screen:$screenName');
  }

  @override
  Future<void> logLogin(String method) async {
    events.add('login:$method');
  }

  @override
  Future<void> logTaskCreated() async => events.add('task_created');

  @override
  Future<void> logTaskCompleted() async => events.add('task_completed');

  @override
  Future<void> logTaskDeleted() async => events.add('task_deleted');

  @override
  Future<void> setUserPlan(String plan) async => events.add('plan:$plan');
}


class LoginHarness extends StatelessWidget {
  const LoginHarness({
    super.key,
    required this.auth,
    this.googleSignInAvailable = true,
  });

  final FakeAuthService auth;
  final bool googleSignInAvailable;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      authService: auth,
      googleSignInAvailable: googleSignInAvailable,
    );
  }
}
