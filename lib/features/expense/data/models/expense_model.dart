import 'dart:developer' as dev;

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const bool _kDebugMode = !bool.fromEnvironment('dart.vm.product');

enum TransactionType { expense, income, transfer }

extension TransactionTypeCodec on TransactionType {
  String get storageValue {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
      case TransactionType.transfer:
        return 'transfer';
    }
  }

  static TransactionType fromStorageValue(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}

class ExpenseModel {
  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required DateTime date,
    required this.note,
    this.accountId,
    this.toAccountId,
    this.type = TransactionType.expense,
  }) : date = date.toUtc() {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Expense id cannot be empty.');
    }
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Expense amount must be positive.',
      );
    }
    if (category.trim().isEmpty) {
      throw ArgumentError.value(
        category,
        'category',
        'Expense category cannot be empty.',
      );
    }
  }

  factory ExpenseModel.create({
    required double amount,
    required String category,
    required DateTime date,
    String note = '',
    String? accountId,
    String? toAccountId,
    TransactionType type = TransactionType.expense,
  }) {
    return ExpenseModel(
      id: const Uuid().v4(),
      amount: amount,
      category: category.trim(),
      date: date,
      note: note.trim(),
      accountId: accountId?.trim().isEmpty ?? true ? null : accountId?.trim(),
      toAccountId:
          toAccountId?.trim().isEmpty ?? true ? null : toAccountId?.trim(),
      type: type,
    );
  }

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final String? accountId;

  /// Destination account for [TransactionType.transfer] records.
  final String? toAccountId;
  final TransactionType type;

  bool get isIncome => type == TransactionType.income;

  /// Returns a signed amount for balance calculations.
  /// Transfers are balance-neutral at the record level (balance is adjusted
  /// per-account inside [ExpenseController.addTransfer]), so they return 0.
  double get signedAmount {
    if (type == TransactionType.transfer) {
      return 0;
    }
    return isIncome ? amount : -amount;
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? accountId,
    bool clearAccountId = false,
    String? toAccountId,
    bool clearToAccountId = false,
    TransactionType? type,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: clearAccountId ? null : accountId ?? this.accountId,
      toAccountId: clearToAccountId ? null : toAccountId ?? this.toAccountId,
      type: type ?? this.type,
    );
  }
}

class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  static const int typeIdValue = 0;

  @override
  final int typeId = typeIdValue;

  @override
  ExpenseModel read(BinaryReader reader) {
    final id = reader.readString();
    final amount = reader.readDouble();
    final category = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(
      reader.readInt(),
      isUtc: true,
    );
    final note = reader.readString();

    String? accountId;
    try {
      final storedAccountId = reader.readString();
      accountId = storedAccountId.isEmpty ? null : storedAccountId;
    } catch (e, stackTrace) {
      if (_kDebugMode) {
        dev.log(
          'Failed to parse accountId from storage',
          error: e,
          stackTrace: stackTrace,
          name: 'ExpenseModelAdapter',
        );
      }
      accountId = null;
    }

    TransactionType type;
    try {
      type = TransactionTypeCodec.fromStorageValue(reader.readString());
    } catch (e, stackTrace) {
      if (_kDebugMode) {
        dev.log(
          'Failed to parse TransactionType from storage',
          error: e,
          stackTrace: stackTrace,
          name: 'ExpenseModelAdapter',
        );
      }
      type = TransactionType.expense;
    }

    String? toAccountId;
    try {
      final stored = reader.readString();
      toAccountId = stored.isEmpty ? null : stored;
    } catch (_) {
      toAccountId = null;
    }

    return ExpenseModel(
      id: id,
      amount: amount,
      category: category,
      date: date,
      note: note,
      accountId: accountId,
      toAccountId: toAccountId,
      type: type,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeString(obj.id)
      ..writeDouble(obj.amount)
      ..writeString(obj.category)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeString(obj.note)
      ..writeString(obj.accountId ?? '')
      ..writeString(obj.type.storageValue)
      ..writeString(obj.toAccountId ?? '');
  }
}
