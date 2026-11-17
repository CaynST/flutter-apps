import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_storage_service.dart';
import 'widgets/auth_gate.dart';

class CaynstApp extends StatefulWidget {
  const CaynstApp({super.key});

  @override
  State<CaynstApp> createState() => _CaynstAppState();
}

class _CaynstAppState extends State<CaynstApp> {
  late final AuthService _authService = AuthService();
  late final FirestoreService _firestoreService = FirestoreService();
  late final LocalStorageService _storageService = LocalStorageService();
  late final AnalyticsService _analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caynst',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: AuthGate(
        authService: _authService,
        firestoreService: _firestoreService,
        storageService: _storageService,
        analytics: _analyticsService,
      ),
    );
  }
}
