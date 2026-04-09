import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/account_model.dart';
import '../../data/models/expense_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/account_icons.dart';
import '../widgets/expense_category.dart';
import 'add_expense/add_expense_widgets.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.initialAmount,
    this.initialCategory,
    this.initialDate,
    this.initialNote,
    this.initialAccountId,
    this.initialType = TransactionType.expense,
  });

  final String? expenseId;
  final double? initialAmount;
  final String? initialCategory;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialAccountId;
  final TransactionType initialType;

  bool get isEditing => expenseId != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _noteController;
  late String _amountText;
  late String _selectedExpenseCategory;
  late String _selectedIncomeCategory;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  String? _selectedAccountId;
  late bool _hasExplicitAccountChoice;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final seedDate = widget.initialDate ?? now;
    final shouldInjectCurrentTime = widget.initialDate != null &&
        seedDate.hour == 0 &&
        seedDate.minute == 0 &&
        seedDate.second == 0 &&
        seedDate.millisecond == 0 &&
        seedDate.microsecond == 0;
    _selectedDate = DateTime(
      seedDate.year,
      seedDate.month,
      seedDate.day,
      shouldInjectCurrentTime ? now.hour : seedDate.hour,
      shouldInjectCurrentTime ? now.minute : seedDate.minute,
    );
    _selectedType = widget.initialType;
    _amountText = widget.initialAmount?.toStringAsFixed(0) ?? '0';
    _selectedExpenseCategory = (_selectedType == TransactionType.expense
            ? widget.initialCategory
            : null) ??
        expenseCategories.first.name;
    _selectedIncomeCategory = (_selectedType == TransactionType.income
            ? widget.initialCategory
            : null) ??
        incomeCategories.first.name;
    _selectedAccountId = widget.initialAccountId;
    _hasExplicitAccountChoice =
        widget.initialAccountId != null || widget.isEditing;
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountListProvider);
    final accounts = accountState.value ?? const <AccountModel>[];
    if (!_hasExplicitAccountChoice && accounts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasExplicitAccountChoice) {
          return;
        }
        setState(() {
          _selectedAccountId = accounts.first.id;
          _hasExplicitAccountChoice = true;
        });
      });
    }

    final selectedExpenseCat = resolveExpenseCategory(_selectedExpenseCategory);
    final selectedIncomeCat = resolveIncomeCategory(_selectedIncomeCategory);
    final selectedAccount = _resolveSelectedAccount(accounts);
    final amount = double.tryParse(_amountText) ?? 0;
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final amountLabel =
        amount <= 0 ? '$symbol' '0' : _formatAmount(amount, locale, symbol);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  AddExpenseTopButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: <Widget>[
                        AddExpenseModeTab(
                          label: 'Expense',
                          isSelected: _selectedType == TransactionType.expense,
                          onTap: () => _switchType(TransactionType.expense),
                        ),
                        AddExpenseModeTab(
                          label: 'Income',
                          isSelected: _selectedType == TransactionType.income,
                          onTap: () => _switchType(TransactionType.income),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AddExpenseTopButton(
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF45D19A),
                    onTap: _pickDate,
                    tooltip: 'Select date',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        amountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _selectedType.isIncome
                              ? AppColors.success
                              : AppColors.textDark,
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AddExpenseTopButton(
                    icon: Icons.backspace_outlined,
                    onTap: _backspace,
                    tooltip: 'Backspace',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  controller: _noteController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Add note',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    suffixIcon: _noteController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _noteController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AddExpenseInfoCapsule(
                    icon: Icons.today_outlined,
                    label: DateFormat('EEE, d MMM').format(_selectedDate),
                    onTap: _pickDate,
                  ),
                  const SizedBox(width: 8),
                  AddExpenseInfoCapsule(
                    icon: Icons.schedule_rounded,
                    label: DateFormat('HH:mm').format(_selectedDate),
                    onTap: _pickTime,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AddExpenseQuickBar(
                selectedAccount: selectedAccount,
                expenseCategory: selectedExpenseCat,
                incomeCategory: selectedIncomeCat,
                selectedType: _selectedType,
                onTapAccount: () => _pickAccount(accounts),
                onTapExpenseCategory: _tapExpenseCategory,
                onTapIncomeCategory: _tapIncomeCategory,
                accountEnabled: accounts.isNotEmpty,
              ),
              const Spacer(),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: <Widget>[
                  for (final key in <String>[
                    '1',
                    '2',
                    '3',
                    '4',
                    '5',
                    '6',
                    '7',
                    '8',
                    '9',
                    '.',
                    '0',
                  ])
                    AddExpenseKeypadButton(label: key, onTap: () => _appendValue(key)),
                  AddExpenseKeypadButton(
                    label: '✓',
                    isPrimary: true,
                    onTap: _saveExpense,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  AccountModel? _resolveSelectedAccount(List<AccountModel> accounts) {
    if (accounts.isEmpty) {
      return null;
    }
    if (_hasExplicitAccountChoice && _selectedAccountId == null) {
      return null;
    }
    final desiredId = _selectedAccountId ?? widget.initialAccountId;
    if (desiredId == null) {
      return accounts.first;
    }
    for (final account in accounts) {
      if (account.id == desiredId) {
        return account;
      }
    }
    return accounts.first;
  }

  String _formatAmount(double amount, String locale, String symbol) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    ).format(amount);
  }

  void _appendValue(String value) {
    setState(() {
      if (value == '.' && _amountText.contains('.')) {
        return;
      }
      if (_amountText == '0' && value != '.') {
        _amountText = value;
      } else {
        _amountText += value;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_amountText.length <= 1) {
        _amountText = '0';
        return;
      }
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  void _switchType(TransactionType type) {
    if (_selectedType == type) {
      return;
    }
    setState(() {
      _selectedType = type;
    });
  }

  Future<void> _tapExpenseCategory() async {
    if (_selectedType != TransactionType.expense) {
      setState(() => _selectedType = TransactionType.expense);
    }
    await _pickExpenseCategory();
  }

  Future<void> _tapIncomeCategory() async {
    if (_selectedType != TransactionType.income) {
      setState(() => _selectedType = TransactionType.income);
    }
    await _pickIncomeCategory();
  }

  Future<void> _pickExpenseCategory() async {
    final selected = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DFEA),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select expense category',
                    style: TextStyle(
                      color: Color(0xFF111A33),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...expenseCategories.map((category) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.15),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: category.name == _selectedExpenseCategory
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0A6BE8),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(category),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedExpenseCategory = selected.name);
  }

  Future<void> _pickIncomeCategory() async {
    final selected = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DFEA),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select income category',
                    style: TextStyle(
                      color: Color(0xFF111A33),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...incomeCategories.map((category) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: category.color.withValues(alpha: 0.15),
                      child: Icon(category.icon, color: category.color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: category.name == _selectedIncomeCategory
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0A6BE8),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(category),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedIncomeCategory = selected.name);
  }

  Future<void> _pickAccount(List<AccountModel> accounts) async {
    final selected = await showModalBottomSheet<AccountModel?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DFEA),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose account',
                    style: TextStyle(
                      color: Color(0xFF111A33),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF5FF),
                    child: Icon(
                      Icons.do_not_disturb_on_outlined,
                      color: Color(0xFF90A1BE),
                    ),
                  ),
                  title: const Text(
                    'No account',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _selectedAccountId == null
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF0A6BE8),
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(null),
                ),
                ...accounts.map((account) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEFF5FF),
                      child: Icon(
                        resolveAccountIcon(account.iconKey),
                        color: const Color(0xFF0A6BE8),
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: account.id == _selectedAccountId
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0A6BE8),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(account),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedAccountId = selected?.id;
      _hasExplicitAccountChoice = true;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountText) ?? 0;
    final accounts =
        ref.read(accountListProvider).value ?? const <AccountModel>[];
    final effectiveAccountId = _resolveSelectedAccount(accounts)?.id;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount before saving.')),
      );
      return;
    }

    if (widget.isEditing) {
      await ref.read(expenseControllerProvider).updateExpense(
            id: widget.expenseId!,
            amount: amount,
            category: _selectedType.isIncome
                ? _selectedIncomeCategory
                : _selectedExpenseCategory,
            date: _selectedDate,
            note: _noteController.text,
            accountId: effectiveAccountId,
            type: _selectedType,
          );
    } else {
      await ref.read(expenseControllerProvider).addExpense(
            amount: amount,
            category: _selectedType.isIncome
                ? _selectedIncomeCategory
                : _selectedExpenseCategory,
            date: _selectedDate,
            note: _noteController.text,
            accountId: effectiveAccountId,
            type: _selectedType,
          );
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}
