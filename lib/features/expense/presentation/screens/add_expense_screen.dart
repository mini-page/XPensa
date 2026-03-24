import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/account_model.dart';
import '../provider/account_providers.dart';
import '../provider/expense_providers.dart';
import '../widgets/account_icons.dart';
import '../widgets/expense_category.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.initialAmount,
    this.initialCategory,
    this.initialDate,
    this.initialNote,
    this.initialAccountId,
  });

  final String? expenseId;
  final double? initialAmount;
  final String? initialCategory;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialAccountId;

  bool get isEditing => expenseId != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _noteController;
  late String _amountText;
  late String _selectedCategory;
  late DateTime _selectedDate;
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
    _amountText = widget.initialAmount?.toStringAsFixed(0) ?? '0';
    _selectedCategory = widget.initialCategory ?? expenseCategories.first.name;
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
    final accounts = accountState.valueOrNull ?? const <AccountModel>[];
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
    final effectiveAccount = _resolveSelectedAccount(accounts);
    final amount = double.tryParse(_amountText) ?? 0;
    final amountLabel = amount <= 0 ? '₹0' : _formatAmount(amount);
    final selectedCategory = resolveCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.isEditing ? Icons.edit_rounded : Icons.bolt_rounded,
                  color: const Color(0xFFFA5B8C),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.isEditing ? 'Edit Transaction.' : 'Blazing Fast Input.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF111A33),
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  _TopCircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
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
                        _ModeTab(
                          label: 'Expense',
                          isSelected: true,
                          onTap: () {},
                        ),
                        _ModeTab(
                          label: 'Income',
                          isSelected: false,
                          onTap: _showIncomeMessage,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _TopCircleButton(
                    icon: Icons.calendar_month_rounded,
                    color: const Color(0xFF45D19A),
                    onTap: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      amountLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111A33),
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _TopCircleButton(
                    icon: Icons.backspace_outlined,
                    onTap: _backspace,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            selectedCategory.icon,
                            size: 18,
                            color: selectedCategory.color,
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              selectedCategory.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF34435F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF8B99B0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        accounts.isEmpty ? null : () => _pickAccount(accounts),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            effectiveAccount == null
                                ? Icons.account_balance_wallet_outlined
                                : resolveAccountIcon(effectiveAccount.iconKey),
                            size: 18,
                            color: const Color(0xFF0A6BE8),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              effectiveAccount?.name ?? 'No account',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF34435F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF8B99B0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _InfoCapsule(
                    icon: Icons.today_outlined,
                    label: DateFormat('EEE, d MMM').format(_selectedDate),
                    onTap: _pickDate,
                  ),
                  const SizedBox(width: 10),
                  _InfoCapsule(
                    icon: Icons.schedule_rounded,
                    label: DateFormat('HH:mm').format(_selectedDate),
                    onTap: _pickTime,
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
                    hintText: 'Add note (optional)',
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
                    _KeypadButton(
                      label: key,
                      onTap: () => _appendValue(key),
                    ),
                  _KeypadButton(
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

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
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

  Future<void> _pickCategory() async {
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
                    'Select category',
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
                    trailing: category.name == _selectedCategory
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

    setState(() {
      _selectedCategory = selected.name;
    });
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

  void _showIncomeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Income tracking is planned for a later release.'),
      ),
    );
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountText) ?? 0;
    final accounts =
        ref.read(accountListProvider).valueOrNull ?? const <AccountModel>[];
    final effectiveAccountId = _resolveSelectedAccount(accounts)?.id;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount before saving.'),
        ),
      );
      return;
    }

    if (widget.isEditing) {
      await ref.read(expenseControllerProvider).updateExpense(
            id: widget.expenseId!,
            amount: amount,
            category: _selectedCategory,
            date: _selectedDate,
            note: _noteController.text,
            accountId: effectiveAccountId,
          );
    } else {
      await ref.read(expenseControllerProvider).addExpense(
            amount: amount,
            category: _selectedCategory,
            date: _selectedDate,
            note: _noteController.text,
            accountId: effectiveAccountId,
          );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF8B99B0),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F7FB),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF111A33) : const Color(0xFFA6B2C7),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoCapsule extends StatelessWidget {
  const _InfoCapsule({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FB),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: const Color(0xFF7D8BA5)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF4A5874),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? const Color(0xFF383838) : const Color(0xFFF6F7FA),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? Colors.white : const Color(0xFF111A33),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
