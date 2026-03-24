import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pensa/features/expense/data/models/expense_model.dart';
import 'package:pensa/features/expense/domain/repositories/expense_repository.dart';
import 'package:pensa/features/expense/presentation/provider/expense_providers.dart';
import 'package:pensa/main.dart';

void main() {
  testWidgets('shows the expense dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository()),
        ],
        child: const PensaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pensa'), findsOneWidget);
    expect(find.text('RECENT TRANSACTIONS'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
  });
}

class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseModel> _items = <ExpenseModel>[];

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    _items.removeWhere((item) => item.id == expense.id);
    _items.add(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    _items.removeWhere((expense) => expense.id == id);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    return _items;
  }
}
