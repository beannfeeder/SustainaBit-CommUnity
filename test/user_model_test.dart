import 'package:flutter_test/flutter_test.dart';
import 'package:sustainabit_community/src/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User should be created from JSON', () {
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'impactScore': 1250,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.impactScore, 1250);
    });

    test('User should convert to JSON', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        impactScore: 1250,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['impactScore'], 1250);
    });

    test('User copyWith should create new instance with updated fields', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        impactScore: 1250,
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
      );

      final updatedUser = user.copyWith(name: 'Jane Doe', impactScore: 2000);

      expect(updatedUser.name, 'Jane Doe');
      expect(updatedUser.impactScore, 2000);
      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
    });
  });
}
