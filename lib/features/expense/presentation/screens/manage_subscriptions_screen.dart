import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/recurring_subscription_model.dart';
import '../provider/recurring_subscription_providers.dart';
import '../widgets/subscription_editor_sheet.dart';
import '../widgets/subscription_icons.dart';

class ManageSubscriptionsScreen extends ConsumerWidget {
  const ManageSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(recurringSubscriptionListProvider);
    final subscriptions =
        subscriptionState.valueOrNull ?? const <RecurringSubscriptionModel>[];
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Recurring',
          style: TextStyle(
            color: Color(0xFF152039),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, ref),
        backgroundColor: const Color(0xFF0A6BE8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: subscriptionState.hasError
              ? const _SubscriptionStateCard(
                  title: 'Unable to load subscriptions',
                  message: 'The recurring list is unavailable right now.',
                )
              : subscriptionState.isLoading && subscriptions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : subscriptions.isEmpty
              ? const _SubscriptionStateCard(
                  title: 'No recurring subscriptions',
                  message:
                      'Create the first subscription to keep upcoming bills visible.',
                )
              : ListView(
                  children: subscriptions
                      .map((subscription) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _SubscriptionTile(
                            subscription: subscription,
                            amountText: currency.format(subscription.amount),
                            onTap: () => _openEditor(
                              context,
                              ref,
                              subscription: subscription,
                            ),
                            onDelete: () => ref
                                .read(recurringSubscriptionControllerProvider)
                                .deleteSubscription(subscription.id),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
        ),
      ),
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
    if (result == null) {
      return;
    }

    await ref
        .read(recurringSubscriptionControllerProvider)
        .saveSubscription(
          id: result.id,
          name: result.name,
          amount: result.amount,
          nextBillDate: result.nextBillDate,
          iconKey: result.iconKey,
          note: result.note,
          isActive: result.isActive,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          subscription == null
              ? '${result.name} created.'
              : '${result.name} updated.',
        ),
      ),
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
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  resolveSubscriptionIcon(subscription.iconKey),
                  color: const Color(0xFF0A6BE8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subscription.name,
                      style: const TextStyle(
                        color: Color(0xFF152039),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next bill: ${DateFormat('d MMM yyyy').format(subscription.nextBillDate)}',
                      style: const TextStyle(
                        color: Color(0xFF90A1BE),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    amountText,
                    style: const TextStyle(
                      color: Color(0xFF0A6BE8),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: subscription.isActive
                              ? const Color(0xFFE8F9EF)
                              : const Color(0xFFF3F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subscription.isActive ? 'Active' : 'Paused',
                          style: TextStyle(
                            color: subscription.isActive
                                ? const Color(0xFF1DAA63)
                                : const Color(0xFF90A1BE),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Color(0xFF90A1BE),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDelete();
                            return;
                          }
                          onTap();
                        },
                        itemBuilder: (context) =>
                            const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
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

class _SubscriptionStateCard extends StatelessWidget {
  const _SubscriptionStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1209386D),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF152039),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF6E7F9C),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
