// ignore_for_file: avoid_print
import 'dart:math';

// Standalone mockup to represent the domain without needing the entire Hive framework
class MockExpenseModel {
  MockExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.accountId,
  });

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? accountId;
}

enum RecordsFilter { all, today, week, month, future }

void main() {
  print('--- Benchmarking _filterExpenses ---');

  // Generate 100,000 dummy expenses spread across the last 60 days
  final random = Random(42);
  final now = DateTime.now();
  final expenses = List.generate(100000, (index) {
    final daysToSubtract = random.nextInt(60);
    final hoursToSubtract = random.nextInt(24);
    final date = now.subtract(Duration(days: daysToSubtract, hours: hoursToSubtract)).toUtc();
    return MockExpenseModel(
      id: 'id_$index',
      amount: random.nextDouble() * 100,
      category: 'Food',
      date: date,
      accountId: index % 2 == 0 ? 'acc1' : 'acc2',
    );
  });

  print('Generated ${expenses.length} expenses.');

  // Constants to match the real screen state
  const allAccountsKey = '__all_accounts__';
  final String selectedAccountFilter = 'acc1';
  final RecordsFilter selectedFilter = RecordsFilter.week;

  // WARMUP
  for (var i = 0; i < 10; i++) {
    _filterExpensesOriginal(expenses, selectedFilter, selectedAccountFilter, allAccountsKey);
    _filterExpensesOptimized(expenses, selectedFilter, selectedAccountFilter, allAccountsKey);
  }

  // BENCHMARK
  final iterations = 100;
  print('Running benchmark ($iterations iterations)...');

  final watchOriginal = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    _filterExpensesOriginal(expenses, selectedFilter, selectedAccountFilter, allAccountsKey);
  }
  watchOriginal.stop();
  print('Original approach: ${watchOriginal.elapsedMilliseconds} ms');

  final watchOptimized = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    _filterExpensesOptimized(expenses, selectedFilter, selectedAccountFilter, allAccountsKey);
  }
  watchOptimized.stop();
  print('Optimized approach: ${watchOptimized.elapsedMilliseconds} ms');
}

// ---------------------------------------------------------
// ORIGINAL IMPLEMENTATION
// ---------------------------------------------------------
List<MockExpenseModel> _filterExpensesOriginal(
  List<MockExpenseModel> expenses,
  RecordsFilter selectedFilter,
  String selectedAccountFilter,
  String allAccountsKey,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: now.weekday - 1));

  return expenses.where((expense) {
    final localDate = expense.date.toLocal();
    final dateOnly = DateTime(localDate.year, localDate.month, localDate.day);
    final matchesAccount =
        selectedAccountFilter == allAccountsKey || expense.accountId == selectedAccountFilter;

    if (!matchesAccount) {
      return false;
    }

    switch (selectedFilter) {
      case RecordsFilter.today:
        return dateOnly.year == today.year && dateOnly.month == today.month && dateOnly.day == today.day;
      case RecordsFilter.week:
        return !dateOnly.isBefore(weekStart) && !dateOnly.isAfter(today);
      case RecordsFilter.month:
        return dateOnly.year == today.year && dateOnly.month == today.month;
      case RecordsFilter.future:
        return dateOnly.isAfter(today);
      case RecordsFilter.all:
        return true;
    }
  }).toList(growable: false)
    ..sort((left, right) => right.date.compareTo(left.date));
}

// ---------------------------------------------------------
// OPTIMIZED IMPLEMENTATION
// ---------------------------------------------------------
List<MockExpenseModel> _filterExpensesOptimized(
  List<MockExpenseModel> expenses,
  RecordsFilter selectedFilter,
  String selectedAccountFilter,
  String allAccountsKey,
) {
  final nowLocal = DateTime.now();
  final todayLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);

  // Calculate local boundaries FIRST, outside the loop
  DateTime? startBoundLocal;
  DateTime? endBoundLocal;

  switch (selectedFilter) {
    case RecordsFilter.today:
      startBoundLocal = todayLocal;
      endBoundLocal = todayLocal.add(const Duration(days: 1));
      break;
    case RecordsFilter.week:
      startBoundLocal = todayLocal.subtract(Duration(days: nowLocal.weekday - 1));
      endBoundLocal = todayLocal.add(const Duration(days: 1));
      break;
    case RecordsFilter.month:
      startBoundLocal = DateTime(todayLocal.year, todayLocal.month, 1);
      endBoundLocal = DateTime(todayLocal.year, todayLocal.month + 1, 1);
      break;
    case RecordsFilter.future:
      startBoundLocal = todayLocal.add(const Duration(days: 1));
      endBoundLocal = null; // No end bound
      break;
    case RecordsFilter.all:
      startBoundLocal = null;
      endBoundLocal = null;
      break;
  }

  // Convert boundaries to UTC so we can compare directly with expense.date (which is UTC)
  final startBoundUtc = startBoundLocal?.toUtc();
  final endBoundUtc = endBoundLocal?.toUtc();

  final filterByAccount = selectedAccountFilter != allAccountsKey;

  return expenses.where((expense) {
    if (filterByAccount && expense.accountId != selectedAccountFilter) {
      return false;
    }

    if (startBoundUtc != null && expense.date.isBefore(startBoundUtc)) {
      return false;
    }
    if (endBoundUtc != null && !expense.date.isBefore(endBoundUtc)) {
      return false;
    }
    return true;
  }).toList(growable: false)
    ..sort((left, right) => right.date.compareTo(left.date));
}
