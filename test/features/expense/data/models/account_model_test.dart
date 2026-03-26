import 'package:flutter_test/flutter_test.dart';
import 'package:xpensa/features/expense/data/models/account_model.dart';

void main() {
  group('AccountModel Validation', () {
    test('throws ArgumentError when name is empty string', () {
      expect(
        () => AccountModel(id: '123', name: '', iconKey: 'bank', balance: 0),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Account name cannot be empty.')),
      );
    });

    test('throws ArgumentError when name is whitespace only', () {
      expect(
        () => AccountModel(id: '123', name: '   ', iconKey: 'bank', balance: 0),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Account name cannot be empty.')),
      );
    });

    test('create throws ArgumentError when name is empty string', () {
      expect(
        () => AccountModel.create(name: '', iconKey: 'bank', balance: 0),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Account name cannot be empty.')),
      );
    });

    test('create throws ArgumentError when name is whitespace only', () {
      expect(
        () => AccountModel.create(name: '   ', iconKey: 'bank', balance: 0),
        throwsA(isA<ArgumentError>().having(
            (e) => e.message, 'message', 'Account name cannot be empty.')),
      );
    });

    test('creates AccountModel successfully with valid name', () {
      final account = AccountModel(
          id: '123', name: 'Checking', iconKey: 'bank', balance: 100);
      expect(account.id, '123');
      expect(account.name, 'Checking');
      expect(account.iconKey, 'bank');
      expect(account.balance, 100);
    });

    test('creates AccountModel successfully with valid name via create', () {
      final account = AccountModel.create(
          name: ' Savings ', iconKey: 'wallet', balance: 50);
      expect(account.id, isNotEmpty);
      expect(account.name, 'Savings'); // Should be trimmed
      expect(account.iconKey, 'wallet');
      expect(account.balance, 50);
    });
  });
}
