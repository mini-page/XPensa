import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}
