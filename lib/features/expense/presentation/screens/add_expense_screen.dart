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
import 'add_expense/amount_expression.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.initialAmount,
    this.initialCategory,
    this.initialDate,
    this.initialNote,
    this.initialAccountId,
    this.initialToAccountId,
    this.initialType = TransactionType.expense,
  });

  final String? expenseId;
  final double? initialAmount;
  final String? initialCategory;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialAccountId;
  final String? initialToAccountId;
  final TransactionType initialType;

  bool get isEditing => expenseId != null;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _noteController;
  late final FocusNode _noteFocusNode;
  late String _amountExpression;
  late String _selectedExpenseCategory;
  late String _selectedIncomeCategory;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  String? _selectedAccountId;
  String? _toAccountId;
  late bool _hasExplicitAccountChoice;
  bool _isSaving = false;

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
    _amountExpression = normalizeAmountSeed(widget.initialAmount);
    _selectedExpenseCategory = (_selectedType == TransactionType.expense
            ? widget.initialCategory
            : null) ??
        expenseCategories.first.name;
    _selectedIncomeCategory = (_selectedType == TransactionType.income
            ? widget.initialCategory
            : null) ??
        incomeCategories.first.name;
    _selectedAccountId = widget.initialAccountId;
    _toAccountId = widget.initialToAccountId;
    _hasExplicitAccountChoice =
        widget.initialAccountId != null || widget.isEditing;
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _noteFocusNode = FocusNode()..addListener(_handleNoteFocusChanged);
  }

  @override
  void dispose() {
    _noteFocusNode
      ..removeListener(_handleNoteFocusChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountListProvider).value ?? const <AccountModel>[];
    final disabledExpenseCategories =
        ref.watch(disabledExpenseCategoriesProvider);
    final disabledIncomeCategories =
        ref.watch(disabledIncomeCategoriesProvider);
    final disabledAccountIds = ref.watch(disabledAccountIdsProvider);
    final allExpenseCategories = ref.watch(allExpenseCategoriesProvider);
    final allIncomeCategories = ref.watch(allIncomeCategoriesProvider);
    final availableExpenseCategories = allExpenseCategories
        .where((category) => !disabledExpenseCategories.contains(category.name))
        .toList(growable: false);
    final availableIncomeCategories = allIncomeCategories
        .where((category) => !disabledIncomeCategories.contains(category.name))
        .toList(growable: false);
    final availableAccounts = accounts
        .where((account) => !disabledAccountIds.contains(account.id))
        .toList(growable: false);
    _queueDefaultSelections(
      availableAccounts,
      availableExpenseCategories,
      availableIncomeCategories,
    );

    final selectedExpenseCat = _selectedExpenseCategory.isEmpty
        ? null
        : resolveExpenseCategory(
            _selectedExpenseCategory, allExpenseCategories);
    final selectedIncomeCat = _selectedIncomeCategory.isEmpty
        ? null
        : resolveIncomeCategory(
            _selectedIncomeCategory, allIncomeCategories);
    final selectionAccounts = widget.isEditing ? accounts : availableAccounts;
    final selectedAccount = _resolveSelectedAccount(selectionAccounts);
    final toAccount = _resolveToAccount(selectionAccounts);
    final amountState = evaluateAmountExpression(_amountExpression);
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final amountLabel = amountState.previewAmount > 0
        ? _formatAmount(amountState.previewAmount, locale, symbol)
        : '$symbol${0.toStringAsFixed(0)}';
    final noteHintText = amountState.errorText == 'Amount must stay above zero.'
        ? 'Amount must stay above zero'
        : 'Add note';
    final showNoteIcon = noteHintText == 'Add note';
    final showNotePlaceholder =
        _noteController.text.isEmpty && !_noteFocusNode.hasFocus;
    final canSubmit = _canSubmit(
      amountState: amountState,
      selectedAccount: selectedAccount,
      toAccount: toAccount,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = MediaQuery.viewInsetsOf(context);
            final minHeight = constraints.maxHeight - viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          AddExpenseTopButton(
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.of(context).pop(),
                            tooltip: 'Close',
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F6FA),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: AddExpenseModeTab(
                                      label: 'Expense',
                                      icon: Icons.arrow_outward_rounded,
                                      activeColor: const Color(0xFFC23358),
                                      inactiveColor: const Color(0xFFC23358),
                                      isSelected: _selectedType ==
                                          TransactionType.expense,
                                      onTap: () =>
                                          _switchType(TransactionType.expense),
                                    ),
                                  ),
                                  Expanded(
                                    child: AddExpenseModeTab(
                                      label: 'Income',
                                      icon: Icons.arrow_downward_rounded,
                                      activeColor: AppColors.success,
                                      inactiveColor: AppColors.success,
                                      isSelected: _selectedType ==
                                          TransactionType.income,
                                      onTap: () =>
                                          _switchType(TransactionType.income),
                                    ),
                                  ),
                                  Expanded(
                                    child: AddExpenseModeTab(
                                      label: 'Transfer',
                                      icon: Icons.sync_alt_rounded,
                                      activeColor: AppColors.primaryBlue,
                                      inactiveColor: AppColors.primaryBlue,
                                      isSelected: _selectedType ==
                                          TransactionType.transfer,
                                      onTap: () =>
                                          _switchType(TransactionType.transfer),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        amountState.displayExpression,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            amountLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedType.isIncome
                                  ? AppColors.success
                                  : _selectedType.isTransfer
                                      ? AppColors.primaryBlue
                                      : AppColors.textDark,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FB),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: _noteFocusNode.hasFocus
                                  ? const <BoxShadow>[
                                      BoxShadow(
                                        color: Color(0x1409386D),
                                        blurRadius: 18,
                                        offset: Offset(0, 10),
                                      ),
                                    ]
                                  : const <BoxShadow>[],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                TextField(
                                  controller: _noteController,
                                  focusNode: _noteFocusNode,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  textInputAction: TextInputAction.done,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                if (showNotePlaceholder)
                                  IgnorePointer(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        if (showNoteIcon) ...<Widget>[
                                          const Icon(
                                            Icons.edit_note_rounded,
                                            size: 16,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          noteHintText,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AddExpenseSelectionCapsule(
                              icon: selectedAccount == null
                                  ? Icons.account_balance_wallet_outlined
                                  : resolveAccountIcon(selectedAccount.iconKey),
                              iconColor: AppColors.primaryBlue,
                              background: AppColors.lightBlueBg,
                              label: _sourceAccountLabel(selectedAccount),
                              onTap: availableAccounts.isNotEmpty
                                  ? () => _pickAccount(availableAccounts)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _selectedType == TransactionType.transfer
                                ? AddExpenseSelectionCapsule(
                                    icon: toAccount == null
                                        ? Icons.compare_arrows_rounded
                                        : resolveAccountIcon(
                                            toAccount.iconKey,
                                          ),
                                    iconColor: AppColors.primaryBlue,
                                    background: AppColors.lightBlueBg,
                                    label: _destinationAccountLabel(toAccount),
                                    onTap: availableAccounts.isNotEmpty
                                        ? () =>
                                            _pickToAccount(availableAccounts)
                                        : null,
                                  )
                                : AddExpenseSelectionCapsule(
                                    icon:
                                        _selectedType == TransactionType.income
                                            ? (selectedIncomeCat?.icon ??
                                                Icons.category_outlined)
                                            : (selectedExpenseCat?.icon ??
                                                Icons.category_outlined),
                                    iconColor:
                                        _selectedType == TransactionType.income
                                            ? (selectedIncomeCat?.color ??
                                                AppColors.textMuted)
                                            : (selectedExpenseCat?.color ??
                                                AppColors.textMuted),
                                    background:
                                        (_selectedType == TransactionType.income
                                                ? (selectedIncomeCat?.color ??
                                                    AppColors.textMuted)
                                                : (selectedExpenseCat?.color ??
                                                    AppColors.textMuted))
                                            .withValues(alpha: 0.15),
                                    label:
                                        _selectedType == TransactionType.income
                                            ? (selectedIncomeCat?.name ??
                                                'No income category enabled')
                                            : (selectedExpenseCat?.name ??
                                                'No expense category enabled'),
                                    onTap: _selectedType ==
                                            TransactionType.income
                                        ? (availableIncomeCategories.isEmpty
                                            ? null
                                            : _pickIncomeCategory)
                                        : (availableExpenseCategories.isEmpty
                                            ? null
                                            : _pickExpenseCategory),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AddExpenseInfoCapsule(
                              icon: Icons.today_outlined,
                              label: DateFormat('EEE, d MMM')
                                  .format(_selectedDate),
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AddExpenseInfoCapsule(
                              icon: Icons.schedule_rounded,
                              label: DateFormat('h:mm a').format(_selectedDate),
                              centerContent: true,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.96,
                        children: <Widget>[
                          _buildOperatorKey('+'),
                          _buildDigitKey('1'),
                          _buildDigitKey('2'),
                          _buildDigitKey('3'),
                          _buildOperatorKey('-'),
                          _buildDigitKey('4'),
                          _buildDigitKey('5'),
                          _buildDigitKey('6'),
                          AddExpenseKeypadButton(
                            onTap: amountState.canEvaluate
                                ? _applyExpression
                                : null,
                            isEnabled: amountState.canEvaluate,
                            backgroundColor: const Color(0xFFEFF5FF),
                            foregroundColor: AppColors.primaryBlue,
                            child: const Text('='),
                          ),
                          _buildDigitKey('7'),
                          _buildDigitKey('8'),
                          _buildDigitKey('9'),
                          AddExpenseKeypadButton(
                            onTap: _appendDecimal,
                            child: const Text('.'),
                          ),
                          _buildDigitKey('0'),
                          AddExpenseKeypadButton(
                            onTap: _backspace,
                            backgroundColor: const Color(0xFFFFE7EC),
                            foregroundColor: const Color(0xFFC23358),
                            child: const Icon(Icons.backspace_outlined),
                          ),
                          AddExpenseKeypadButton(
                            onTap: canSubmit ? _saveExpense : null,
                            isEnabled: canSubmit,
                            backgroundColor: AppColors.textDark,
                            foregroundColor: Colors.white,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AddExpenseKeypadButton _buildDigitKey(String value) {
    return AddExpenseKeypadButton(
      onTap: () => _appendDigit(value),
      child: Text(value),
    );
  }

  AddExpenseKeypadButton _buildOperatorKey(String operator) {
    return AddExpenseKeypadButton(
      onTap: () => _appendOperator(operator),
      backgroundColor: const Color(0xFFF1F4FB),
      foregroundColor: AppColors.textDark,
      child: Text(operator),
    );
  }

  void _handleNoteFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _queueDefaultSelections(
    List<AccountModel> availableAccounts,
    List<ExpenseCategory> availableExpenseCategories,
    List<ExpenseCategory> availableIncomeCategories,
  ) {
    if (widget.isEditing) {
      return;
    }
    final nextExpenseCategory = _resolveEnabledCategoryName(
      _selectedExpenseCategory,
      availableExpenseCategories,
    );
    final nextIncomeCategory = _resolveEnabledCategoryName(
      _selectedIncomeCategory,
      availableIncomeCategories,
    );
    final nextAccountId = _resolveEnabledAccountId(
      _selectedAccountId,
      availableAccounts,
    );
    final needsUpdate = nextExpenseCategory != _selectedExpenseCategory ||
        nextIncomeCategory != _selectedIncomeCategory ||
        nextAccountId != _selectedAccountId ||
        (!_hasExplicitAccountChoice && availableAccounts.isNotEmpty);

    if (!needsUpdate) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.isEditing) {
        return;
      }
      setState(() {
        _selectedExpenseCategory = nextExpenseCategory;
        _selectedIncomeCategory = nextIncomeCategory;
        _selectedAccountId = nextAccountId;
        _hasExplicitAccountChoice =
            _hasExplicitAccountChoice || availableAccounts.isNotEmpty;
        if (_selectedType == TransactionType.transfer) {
          _ensureTransferAccounts(availableAccounts);
        }
      });
    });
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

  AccountModel? _resolveToAccount(List<AccountModel> accounts) {
    if (accounts.isEmpty || _toAccountId == null) {
      return null;
    }
    for (final account in accounts) {
      if (account.id == _toAccountId) {
        return account;
      }
    }
    return null;
  }

  String _resolveEnabledCategoryName(
    String currentValue,
    List<ExpenseCategory> availableCategories,
  ) {
    if (availableCategories.isEmpty) {
      return '';
    }
    for (final category in availableCategories) {
      if (category.name == currentValue) {
        return currentValue;
      }
    }
    return availableCategories.first.name;
  }

  String? _resolveEnabledAccountId(
    String? currentValue,
    List<AccountModel> availableAccounts,
  ) {
    if (availableAccounts.isEmpty) {
      return null;
    }
    for (final account in availableAccounts) {
      if (account.id == currentValue) {
        return currentValue;
      }
    }
    return availableAccounts.first.id;
  }

  String _formatAmount(double amount, String locale, String symbol) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    ).format(amount);
  }

  String _sourceAccountLabel(AccountModel? account) {
    if (_selectedType == TransactionType.transfer) {
      return account == null ? 'From account' : 'From ${account.name}';
    }
    return account?.name ?? 'Choose account';
  }

  String _destinationAccountLabel(AccountModel? account) {
    return account == null ? 'To account' : 'To ${account.name}';
  }

  String? _validationMessage({
    required AmountExpressionResult amountState,
    required AccountModel? selectedAccount,
    required AccountModel? toAccount,
  }) {
    if (_isSaving) {
      return null;
    }
    if (amountState.errorText case final String error) {
      return error;
    }
    if (_selectedType == TransactionType.expense &&
        _selectedExpenseCategory.isEmpty) {
      return 'Enable at least one expense category.';
    }
    if (_selectedType == TransactionType.income &&
        _selectedIncomeCategory.isEmpty) {
      return 'Enable at least one income category.';
    }
    if (_selectedType == TransactionType.transfer) {
      if (selectedAccount == null || toAccount == null) {
        return 'Choose both accounts.';
      }
      if (selectedAccount.id == toAccount.id) {
        return 'Pick two different accounts.';
      }
    }
    return null;
  }

  bool _canSubmit({
    required AmountExpressionResult amountState,
    required AccountModel? selectedAccount,
    required AccountModel? toAccount,
  }) {
    return !_isSaving &&
        amountState.canSubmit &&
        _validationMessage(
              amountState: amountState,
              selectedAccount: selectedAccount,
              toAccount: toAccount,
            ) ==
            null;
  }

  void _appendDigit(String value) {
    setState(() {
      if (_amountExpression == '0') {
        _amountExpression = value;
        return;
      }

      final currentSegment = _currentSegment(_amountExpression);
      if (currentSegment == '0') {
        _amountExpression =
            _amountExpression.substring(0, _amountExpression.length - 1) +
                value;
        return;
      }

      _amountExpression += value;
    });
  }

  void _appendDecimal() {
    setState(() {
      final currentSegment = _currentSegment(_amountExpression);
      if (currentSegment.contains('.')) {
        return;
      }
      if (_amountExpression == '0') {
        _amountExpression = '0.';
        return;
      }
      if (_endsWithOperator(_amountExpression)) {
        _amountExpression += '0.';
        return;
      }
      _amountExpression += '.';
    });
  }

  void _appendOperator(String operator) {
    setState(() {
      if (_amountExpression.isEmpty || _amountExpression == '0') {
        return;
      }
      if (_endsWithOperator(_amountExpression)) {
        _amountExpression =
            '${_amountExpression.substring(0, _amountExpression.length - 1)}$operator';
        return;
      }
      if (_amountExpression.endsWith('.')) {
        _amountExpression += '0';
      }
      _amountExpression += operator;
    });
  }

  void _applyExpression() {
    final result = evaluateAmountExpression(_amountExpression);
    if (!result.canEvaluate) {
      return;
    }
    setState(() {
      _amountExpression = formatAmountExpressionValue(result.amount);
    });
  }

  void _backspace() {
    setState(() {
      if (_amountExpression.length <= 1) {
        _amountExpression = '0';
        return;
      }
      _amountExpression =
          _amountExpression.substring(0, _amountExpression.length - 1);
      if (_amountExpression.isEmpty) {
        _amountExpression = '0';
      }
    });
  }

  String _currentSegment(String expression) {
    final plusIndex = expression.lastIndexOf('+');
    final minusIndex = expression.lastIndexOf('-');
    final splitIndex = plusIndex > minusIndex ? plusIndex : minusIndex;
    if (splitIndex == -1) {
      return expression;
    }
    return expression.substring(splitIndex + 1);
  }

  bool _endsWithOperator(String expression) {
    return expression.endsWith('+') || expression.endsWith('-');
  }

  void _switchType(TransactionType type) {
    if (_selectedType == type) {
      return;
    }

    final accounts =
        ref.read(accountListProvider).value ?? const <AccountModel>[];
    final disabledExpenseCategories =
        ref.read(disabledExpenseCategoriesProvider);
    final disabledIncomeCategories = ref.read(disabledIncomeCategoriesProvider);
    final disabledAccountIds = ref.read(disabledAccountIdsProvider);
    final allExpenseCategories = ref.read(allExpenseCategoriesProvider);
    final allIncomeCategories = ref.read(allIncomeCategoriesProvider);
    final availableExpenseCategories = allExpenseCategories
        .where((category) => !disabledExpenseCategories.contains(category.name))
        .toList(growable: false);
    final availableIncomeCategories = allIncomeCategories
        .where((category) => !disabledIncomeCategories.contains(category.name))
        .toList(growable: false);
    final availableAccounts = accounts
        .where((account) => !disabledAccountIds.contains(account.id))
        .toList(growable: false);

    setState(() {
      _selectedType = type;
      if (type == TransactionType.transfer) {
        _ensureTransferAccounts(availableAccounts);
      }
      if (type != TransactionType.transfer) {
        _selectedExpenseCategory = _resolveEnabledCategoryName(
          _selectedExpenseCategory,
          availableExpenseCategories,
        );
      }
      if (type == TransactionType.income) {
        _selectedIncomeCategory = _resolveEnabledCategoryName(
          _selectedIncomeCategory,
          availableIncomeCategories,
        );
      }
    });
  }

  void _ensureTransferAccounts(List<AccountModel> accounts) {
    if (accounts.isEmpty) {
      return;
    }

    _selectedAccountId ??= accounts.first.id;
    if (_toAccountId == null || _toAccountId == _selectedAccountId) {
      for (final account in accounts) {
        if (account.id != _selectedAccountId) {
          _toAccountId = account.id;
          return;
        }
      }
      _toAccountId = accounts.first.id;
    }
  }

  Future<void> _pickExpenseCategory() async {
    final disabledExpenseCategories =
        ref.read(disabledExpenseCategoriesProvider);
    final allExpenseCategories = ref.read(allExpenseCategoriesProvider);
    final availableExpenseCategories = allExpenseCategories
        .where((category) => !disabledExpenseCategories.contains(category.name))
        .toList(growable: false);
    if (availableExpenseCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable an expense category first.')),
      );
      return;
    }
    final selected = await _showPickerSheet<ExpenseCategory>(
      title: 'Select expense category',
      children: availableExpenseCategories.map((category) {
        return _SelectionSheetTile(
          icon: category.icon,
          iconColor: category.color,
          iconBackground: category.color.withValues(alpha: 0.15),
          label: category.name,
          isSelected: category.name == _selectedExpenseCategory,
          onTap: () => Navigator.of(context).pop(category),
        );
      }).toList(growable: false),
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedExpenseCategory = selected.name);
  }

  Future<void> _pickIncomeCategory() async {
    final disabledIncomeCategories = ref.read(disabledIncomeCategoriesProvider);
    final allIncomeCategories = ref.read(allIncomeCategoriesProvider);
    final availableIncomeCategories = allIncomeCategories
        .where((category) => !disabledIncomeCategories.contains(category.name))
        .toList(growable: false);
    if (availableIncomeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable an income category first.')),
      );
      return;
    }
    final selected = await _showPickerSheet<ExpenseCategory>(
      title: 'Select income category',
      children: availableIncomeCategories.map((category) {
        return _SelectionSheetTile(
          icon: category.icon,
          iconColor: category.color,
          iconBackground: category.color.withValues(alpha: 0.15),
          label: category.name,
          isSelected: category.name == _selectedIncomeCategory,
          onTap: () => Navigator.of(context).pop(category),
        );
      }).toList(growable: false),
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedIncomeCategory = selected.name);
  }

  Future<void> _pickAccount(List<AccountModel> accounts) async {
    final selected = await _showPickerSheet<_NullableAccountSelection>(
      title: 'Choose account',
      children: <Widget>[
        _SelectionSheetTile(
          icon: Icons.do_not_disturb_on_outlined,
          iconColor: AppColors.textMuted,
          iconBackground: const Color(0xFFEFF5FF),
          label: 'No account',
          isSelected: _selectedAccountId == null,
          onTap: () => Navigator.of(context).pop(
            const _NullableAccountSelection(null),
          ),
        ),
        ...accounts.map((account) {
          return _SelectionSheetTile(
            icon: resolveAccountIcon(account.iconKey),
            iconColor: AppColors.primaryBlue,
            iconBackground: const Color(0xFFEFF5FF),
            label: account.name,
            isSelected: account.id == _selectedAccountId,
            onTap: () => Navigator.of(context).pop(
              _NullableAccountSelection(account),
            ),
          );
        }),
      ],
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedAccountId = selected.account?.id;
      _hasExplicitAccountChoice = true;
      if (_selectedType == TransactionType.transfer) {
        _ensureTransferAccounts(accounts);
      }
    });
  }

  Future<void> _pickToAccount(List<AccountModel> accounts) async {
    final selected = await _showPickerSheet<AccountModel>(
      title: 'Transfer to account',
      children: accounts.map((account) {
        return _SelectionSheetTile(
          icon: resolveAccountIcon(account.iconKey),
          iconColor: AppColors.primaryBlue,
          iconBackground: const Color(0xFFEFF5FF),
          label: account.name,
          isSelected: account.id == _toAccountId,
          onTap: () => Navigator.of(context).pop(account),
        );
      }).toList(growable: false),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _toAccountId = selected.id;
    });
  }

  Future<T?> _showPickerSheet<T>({
    required String title,
    required List<Widget> children,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.74,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7DFEA),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111A33),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: children,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
    if (_isSaving) {
      return;
    }

    final amountState = evaluateAmountExpression(_amountExpression);
    final accounts =
        ref.read(accountListProvider).value ?? const <AccountModel>[];
    final disabledAccountIds = ref.read(disabledAccountIdsProvider);
    final selectionAccounts = widget.isEditing
        ? accounts
        : accounts
            .where((account) => !disabledAccountIds.contains(account.id))
            .toList(growable: false);
    final selectedAccount = _resolveSelectedAccount(selectionAccounts);
    final toAccount = _resolveToAccount(selectionAccounts);
    final validationMessage = _validationMessage(
      amountState: amountState,
      selectedAccount: selectedAccount,
      toAccount: toAccount,
    );

    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(expenseControllerProvider);
      if (_selectedType == TransactionType.transfer) {
        if (widget.isEditing) {
          await controller.updateExpense(
            id: widget.expenseId!,
            amount: amountState.amount,
            category: 'Transfer',
            date: _selectedDate,
            note: _noteController.text,
            accountId: selectedAccount?.id,
            toAccountId: toAccount?.id,
            type: TransactionType.transfer,
          );
        } else {
          await controller.addTransfer(
            amount: amountState.amount,
            fromAccountId: selectedAccount!.id,
            toAccountId: toAccount!.id,
            date: _selectedDate,
            note: _noteController.text,
          );
        }
      } else if (widget.isEditing) {
        await controller.updateExpense(
          id: widget.expenseId!,
          amount: amountState.amount,
          category: _selectedType.isIncome
              ? _selectedIncomeCategory
              : _selectedExpenseCategory,
          date: _selectedDate,
          note: _noteController.text,
          accountId: selectedAccount?.id,
          type: _selectedType,
        );
      } else {
        await controller.addExpense(
          amount: amountState.amount,
          category: _selectedType.isIncome
              ? _selectedIncomeCategory
              : _selectedExpenseCategory,
          date: _selectedDate,
          note: _noteController.text,
          accountId: selectedAccount?.id,
          type: _selectedType,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _NullableAccountSelection {
  const _NullableAccountSelection(this.account);

  final AccountModel? account;
}

class _SelectionSheetTile extends StatelessWidget {
  const _SelectionSheetTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? const Color(0xFFF6F9FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          leading: CircleAvatar(
            backgroundColor: iconBackground,
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check_rounded,
                  color: AppColors.primaryBlue,
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
