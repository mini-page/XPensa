import '../../expense/data/models/expense_model.dart';

/// The result of parsing a single SMS / notification message.
class SmsTransaction {
  const SmsTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.notes,
    required this.rawMessage,
    required this.senderAddress,
    required this.confidence,
  });

  /// Stable identifier (typically a hash of sender + body + timestamp).
  final String id;

  /// Extracted monetary amount (always positive).
  final double amount;

  /// Detected transaction direction.
  final TransactionType type;

  /// Date/time extracted from the message, or message-received time if absent.
  final DateTime timestamp;

  /// Human-readable notes built from ref ID, UPI ID, merchant name, etc.
  final String notes;

  /// Original raw SMS body.
  final String rawMessage;

  /// Sender alphanumeric ID or phone number.
  final String senderAddress;

  /// Parser confidence score in [0, 1]. Values below [SmsParserEngine.kMinConfidence]
  /// are considered low-confidence and require manual edit.
  final double confidence;
}
