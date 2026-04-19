// ignore_for_file: avoid_print
class MockExpense {
  final String id;
  MockExpense(this.id);
}

void main() {
  final count = 1000;
  final iterations = 10000;
  final expenses = List.generate(
    count,
    (index) => MockExpense('id_$index'),
  );

  final targetId = 'id_${count - 1}';

  print('--- Benchmarking Search Patterns ---');
  print('List size: $count, Iterations: $iterations');

  // Warmup
  for (var i = 0; i < 1000; i++) {
    expenses.where((e) => e.id == targetId).firstOrNull;
    expenses
        .cast<MockExpense?>()
        .firstWhere((e) => e?.id == targetId, orElse: () => null);
  }

  final watch1 = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    expenses.where((e) => e.id == targetId).firstOrNull;
  }
  watch1.stop();
  print('where(...).firstOrNull: ${watch1.elapsedMilliseconds} ms');

  final watch2 = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    expenses
        .cast<MockExpense?>()
        .firstWhere((e) => e?.id == targetId, orElse: () => null);
  }
  watch2.stop();
  print(
      'cast<T?>().firstWhere(..., orElse: () => null): ${watch2.elapsedMilliseconds} ms');

  final watch3 = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    for (final e in expenses) {
      if (e.id == targetId) {
        break;
      }
    }
  }
  watch3.stop();
  print('Manual for-loop: ${watch3.elapsedMilliseconds} ms');
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
