import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_storage_service.dart';
import 'widgets/auth_gate.dart';

class IsabellaApp extends StatefulWidget {
  const IsabellaApp({super.key});

  @override
  State<IsabellaApp> createState() => _IsabellaAppState();
}

class _IsabellaAppState extends State<IsabellaApp> {
  late final AuthService _authService = AuthService();
  late final FirestoreService _firestoreService = FirestoreService();
  late final LocalStorageService _storageService = LocalStorageService();
  late final AnalyticsService _analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isabella',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: AuthGate(
        authService: _authService,
        firestoreService: _firestoreService,
        storageService: _storageService,
        analytics: _analyticsService,
      ),
    );
  }
}
