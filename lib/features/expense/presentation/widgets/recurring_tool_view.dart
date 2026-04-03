import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/recurring_subscription_model.dart';
import '../provider/preferences_providers.dart';
import '../provider/recurring_subscription_providers.dart';
import '../widgets/subscription_editor_sheet.dart';
import '../widgets/subscription_icons.dart';

class RecurringToolView extends ConsumerWidget {
  const RecurringToolView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(recurringSubscriptionListProvider);
    final subscriptions = subscriptionState.value ?? const <RecurringSubscriptionModel>[];
    final locale = ref.watch(localeProvider);
    final symbol = ref.watch(currencySymbolProvider);

    final currency = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recurring Bills',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Manage your monthly subscriptions',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: () => _openEditor(context, ref),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add new subscription',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (subscriptionState.hasError)
          const _StateCard(
            title: 'Unable to load subscriptions',
            message: 'The recurring list is unavailable right now.',
          )
        else if (subscriptionState.isLoading && subscriptions.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (subscriptions.isEmpty)
          const _StateCard(
            title: 'No recurring subscriptions',
            message: 'Create the first subscription to keep upcoming bills visible.',
          )
        else
          ...subscriptions.map((subscription) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SubscriptionTile(
                subscription: subscription,
                amountText: currency.format(subscription.amount),
                onTap: () => _openEditor(context, ref, subscription: subscription),
                onDelete: () => ref
                    .read(recurringSubscriptionControllerProvider)
                    .deleteSubscription(subscription.id),
              ),
            );
          }),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    RecurringSubscriptionModel? subscription,
  }) async {
    final result = await showSubscriptionEditorSheet(
      context,
      subscription: subscription,
    );
    if (result == null) return;

    await ref.read(recurringSubscriptionControllerProvider).saveSubscription(
          id: result.id,
          name: result.name,
          amount: result.amount,
          nextBillDate: result.nextBillDate,
          iconKey: result.iconKey,
          note: result.note,
          isActive: result.isActive,
        );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.subscription,
    required this.amountText,
    required this.onTap,
    required this.onDelete,
  });

  final RecurringSubscriptionModel subscription;
  final String amountText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  resolveSubscriptionIcon(subscription.iconKey),
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subscription.name,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Next: ${DateFormat('d MMM').format(subscription.nextBillDate)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else {
                        onTap();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF152039),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6E7F9C),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
