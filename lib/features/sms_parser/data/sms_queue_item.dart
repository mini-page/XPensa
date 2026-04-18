import 'sms_transaction.dart';

/// Lifecycle states for a parsed-SMS transaction waiting in the queue.
enum SmsQueueStatus {
  /// Awaiting user confirmation or auto-confirm.
  pending,

  /// Saved automatically using default account / category.
  confirmed,

  /// User chose to edit; opened in AddExpenseScreen.
  editing,

  /// User dismissed / app saved after edit.
  dismissed,
}

/// An entry in the SMS confirmation queue.
class SmsQueueItem {
  const SmsQueueItem({
    required this.transaction,
    this.status = SmsQueueStatus.pending,
    required this.receivedAt,
  });

  final SmsTransaction transaction;
  final SmsQueueStatus status;
  final DateTime receivedAt;

  SmsQueueItem copyWith({SmsQueueStatus? status}) {
    return SmsQueueItem(
      transaction: transaction,
      status: status ?? this.status,
      receivedAt: receivedAt,
    );
  }
}
