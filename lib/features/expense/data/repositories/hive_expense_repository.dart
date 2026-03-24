import '../../domain/repositories/expense_repository.dart';
import '../datasource/expense_local_datasource.dart';
import '../models/expense_model.dart';

class HiveExpenseRepository implements ExpenseRepository {
  HiveExpenseRepository(this._localDatasource);

  final ExpenseLocalDatasource _localDatasource;

  @override
  Future<void> saveExpense(ExpenseModel expense) {
    return _localDatasource.saveExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    return _localDatasource.deleteExpense(id);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() {
    return _localDatasource.getAllExpenses();
  }
}
