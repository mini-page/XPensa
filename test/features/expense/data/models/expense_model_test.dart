import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:xpensa/features/expense/data/models/expense_model.dart';

void main() {
  group('ExpenseModel', () {
    final validId = const Uuid().v4();
    final validAmount = 100.0;
    final validCategory = 'Food';
    final validDate = DateTime.now();

    test('should create a valid ExpenseModel', () {
      final expense = ExpenseModel(
        id: validId,
        amount: validAmount,
        category: validCategory,
        date: validDate,
        note: 'Lunch',
      );

      expect(expense.id, validId);
      expect(expense.amount, validAmount);
      expect(expense.category, validCategory);
      expect(expense.date, validDate.toUtc());
      expect(expense.note, 'Lunch');
      expect(expense.type, TransactionType.expense);
    });

    test('should throw ArgumentError when category is empty', () {
      expect(
        () => ExpenseModel(
          id: validId,
          amount: validAmount,
          category: '',
          date: validDate,
    group('Getters: signedAmount and isIncome', () {
      test('should return positive amount and true for income', () {
        final model = ExpenseModel(
          id: 'test-id',
          amount: 100.0,
          category: 'Salary',
          date: DateTime(2023),
          note: '',
          type: TransactionType.income,
        );

        expect(model.signedAmount, 100.0);
        expect(model.isIncome, isTrue);
      });

      test('should return negative amount and false for expense', () {
        final model = ExpenseModel(
          id: 'test-id',
          amount: 50.0,
          category: 'Food',
          date: DateTime(2023),
          note: '',
          type: TransactionType.expense,
        );

        expect(model.signedAmount, -50.0);
        expect(model.isIncome, isFalse);
      });

      test(
          'should return negative amount when type is not specified (defaults to expense)',
          () {
        final model = ExpenseModel(
          id: 'test-id',
          amount: 50.0,
          category: 'Food',
          date: DateTime(2023),
          note: '',
        );

        expect(model.signedAmount, -50.0);
        expect(model.isIncome, isFalse);
      });
    });

    group('Constructor Validations', () {
      test('should throw ArgumentError when id is empty', () {
        expect(
          () => ExpenseModel(
            id: '',
            amount: 100.0,
            category: 'Salary',
            date: DateTime(2023),
            note: '',
          ),
          throwsA(isA<ArgumentError>().having(
              (e) => e.message, 'message', 'Expense id cannot be empty.')),
        );
      });

      test('should throw ArgumentError when amount is zero or negative', () {
        expect(
          () => ExpenseModel(
            id: 'test-id',
            amount: 0.0,
            category: 'Salary',
            date: DateTime(2023),
            note: '',
          ),
          throwsA(isA<ArgumentError>().having(
              (e) => e.message, 'message', 'Expense amount must be positive.')),
        );

        expect(
          () => ExpenseModel(
            id: 'test-id',
            amount: -10.0,
            category: 'Salary',
            date: DateTime(2023),
            note: '',
          ),
          throwsA(isA<ArgumentError>().having(
              (e) => e.message, 'message', 'Expense amount must be positive.')),
        );
      });

      test(
          'should throw ArgumentError when category is empty or only whitespace',
          () {
        expect(
          () => ExpenseModel(
            id: 'test-id',
            amount: 100.0,
            category: '',
            date: DateTime(2023),
            note: '',
          ),
          throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
              'Expense category cannot be empty.')),
        );

        expect(
          () => ExpenseModel(
            id: 'test-id',
            amount: 100.0,
            category: '   ',
            date: DateTime(2023),
            note: '',
          ),
          throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
              'Expense category cannot be empty.')),
        );
      });

      test('should convert date to UTC', () {
        final localDate = DateTime(2023, 1, 1, 12, 0, 0); // Local time
        final model = ExpenseModel(
          id: 'test-id',
          amount: 100.0,
          category: 'Salary',
          date: localDate,
          note: '',
        );

        expect(model.date.isUtc, isTrue);
        expect(model.date, localDate.toUtc());
      });
    });

    group('Factory: create', () {
      test('should generate UUID and trim fields', () {
        final date = DateTime(2023);
        final model = ExpenseModel.create(
          amount: 100.0,
          category: '  Salary  ',
          date: date,
          note: '  Bonus  ',
          accountId: '  acc-123  ',
        );

        expect(model.id, isNotEmpty);
        expect(model.category, 'Salary');
        expect(model.note, 'Bonus');
        expect(model.accountId, 'acc-123');
        expect(model.type, TransactionType.expense); // default
      });

      test('should set accountId to null if it is empty or whitespace', () {
        final date = DateTime(2023);

        final model1 = ExpenseModel.create(
          amount: 100.0,
          category: 'Salary',
          date: date,
          accountId: '',
        );
        expect(model1.accountId, isNull);

        final model2 = ExpenseModel.create(
          amount: 100.0,
          category: 'Salary',
          date: date,
          accountId: '   ',
        );
        expect(model2.accountId, isNull);
      });
    });

    group('copyWith', () {
      test('should return a new instance with updated values', () {
        final original = ExpenseModel(
          id: 'test-id',
          amount: 100.0,
          category: 'Salary',
          date: DateTime.utc(2023),
          note: 'Initial note',
          type: TransactionType.income,
          accountId: 'acc-1',
        );

        final newDate = DateTime.utc(2024);
        final updated = original.copyWith(
          amount: 200.0,
          category: 'Bonus',
          date: newDate,
          note: 'Updated note',
          type: TransactionType.expense,
        );

        expect(updated.id, original.id); // unchanged
        expect(updated.amount, 200.0);
        expect(updated.category, 'Bonus');
        expect(updated.date, newDate);
        expect(updated.note, 'Updated note');
        expect(updated.type, TransactionType.expense);
        expect(updated.accountId, 'acc-1'); // unchanged
      });

      test('should clear accountId when clearAccountId is true', () {
        final original = ExpenseModel(
          id: 'test-id',
          amount: 100.0,
          category: 'Salary',
          date: DateTime.utc(2023),
          note: '',
          accountId: 'acc-1',
        );

        final updated = original.copyWith(clearAccountId: true);

        expect(updated.accountId, isNull);
        // other fields should remain the same
        expect(updated.id, original.id);
      });

      test('should ignore new accountId when clearAccountId is true', () {
        final original = ExpenseModel(
          id: 'test-id',
          amount: 100.0,
          category: 'Salary',
          date: DateTime.utc(2023),
          note: '',
          accountId: 'acc-1',
        );

        final updated = original.copyWith(
          accountId: 'acc-2',
          clearAccountId: true,
        );

        expect(updated.accountId, isNull);
      });
  group('ExpenseModel Validations', () {
    final DateTime testDate = DateTime.now();

    test('should construct successfully with valid arguments', () {
      final expense = ExpenseModel(
        id: '123',
        amount: 10.0,
        category: 'Food',
        date: testDate,
        note: 'Lunch',
      );

      expect(expense.id, '123');
      expect(expense.amount, 10.0);
      expect(expense.category, 'Food');
      expect(expense.date, testDate.toUtc());
      expect(expense.note, 'Lunch');
      expect(expense.type, TransactionType.expense); // Default
    });

    test('should throw ArgumentError when id is empty', () {
      expect(
        () => ExpenseModel(
          id: '',
          amount: 10.0,
          category: 'Food',
          date: testDate,
          note: 'Lunch',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Expense category cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when category is whitespace', () {
      expect(
        () => ExpenseModel(
          id: validId,
          amount: validAmount,
          category: '   ',
          date: validDate,
            'Expense id cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when amount is zero', () {
      expect(
        () => ExpenseModel(
          id: '123',
          amount: 0.0,
          category: 'Food',
          date: testDate,
          note: 'Lunch',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Expense category cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when id is empty', () {
      expect(
        () => ExpenseModel(
          id: '',
          amount: validAmount,
          category: validCategory,
          date: validDate,
            'Expense amount must be positive.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when amount is negative', () {
      expect(
        () => ExpenseModel(
          id: '123',
          amount: -10.0,
          category: 'Food',
          date: testDate,
          note: 'Lunch',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Expense id cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when amount is zero', () {
      expect(
        () => ExpenseModel(
          id: validId,
          amount: 0.0,
          category: validCategory,
          date: validDate,
            'Expense amount must be positive.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when category is empty', () {
      expect(
        () => ExpenseModel(
          id: '123',
          amount: 10.0,
          category: '',
          date: testDate,
          note: 'Lunch',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Expense amount must be positive.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when amount is negative', () {
      expect(
        () => ExpenseModel(
          id: validId,
          amount: -50.0,
          category: validCategory,
          date: validDate,
            'Expense category cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when category contains only whitespace', () {
      expect(
        () => ExpenseModel(
          id: '123',
          amount: 10.0,
          category: '   ',
          date: testDate,
          note: 'Lunch',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Expense amount must be positive.',
          ),
        ),
      );
    });

    group('factory create()', () {
      test('should trim category and note on create', () {
        final expense = ExpenseModel.create(
          amount: validAmount,
          category: '  Food  ',
          date: validDate,
          note: '  Lunch  ',
        );

        expect(expense.category, 'Food');
        expect(expense.note, 'Lunch');
      });
            'Expense category cannot be empty.',
          ),
        ),
      );
    });
  });

  group('ExpenseModel Factory & Methods', () {
    final DateTime testDate = DateTime.now();

    test('factory create generates an id and correctly populates fields', () {
      final expense = ExpenseModel.create(
        amount: 50.0,
        category: '  Transport  ', // Should be trimmed
        date: testDate,
        note: '  Taxi  ', // Should be trimmed
        accountId: '  acc123  ', // Should be trimmed
      );

      expect(expense.id.isNotEmpty, true); // UUID generated
      expect(expense.amount, 50.0);
      expect(expense.category, 'Transport'); // Trimmed
      expect(expense.date, testDate.toUtc());
      expect(expense.note, 'Taxi'); // Trimmed
      expect(expense.accountId, 'acc123'); // Trimmed
    });

    test('factory create handles empty accountId correctly', () {
      final expense = ExpenseModel.create(
        amount: 50.0,
        category: 'Transport',
        date: testDate,
        accountId: '   ', // Blank string should map to null
      );

      expect(expense.accountId, isNull);
    });

    test('getters isIncome and signedAmount return correct values for expense', () {
      final expense = ExpenseModel.create(
        amount: 100.0,
        category: 'Food',
        date: testDate,
        type: TransactionType.expense,
      );

      expect(expense.isIncome, false);
      expect(expense.signedAmount, -100.0);
    });

    test('getters isIncome and signedAmount return correct values for income', () {
      final income = ExpenseModel.create(
        amount: 1000.0,
        category: 'Salary',
        date: testDate,
        type: TransactionType.income,
      );

      expect(income.isIncome, true);
      expect(income.signedAmount, 1000.0);
    });

    test('copyWith correctly updates properties', () {
      final original = ExpenseModel.create(
        amount: 10.0,
        category: 'Food',
        date: testDate,
        accountId: 'acc1',
      );

      final newDate = testDate.add(const Duration(days: 1));

      final updated = original.copyWith(
        amount: 20.0,
        category: 'Dining',
        date: newDate,
        note: 'Dinner',
        accountId: 'acc2',
        type: TransactionType.income,
      );

      expect(updated.id, original.id); // Stays the same
      expect(updated.amount, 20.0);
      expect(updated.category, 'Dining');
      expect(updated.date, newDate.toUtc());
      expect(updated.note, 'Dinner');
      expect(updated.accountId, 'acc2');
      expect(updated.type, TransactionType.income);
    });

    test('copyWith clearAccountId correctly nullifies accountId', () {
      final original = ExpenseModel.create(
        amount: 10.0,
        category: 'Food',
        date: testDate,
        accountId: 'acc1',
      );

      final cleared = original.copyWith(clearAccountId: true);

      expect(cleared.accountId, isNull);
    });
  });
}
