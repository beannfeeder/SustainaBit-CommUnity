import 'package:flutter_test/flutter_test.dart';
import 'package:sustainabit_community/src/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name+tag@example.co.uk'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
      });

      test('should return error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('Password Validation', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('SecureP@ssw0rd'), null);
      });

      test('should return error for short password', () {
        expect(Validators.validatePassword('short'), isNotNull);
        expect(Validators.validatePassword('1234567'), isNotNull);
      });

      test('should return error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });
    });

    group('Required Field Validation', () {
      test('should return null for non-empty value', () {
        expect(Validators.validateRequired('value'), null);
      });

      test('should return error for empty value', () {
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired(null), isNotNull);
      });

      test('should include field name in error message', () {
        final error = Validators.validateRequired('', fieldName: 'Username');
        expect(error, contains('Username'));
      });
    });

    group('Phone Validation', () {
      test('should return null for valid phone', () {
        expect(Validators.validatePhone('1234567890'), null);
        expect(Validators.validatePhone('+1 234 567 8900'), null);
      });

      test('should return error for invalid phone', () {
        expect(Validators.validatePhone('123'), isNotNull);
        expect(Validators.validatePhone('abc'), isNotNull);
      });
    });

    group('URL Validation', () {
      test('should return null for valid URL', () {
        expect(Validators.validateUrl('https://example.com'), null);
        expect(Validators.validateUrl('http://example.com'), null);
        expect(Validators.validateUrl('example.com'), null);
      });

      test('should return error for invalid URL', () {
        expect(Validators.validateUrl('not a url'), isNotNull);
      });
    });
  });
}
