import 'package:flutter_test/flutter_test.dart';
import 'package:xpensa/features/expense/data/models/budget_model.dart';

void main() {
  group('BudgetModel', () {
    test('should create BudgetModel when valid arguments are provided', () {
      final model = BudgetModel(category: 'Food', monthlyLimit: 500.0);
      expect(model.category, 'Food');
      expect(model.monthlyLimit, 500.0);
    });

    test('should throw ArgumentError when category is empty or whitespace', () {
      expect(
        () => BudgetModel(category: '   ', monthlyLimit: 100.0),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Budget category cannot be empty.',
          ),
        ),
      );

      expect(
        () => BudgetModel(category: '', monthlyLimit: 100.0),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Budget category cannot be empty.',
          ),
        ),
      );
    });

    test('should throw ArgumentError when monthlyLimit is negative', () {
      expect(
        () => BudgetModel(category: 'Food', monthlyLimit: -10.0),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Budget amount cannot be negative.',
          ),
        ),
      );
    });
  });
}
