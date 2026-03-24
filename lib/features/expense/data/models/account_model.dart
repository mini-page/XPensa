import 'dart:math';

import 'package:hive/hive.dart';

class AccountModel {
  AccountModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.balance,
  }) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Account id cannot be empty.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Account name cannot be empty.');
    }
  }

  factory AccountModel.create({
    required String name,
    required String iconKey,
    required double balance,
  }) {
    return AccountModel(
      id: _AccountIdGenerator.generate(),
      name: name.trim(),
      iconKey: iconKey,
      balance: balance,
    );
  }

  final String id;
  final String name;
  final String iconKey;
  final double balance;

  AccountModel copyWith({
    String? id,
    String? name,
    String? iconKey,
    double? balance,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      balance: balance ?? this.balance,
    );
  }
}

class AccountModelAdapter extends TypeAdapter<AccountModel> {
  static const int typeIdValue = 2;

  @override
  final int typeId = typeIdValue;

  @override
  AccountModel read(BinaryReader reader) {
    return AccountModel(
      id: reader.readString(),
      name: reader.readString(),
      iconKey: reader.readString(),
      balance: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.iconKey)
      ..writeDouble(obj.balance);
  }
}

abstract final class _AccountIdGenerator {
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
