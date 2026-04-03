import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../provider/preferences_providers.dart';
import '../widgets/ui_feedback.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appPreferencesControllerProvider);
    final smartReminders = ref.watch(smartRemindersEnabledProvider);
    final privacyMode = ref.watch(privacyModeEnabledProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(localeProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'General'),
            _SettingsCard(
              children: [
                _buildThemeTile(context, themeMode, controller),
                _buildLanguageTile(context, locale, controller),
                _buildCurrencyTile(context, currencySymbol, controller),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Security & Privacy'),
            _SettingsCard(
              children: [
                _buildToggleTile(
                  icon: Icons.security_outlined,
                  title: 'Privacy Mode',
                  subtitle: 'Mask balances across the app',
                  value: privacyMode,
                  onChanged: controller.setPrivacyMode,
                ),
                _buildToggleTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Smart Reminders',
                  subtitle: 'Gentle nudges for pending bills',
                  value: smartReminders,
                  onChanged: controller.setSmartReminders,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Data Management'),
            _SettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Export Data',
                  subtitle: 'Create a local backup file',
                  onTap: () {
                    // Logic to be added in Task 4
                    context.showSnackBar('Backup logic coming in next task.');
                  },
                ),
                _buildActionTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Import Data',
                  subtitle: 'Restore from a backup file',
                  onTap: () {
                    // Logic to be added in Task 4
                    context.showSnackBar('Restore logic coming in next task.');
                  },
                ),
                _buildToggleTile(
                  icon: Icons.history_rounded,
                  title: 'Auto Backup',
                  subtitle: 'Scheduled offline backups',
                  value: false, // Placeholder
                  onChanged: (val) {
                    showPlannedFeatureNotice(
                      context,
                      title: 'Auto backup is planned',
                      message: 'Scheduled backups will arrive in the next update.',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'About'),
            _SettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'XPensa Version',
                  subtitle: '1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'XPensa',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Offline-first expense tracking',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    ThemeMode currentMode,
    AppPreferencesController controller,
  ) {
    return ListTile(
      leading: const _TileIcon(icon: Icons.palette_outlined),
      title: const Text(
        'Appearance',
        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      trailing: DropdownButton<String>(
        value: currentMode.name,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            controller.setThemeMode(value);
          }
        },
        items: const [
          DropdownMenuItem(value: 'light', child: Text('Light')),
          DropdownMenuItem(value: 'dark', child: Text('Dark')),
          DropdownMenuItem(value: 'system', child: Text('System')),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String currentLocale,
    AppPreferencesController controller,
  ) {
    return ListTile(
      leading: const _TileIcon(icon: Icons.language_rounded),
      title: const Text(
        'Language',
        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      trailing: DropdownButton<String>(
        value: currentLocale,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            controller.setLocale(value);
          }
        },
        items: const [
          DropdownMenuItem(value: 'en_IN', child: Text('English (IN)')),
          DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
          DropdownMenuItem(value: 'hi_IN', child: Text('हिन्दी')),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    String currentCurrency,
    AppPreferencesController controller,
  ) {
    return ListTile(
      leading: const _TileIcon(icon: Icons.payments_outlined),
      title: const Text(
        'Currency',
        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      trailing: DropdownButton<String>(
        value: currentCurrency,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            controller.setCurrencySymbol(value);
          }
        },
        items: const [
          DropdownMenuItem(value: '\u20B9', child: Text('Rupee (\u20B9)')),
          DropdownMenuItem(value: '\$', child: Text('Dollar (\$)')),
          DropdownMenuItem(value: '\u20AC', child: Text('Euro (\u20AC)')),
          DropdownMenuItem(value: '\u00A3', child: Text('Pound (\u00A3)')),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: _TileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _TileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          final isLast = index == children.length - 1;
          if (isLast) return child;
          return Column(
            children: [
              child,
              const Divider(height: 1, indent: 70, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  final IconData icon;
  const _TileIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.primaryBlue, size: 22),
    );
  }
}
