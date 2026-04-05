// ignore_for_file: avoid_print
import 'dart:math';

class ExpenseModel {
  final String id;
  final String? accountId;
  ExpenseModel({required this.id, this.accountId});
}

class AccountModel {
  final String id;
  final String name;
  AccountModel({required this.id, required this.name});
}

void main() {
  final random = Random(42);

  // Generate 100 accounts
  final accounts = List.generate(
    100,
    (i) => AccountModel(id: 'acc_$i', name: 'Account $i'),
  );

  // Generate 10,000 expenses
  final expenses = List.generate(
    10000,
    (i) => ExpenseModel(
      id: 'exp_$i',
      accountId: random.nextBool() ? 'acc_${random.nextInt(100)}' : null,
    ),
  );

  String? accountLabelForLinear(
    ExpenseModel expense,
    List<AccountModel> accounts,
  ) {
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

  String? accountLabelForMap(
    ExpenseModel expense,
    Map<String, String> accountMap,
  ) {
    final accountId = expense.accountId;
    if (accountId == null) {
      return null;
    }
    return accountMap[accountId] ?? 'Archived Account';
  }

  int labelChecksum(String? label) => label?.length ?? 0;

  // Linear benchmark
  var linearChecksum = 0;
  final swLinear = Stopwatch()..start();
  for (int i = 0; i < 1000; i++) {
    for (final expense in expenses) {
      linearChecksum += labelChecksum(accountLabelForLinear(expense, accounts));
    }
  }
  swLinear.stop();
  print(
    'Linear search (1000 iterations): ${swLinear.elapsedMilliseconds} ms '
    '(checksum: $linearChecksum)',
  );

  // Map benchmark
  var mapChecksum = 0;
  final swMap = Stopwatch()..start();
  for (int i = 0; i < 1000; i++) {
    final accountMap = {for (var a in accounts) a.id: a.name};
    for (final expense in expenses) {
      mapChecksum += labelChecksum(accountLabelForMap(expense, accountMap));
    }
  }
  swMap.stop();
  print(
    'Map lookup (1000 iterations): ${swMap.elapsedMilliseconds} ms '
    '(checksum: $mapChecksum)',
  );
}
