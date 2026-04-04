class MockAccount {
  final String id;
  final String name;
  MockAccount(this.id, this.name);
}

class MockExpense {
  final String id;
  final String? accountId;
  MockExpense(this.id, this.accountId);
}

void main() {
  final accounts = List.generate(
    100,
    (index) => MockAccount('acc_$index', 'Account $index'),
  );

  final expenses = List.generate(
    10000,
    (index) => MockExpense('exp_$index', 'acc_${index % 100}'),
  );

  String? accountLabelForON(MockExpense expense, List<MockAccount> accounts) {
    if (expense.accountId == null) {
      return null;
    }

    for (final account in accounts) {
      if (account.id == expense.accountId) {
        return account.name;
      }
    }

    return 'Archived Account';
  }

  String? accountLabelForO1(MockExpense expense, Map<String, MockAccount> accountsMap) {
    if (expense.accountId == null) {
      return null;
    }

    final account = accountsMap[expense.accountId];
    if (account != null) {
      return account.name;
    }

    return 'Archived Account';
  }

  print('--- Benchmarking Account Lookup ---');
  print('Accounts: ${accounts.length}, Expenses: ${expenses.length}');

  // Pre-compute map for O(1) approach
  final accountsMap = {for (var a in accounts) a.id: a};

  // Warmup
  for (int i = 0; i < 1000; i++) {
    for (final expense in expenses) {
      accountLabelForON(expense, accounts);
      accountLabelForO1(expense, accountsMap);
    }
  }

  print('\nRunning O(N) lookup benchmark...');
  final watchON = Stopwatch()..start();
  for (int i = 0; i < 1000; i++) {
    for (final expense in expenses) {
      accountLabelForON(expense, accounts);
    }
  }
  watchON.stop();
  print('Baseline O(N) time (1000 iterations): ${watchON.elapsedMilliseconds} ms');

  print('\nRunning O(1) lookup benchmark (Map pre-computed)...');
  final watchO1 = Stopwatch()..start();
  for (int i = 0; i < 1000; i++) {
    // We include map creation inside the iteration to simulate build method
    final currentAccountsMap = {for (var a in accounts) a.id: a};
    for (final expense in expenses) {
      accountLabelForO1(expense, currentAccountsMap);
    }
  }
  watchO1.stop();
  print('Optimized O(1) time including Map creation (1000 iterations): ${watchO1.elapsedMilliseconds} ms');
}
