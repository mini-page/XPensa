import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/app_colors.dart';
import 'settings/settings_widgets.dart';
import '../../../../core/utils/context_extensions.dart';
import '../provider/backup_providers.dart';
import '../provider/preferences_providers.dart';
import '../widgets/ui_feedback.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appPreferencesControllerProvider);
    final backupController = ref.read(backupControllerProvider);

    final smartReminders = ref.watch(smartRemindersEnabledProvider);
    final privacyMode = ref.watch(privacyModeEnabledProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(localeProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    // Backup states
    final autoBackup = ref.watch(autoBackupEnabledProvider);
    final backupFrequency = ref.watch(backupFrequencyProvider);
    final backupPath = ref.watch(backupDirectoryPathProvider);
    final lastBackup = ref.watch(lastBackupDateTimeProvider);

    final lastBackupText = lastBackup != null
        ? DateFormat('MMM d, yyyy HH:mm').format(lastBackup)
        : 'Never';

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
            const SettingsSectionHeader(title: 'General'),
            SettingsCard(
              children: [
                _buildThemeTile(context, themeMode, controller),
                _buildLanguageTile(context, locale, controller),
                _buildCurrencyTile(context, currencySymbol, controller),
              ],
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'Security & Privacy'),
            SettingsCard(
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
            const SettingsSectionHeader(title: 'Data Management'),
            SettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Export Data',
                  subtitle: 'Create a local backup file (.xpensa)',
                  onTap: () async {
                    try {
                      await backupController.exportData();
                    } catch (e) {
                      if (context.mounted) {
                        context.showSnackBar('Export failed: $e');
                      }
                    }
                  },
                ),
                _buildActionTile(
                  icon: Icons.cloud_download_outlined,
                  title: 'Import Data',
                  subtitle: 'Restore from a backup file',
                  onTap: () async {
                    final confirmed = await confirmDestructiveAction(
                      context,
                      title: 'Restore Data?',
                      message: 'This will overwrite your current transactions. This action cannot be undone.',
                      confirmLabel: 'Restore',
                    );

                    if (confirmed) {
                      try {
                        final success = await backupController.importData();
                        if (success && context.mounted) {
                          context.showSnackBar('Data restored successfully!');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showSnackBar('Import failed: $e');
                        }
                      }
                    }
                  },
                ),
                _buildToggleTile(
                  icon: Icons.history_rounded,
                  title: 'Auto Backup',
                  subtitle: 'Scheduled offline backups',
                  value: autoBackup,
                  onChanged: (val) async {
                    if (val && backupPath == null) {
                      final picked = await _pickBackupDirectory(context, ref);
                      if (picked == null) return;
                    }
                    controller.setAutoBackup(val);
                  },
                ),
                if (autoBackup) ...[
                  _buildSelectionTile(
                    icon: Icons.timer_outlined,
                    title: 'Backup Frequency',
                    subtitle: 'Current: ${backupFrequency.toUpperCase()}',
                    value: backupFrequency,
                    onChanged: (val) {
                      if (val != null) controller.setBackupFrequency(val);
                    },
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    ],
                  ),
                  _buildActionTile(
                    icon: Icons.folder_open_rounded,
                    title: 'Backup Location',
                    subtitle: backupPath ?? 'Not set',
                    onTap: () => _pickBackupDirectory(context, ref),
                  ),
                ],
                ListTile(
                  leading: const SettingsTileIcon(icon: Icons.update_rounded),
                  title: const Text(
                    'Last Backup',
                    style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    lastBackupText,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SettingsSectionHeader(title: 'About'),
            SettingsCard(
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

  Future<String?> _pickBackupDirectory(BuildContext context, WidgetRef ref) async {
    // Request permission first
    final status = await Permission.storage.request();
    if (!status.isGranted && !status.isLimited) {
      if (context.mounted) {
        context.showSnackBar('Storage permission is required for auto-backups.');
      }
      return null;
    }

    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      ref.read(appPreferencesControllerProvider).setBackupDirectory(path);
    }
    return path;
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required ValueChanged<String?> onChanged,
    required List<DropdownMenuItem<String>> items,
  }) {
    return ListTile(
      leading: SettingsTileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items,
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    ThemeMode currentMode,
    AppPreferencesController controller,
  ) {
    return ListTile(
      leading: const SettingsTileIcon(icon: Icons.palette_outlined),
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
      leading: const SettingsTileIcon(icon: Icons.language_rounded),
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
      leading: const SettingsTileIcon(icon: Icons.payments_outlined),
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
      leading: SettingsTileIcon(icon: icon),
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
      leading: SettingsTileIcon(icon: icon),
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

