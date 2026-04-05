# State Management — Skill Module

## Domain
Advanced Riverpod patterns for Flutter: provider design, state modeling, async lifecycle, dependency injection, and testing.

## Core Concepts

### Provider Selection Guide

```
Need async data from Hive / network?
  → AsyncNotifierProvider<MyNotifier, MyState>

Need sync computed value derived from other providers?
  → Provider<MyType>((ref) => ...)

Need sync state with mutation methods?
  → NotifierProvider<MyNotifier, MyState>

Need simple UI toggle (tab index, filter selection)?
  → StateProvider<T>

Need a stream (e.g. real-time DB updates)?
  → StreamProvider<T>
```

### AsyncNotifier Pattern (Hive-backed)
```dart
@riverpod
class ExpenseList extends _$ExpenseList {
  @override
  Future<List<ExpenseModel>> build() async {
    final repo = ref.watch(expenseRepositoryProvider);
    return repo.getAllExpenses();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final repo = ref.read(expenseRepositoryProvider);
    await repo.addExpense(expense);
    ref.invalidateSelf(); // triggers build() to re-fetch
  }
}
```

### Derived State with Provider
```dart
final expenseStatsProvider = Provider<ExpenseStats>((ref) {
  final expenses = ref.watch(expenseListProvider).valueOrNull ?? [];
  return ExpenseStats.fromExpenses(expenses);
});
```

### Scoped Rebuilds with select
```dart
// Only rebuilds when totalExpense changes, not on any state mutation:
final total = ref.watch(expenseStatsProvider.select((s) => s.totalExpense));
```

### Side-Effects with listen
```dart
ref.listen<AsyncValue<void>>(saveExpenseProvider, (_, next) {
  next.whenOrNull(
    error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(...),
  );
});
```

### Testing
```dart
test('adds expense and invalidates list', () async {
  final container = ProviderContainer(overrides: [
    expenseRepositoryProvider.overrideWith(() => FakeExpenseRepository()),
  ]);
  final notifier = container.read(expenseListProvider.notifier);
  await notifier.addExpense(testExpense);
  final state = await container.read(expenseListProvider.future);
  expect(state, contains(testExpense));
});
```

## Anti-Patterns to Avoid
- Calling `ref.watch` outside `build()` — use `ref.read`.
- Storing mutable Flutter objects (`TextEditingController`, `AnimationController`) in Notifier state — manage them in a `StatefulWidget` or `HookWidget`.
- Circular provider dependencies.
- Creating providers inside widget `build` methods.

## Checklist
- [ ] Provider type matches use case (see guide above).
- [ ] `ref.watch` only in `build()`.
- [ ] Mutations update or invalidate state after completing.
- [ ] All provider types tested with `ProviderContainer`.
