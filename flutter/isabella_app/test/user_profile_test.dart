import 'package:isabella_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('newUserProfileData incluye los campos que exige la regla', () {
    final Map<String, dynamic> data = newUserProfileData(
      email: 'ana@test.com',
      displayName: 'Ana',
    );

    expect(data['email'], 'ana@test.com');
    expect(data['displayName'], 'Ana');
    expect(data['createdAt'], isA<FieldValue>());
    expect(data['lastLogin'], isA<FieldValue>());
  });

  test('lastLoginUpdateData solo envía lastLogin', () {
    final Map<String, dynamic> data = lastLoginUpdateData();

    expect(data.keys, <String>['lastLogin']);
    expect(data['lastLogin'], isA<FieldValue>());
  });
}
