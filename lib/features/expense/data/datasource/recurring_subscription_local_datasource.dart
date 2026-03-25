import 'package:hive/hive.dart';

import '../models/recurring_subscription_model.dart';

class RecurringSubscriptionLocalDatasource {
  static const String boxName = 'subscriptions';

  Box<RecurringSubscriptionModel> get _box =>
      Hive.box<RecurringSubscriptionModel>(boxName);

  Future<List<RecurringSubscriptionModel>> getAllSubscriptions() async {
    final subscriptions = _box.values.toList(growable: false)
      ..sort((left, right) => left.nextBillDate.compareTo(right.nextBillDate));
    return subscriptions;
  }

  Future<void> saveSubscription(RecurringSubscriptionModel subscription) async {
    await _box.put(subscription.id, subscription);
  }

  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
  }
}
