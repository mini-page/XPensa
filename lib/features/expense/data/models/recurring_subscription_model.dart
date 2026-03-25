import 'dart:math';

import 'package:hive/hive.dart';

class RecurringSubscriptionModel {
  RecurringSubscriptionModel({
    required this.id,
    required this.name,
    required this.amount,
    required DateTime nextBillDate,
    required this.iconKey,
    this.note = '',
    this.isActive = true,
  }) : nextBillDate = DateTime(
          nextBillDate.year,
          nextBillDate.month,
          nextBillDate.day,
        ) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Subscription id cannot be empty.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Subscription name cannot be empty.');
    }
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Subscription amount must be positive.');
    }
  }

  factory RecurringSubscriptionModel.create({
    required String name,
    required double amount,
    required DateTime nextBillDate,
    required String iconKey,
    String note = '',
    bool isActive = true,
  }) {
    return RecurringSubscriptionModel(
      id: _SubscriptionIdGenerator.generate(),
      name: name.trim(),
      amount: amount,
      nextBillDate: nextBillDate,
      iconKey: iconKey,
      note: note.trim(),
      isActive: isActive,
    );
  }

  final String id;
  final String name;
  final double amount;
  final DateTime nextBillDate;
  final String iconKey;
  final String note;
  final bool isActive;

  RecurringSubscriptionModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? nextBillDate,
    String? iconKey,
    String? note,
    bool? isActive,
  }) {
    return RecurringSubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      nextBillDate: nextBillDate ?? this.nextBillDate,
      iconKey: iconKey ?? this.iconKey,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }
}

class RecurringSubscriptionModelAdapter extends TypeAdapter<RecurringSubscriptionModel> {
  static const int typeIdValue = 4;

  @override
  final int typeId = typeIdValue;

  @override
  RecurringSubscriptionModel read(BinaryReader reader) {
    return RecurringSubscriptionModel(
      id: reader.readString(),
      name: reader.readString(),
      amount: reader.readDouble(),
      nextBillDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      iconKey: reader.readString(),
      note: reader.readString(),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, RecurringSubscriptionModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeDouble(obj.amount)
      ..writeInt(obj.nextBillDate.millisecondsSinceEpoch)
      ..writeString(obj.iconKey)
      ..writeString(obj.note)
      ..writeBool(obj.isActive);
  }
}

abstract final class _SubscriptionIdGenerator {
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
