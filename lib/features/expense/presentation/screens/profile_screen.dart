import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/preferences_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider).valueOrNull;
    final controller = ref.read(appPreferencesControllerProvider);
    final smartReminders = ref.watch(smartRemindersEnabledProvider);
    final privacyMode = ref.watch(privacyModeEnabledProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF0A6BE8),
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'XPensa',
                      style: TextStyle(
                        color: Color(0xFF152039),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Offline-first expense control',
                      style: TextStyle(
                        color: Color(0xFF90A1BE),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 26),
            const _ProfileHeroCard(),
            const SizedBox(height: 24),
            const Text(
              'Preferences',
              style: TextStyle(
                color: Color(0xFF0A6BE8),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _PreferenceToggleTile(
              icon: Icons.cloud_off_rounded,
              title: 'Local-first storage',
              subtitle:
                  'Expense, budget, account, and preference data stay on-device.',
              value: true,
              enabled: false,
              onChanged: null,
            ),
            _PreferenceToggleTile(
              icon: Icons.notifications_none_rounded,
              title: 'Smart reminders',
              subtitle: 'Store whether gentle follow-up nudges stay enabled.',
              value: smartReminders,
              onChanged: controller.setSmartReminders,
            ),
            _PreferenceToggleTile(
              icon: Icons.security_outlined,
              title: 'Privacy mode',
              subtitle: 'Mask balances and money values on the main screens.',
              value: privacyMode,
              onChanged: controller.setPrivacyMode,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1209386D),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      _TileIcon(icon: Icons.palette_outlined),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Appearance',
                              style: TextStyle(
                                color: Color(0xFF152039),
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Choose how the app theme behaves on this device.',
                              style: TextStyle(
                                color: Color(0xFF90A1BE),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        const <_ThemeChoice>[
                              _ThemeChoice(label: 'Light', keyValue: 'light'),
                              _ThemeChoice(label: 'Dark', keyValue: 'dark'),
                              _ThemeChoice(label: 'System', keyValue: 'system'),
                            ]
                            .map((choice) {
                              final isSelected = _matchesTheme(
                                themeMode,
                                choice.keyValue,
                              );
                              return ChoiceChip(
                                label: Text(choice.label),
                                selected: isSelected,
                                onSelected: (_) =>
                                    controller.setThemeMode(choice.keyValue),
                                selectedColor: const Color(0xFF0A6BE8),
                                backgroundColor: const Color(0xFFF1F5FB),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF42526B),
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            })
                            .toList(growable: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'App Status',
              style: TextStyle(
                color: Color(0xFF0A6BE8),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                const _StatusChip(label: 'Records Active'),
                const _StatusChip(label: 'Quick Add Active'),
                const _StatusChip(label: 'Stats Active'),
                _StatusChip(
                  label: smartReminders ? 'Reminders On' : 'Reminders Off',
                ),
                _StatusChip(label: privacyMode ? 'Privacy On' : 'Privacy Off'),
                _StatusChip(
                  label: themeMode == ThemeMode.dark
                      ? 'Dark Theme'
                      : themeMode == ThemeMode.system
                      ? 'System Theme'
                      : 'Light Theme',
                ),
                if (preferences == null)
                  const _StatusChip(label: 'Loading Preferences'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static bool _matchesTheme(ThemeMode currentMode, String key) {
    switch (key) {
      case 'dark':
        return currentMode == ThemeMode.dark;
      case 'system':
        return currentMode == ThemeMode.system;
      default:
        return currentMode == ThemeMode.light;
    }
  }
}

class _ThemeChoice {
  const _ThemeChoice({required this.label, required this.keyValue});

  final String label;
  final String keyValue;
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0A6BE8), Color(0xFF3E90FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Keep spending simple.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'XPensa now stores real local preferences for appearance, reminders, and privacy masking.',
            style: TextStyle(
              color: Color(0xD9FFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceToggleTile extends StatelessWidget {
  const _PreferenceToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1209386D),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _TileIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF152039),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF90A1BE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: const Color(0xFF0A6BE8)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0A6BE8),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
