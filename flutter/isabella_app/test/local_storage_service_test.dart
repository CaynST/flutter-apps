import 'dart:convert';
import 'dart:typed_data';

import 'package:isabella_app/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('guarda, lee y borra el avatar de un usuario', () async {
    final LocalStorageService service = LocalStorageService();
    final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

    await service.saveAvatar('u1', bytes);
    expect(await service.getAvatar('u1'), bytes);
    expect(await service.listAvatarUids(), <String>['u1']);

    await service.deleteAvatar('u1');
    expect(await service.getAvatar('u1'), isNull);
    expect(await service.listAvatarUids(), isEmpty);
  });

  test('devuelve null ante un registro corrupto', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'avatar_u2': 'esto-no-es-json',
    });
    final LocalStorageService service = LocalStorageService();
    expect(await service.getAvatar('u2'), isNull);
  });

  test('ignora registros sin campo data', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'avatar_u3': jsonEncode(<String, dynamic>{'contentType': 'image/png'}),
    });
    final LocalStorageService service = LocalStorageService();
    expect(await service.getAvatar('u3'), isNull);
  });
}
