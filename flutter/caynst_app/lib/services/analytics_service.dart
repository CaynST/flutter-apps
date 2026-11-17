import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_web.dart' if (dart.library.io) 'analytics_stub.dart' as web;

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logScreenView(String screenName) {
    if (kIsWeb) {
      web.logEvent('screen_view', <String, Object?>{
        'screen_name': screenName,
        'firebase_screen': screenName,
      });
      return Future<void>.value();
    }
    return _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logLogin(String method) {
    if (kIsWeb) {
      web.logEvent('login', <String, Object?>{'method': method});
      return Future<void>.value();
    }
    return _analytics.logEvent(
      name: 'login',
      parameters: <String, Object>{'method': method},
    );
  }

  Future<void> logTaskCreated() {
    if (kIsWeb) {
      web.logEvent('task_created');
      return Future<void>.value();
    }
    return _analytics.logEvent(name: 'task_created');
  }

  Future<void> logTaskCompleted() {
    if (kIsWeb) {
      web.logEvent('task_completed');
      return Future<void>.value();
    }
    return _analytics.logEvent(name: 'task_completed');
  }

  Future<void> logTaskDeleted() {
    if (kIsWeb) {
      web.logEvent('task_deleted');
      return Future<void>.value();
    }
    return _analytics.logEvent(name: 'task_deleted');
  }

  Future<void> setUserPlan(String plan) {
    if (kIsWeb) {
      web.setUserProperty('plan', plan);
      return Future<void>.value();
    }
    return _analytics.setUserProperty(name: 'plan', value: plan);
  }
}
