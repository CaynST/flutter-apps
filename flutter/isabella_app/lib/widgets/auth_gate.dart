import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/task_list_screen.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.firestoreService,
    required this.storageService,
    this.analytics,
  });

  final AuthService authService;
  final FirestoreService firestoreService;
  final LocalStorageService storageService;
  final AnalyticsService? analytics;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: authService.authStateChanges,
      builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AppUser? user = snapshot.data;
        if (user == null) {
          return LoginScreen(
            authService: authService,
            analytics: analytics,
          );
        }

        return TaskListScreen(
          uid: user.uid,
          displayName: user.displayName,
          email: user.email,
          authService: authService,
          firestoreService: firestoreService,
          storageService: storageService,
          analytics: analytics,
        );
      },
    );
  }
}
