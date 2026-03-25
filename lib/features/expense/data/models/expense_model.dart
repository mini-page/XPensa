import 'dart:math';

import 'package:hive/hive.dart';

enum TransactionType { expense, income }

extension TransactionTypeCodec on TransactionType {
  String get storageValue {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
    }
  }

  static TransactionType fromStorageValue(String value) {
    switch (value) {
      case 'income':
        return TransactionType.income;
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
    TransactionType type = TransactionType.expense,
  }) {
    return ExpenseModel(
      id: _ExpenseIdGenerator.generate(),
      amount: amount,
      category: category.trim(),
      date: date,
      note: note.trim(),
      accountId: accountId?.trim().isEmpty ?? true ? null : accountId?.trim(),
      type: type,
    );
  }

  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final String? accountId;
  final TransactionType type;

  bool get isIncome => type == TransactionType.income;

  double get signedAmount => isIncome ? amount : -amount;

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? accountId,
    bool clearAccountId = false,
    TransactionType? type,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: clearAccountId ? null : accountId ?? this.accountId,
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
    final date =
        DateTime.fromMillisecondsSinceEpoch(reader.readInt(), isUtc: true);
    final note = reader.readString();

    String? accountId;
    try {
      final storedAccountId = reader.readString();
      accountId = storedAccountId.isEmpty ? null : storedAccountId;
    } catch (_) {
      accountId = null;
    }

    TransactionType type;
    try {
      type = TransactionTypeCodec.fromStorageValue(reader.readString());
    } catch (_) {
      type = TransactionType.expense;
    }

    return ExpenseModel(
      id: id,
      amount: amount,
      category: category,
      date: date,
      note: note,
      accountId: accountId,
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
      ..writeString(obj.type.storageValue);
  }
}

abstract final class _ExpenseIdGenerator {
  static final Random _random = Random.secure();

  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return '${_hex(bytes.sublist(0, 4))}-'
        '${_hex(bytes.sublist(4, 6))}-'
        '${_hex(bytes.sublist(6, 8))}-'
        '${_hex(bytes.sublist(8, 10))}-'
        '${_hex(bytes.sublist(10, 16))}';
  }

  static String _hex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
