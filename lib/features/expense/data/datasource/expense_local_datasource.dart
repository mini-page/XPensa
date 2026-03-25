import 'package:hive/hive.dart';

import '../models/expense_model.dart';

class ExpenseLocalDatasource {
  static const String boxName = 'expenses';

  Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(boxName);

  Future<List<ExpenseModel>> getAllExpenses() async {
    final expenses = _box.values.toList(growable: false)
      ..sort((left, right) => right.date.compareTo(left.date));
    return expenses;
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    return _box.get(id);
  }

  Future<void> saveExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }
}
