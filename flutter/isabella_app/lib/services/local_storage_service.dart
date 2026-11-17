import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService({Future<SharedPreferences> Function()? preferencesLoader})
      : _loader = preferencesLoader ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _loader;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await _loader();

  static const String _prefix = 'avatar_';

  Future<void> saveAvatar(
    String uid,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final SharedPreferences prefs = await _preferences;
    await prefs.setString(
      '$_prefix$uid',
      jsonEncode(<String, dynamic>{
        'data': base64Encode(bytes),
        'contentType': contentType,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<Uint8List?> getAvatar(String uid) async {
    final SharedPreferences prefs = await _preferences;
    final String? raw = prefs.getString('$_prefix$uid');
    if (raw == null) return null;
    try {
      final Map<String, dynamic> map =
          jsonDecode(raw) as Map<String, dynamic>;
      final String? data = map['data'] as String?;
      if (data == null) return null;
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAvatar(String uid) async {
    final SharedPreferences prefs = await _preferences;
    await prefs.remove('$_prefix$uid');
  }

  Future<List<String>> listAvatarUids() async {
    final SharedPreferences prefs = await _preferences;
    return prefs
        .getKeys()
        .where((String key) => key.startsWith(_prefix))
        .map((String key) => key.substring(_prefix.length))
        .toList(growable: false);
  }
}
