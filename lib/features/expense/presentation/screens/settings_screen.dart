import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/update_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import 'settings/settings_widgets.dart';
import '../../../../core/utils/context_extensions.dart';
import '../provider/account_providers.dart';
import '../provider/backup_providers.dart';
import '../provider/budget_providers.dart';
import '../provider/expense_providers.dart';
import '../provider/preferences_providers.dart';
import '../provider/recurring_subscription_providers.dart';
import '../widgets/ui_feedback.dart';
import 'about_screen.dart';
import 'pin_entry_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appPreferencesControllerProvider);
    final backupController = ref.read(backupControllerProvider);

    final smartReminders = ref.watch(smartRemindersEnabledProvider);
    final privacyMode = ref.watch(privacyModeEnabledProvider);
    final isPinEnabled = ref.watch(isPinEnabledProvider);
    final displayName = ref.watch(displayNameProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(localeProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    // Backup states
    final autoBackup = ref.watch(autoBackupEnabledProvider);
    final backupFrequency = ref.watch(backupFrequencyProvider);
    final backupPath = ref.watch(backupDirectoryPathProvider);
    final lastBackup = ref.watch(lastBackupDateTimeProvider);

    // Update check state
    final updateState = ref.watch(updateCheckerProvider);

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
            // ── Profile ───────────────────────────────────────────────────
            const SettingsSectionHeader(title: 'Profile'),
            SettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Display Name',
                  subtitle: displayName.trim().isEmpty
                      ? 'Tap to set your name'
                      : displayName,
                  onTap: () => _editDisplayName(context, ref, displayName),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── General ──────────────────────────────────────────────────
            const SettingsSectionHeader(title: 'General'),
            SettingsCard(
              children: [
                _buildThemeTile(context, themeMode, controller),
                _buildCurrencyTile(context, currencySymbol, controller),
                _buildLanguageTile(context, locale, controller),
              ],
            ),
            const SizedBox(height: 24),

            // ── Notifications ─────────────────────────────────────────────
            const SettingsSectionHeader(title: 'Notifications'),
            SettingsCard(
              children: [
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

            // ── Security & Privacy ────────────────────────────────────────
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
                  icon: Icons.pin_outlined,
                  title: 'PIN Lock',
                  subtitle: isPinEnabled
                      ? 'Tap to change or disable PIN'
                      : 'Protect the app with a 4-digit PIN',
                  value: isPinEnabled,
                  onChanged: (enabled) =>
                      _handlePinToggle(context, ref, enabled),
                ),
                if (isPinEnabled)
                  _buildActionTile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Change PIN',
                    subtitle: 'Set a new 4-digit PIN',
                    onTap: () async {
                      await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => const PinEntryScreen(
                            isSetup: true,
                            isChange: true,
                          ),
                        ),
                      );
                    },
                  ),
                _buildComingSoonTile(
                  context,
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Lock',
                  subtitle: 'Secure the app with fingerprint or face ID',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Data Management ───────────────────────────────────────────
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
                      message:
                          'This will overwrite your current transactions. This action cannot be undone.',
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
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly')),
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
                    style: TextStyle(
                        color: AppColors.textDark, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    lastBackupText,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── App Management ────────────────────────────────────────────
            const SettingsSectionHeader(title: 'App Management'),
            SettingsCard(
              children: [
                _buildDangerTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Reset App Data',
                  subtitle:
                      'Permanently erase all transactions and accounts',
                  onTap: () => _resetAppData(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── About ─────────────────────────────────────────────────────
            const SettingsSectionHeader(title: 'About'),
            SettingsCard(
              children: [
                _buildActionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'About XPensa & developer info',
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen()),
                  ),
                ),
                _buildUpdateTile(context, ref, updateState),
                _buildActionTile(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'Support the Project',
                  subtitle: 'Donate or star the repo',
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                        builder: (_) => const SupportScreen()),
                  ),
                ),
                _buildActionTile(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy & Terms',
                  subtitle: 'How we handle your data',
                  onTap: () => showPlannedFeatureNotice(
                    context,
                    title: 'Privacy Policy',
                    message:
                        'XPensa stores all data locally on your device. No data is ever sent to any server or third party.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePinToggle(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final controller = ref.read(appPreferencesControllerProvider);
    if (enable) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const PinEntryScreen(isSetup: true),
        ),
      );
      if (result != true && context.mounted) {
        context.showSnackBar('PIN setup cancelled.');
      }
    } else {
      final confirmed = await confirmDestructiveAction(
        context,
        title: 'Disable PIN Lock?',
        message: 'The app will no longer require a PIN to open.',
        confirmLabel: 'Disable',
      );
      if (confirmed) {
        await controller.clearPin();
      }
    }
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = ref.read(appPreferencesControllerProvider);
    final textController = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display Name'),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(
            hintText: 'Your name',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(textController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await controller.setDisplayName(result);
    }
  }

  Future<void> _resetAppData(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDestructiveAction(
      context,
      title: 'Reset All Data?',
      message:
          'This will permanently delete all transactions, accounts, '
          'subscriptions, and budgets. Your settings will be preserved. '
          'This cannot be undone.',
      confirmLabel: 'Reset Everything',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(backupControllerProvider).resetAllData();
      ref.invalidate(expenseListProvider);
      ref.invalidate(accountListProvider);
      ref.invalidate(budgetTargetsProvider);
      ref.invalidate(recurringSubscriptionListProvider);
      if (context.mounted) {
        context.showSnackBar('All data has been reset.');
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Reset failed: $e');
      }
    }
  }

  Future<String?> _pickBackupDirectory(
      BuildContext context, WidgetRef ref) async {
    // Request permission first
    final status = await Permission.storage.request();
    if (!status.isGranted && !status.isLimited) {
      if (context.mounted) {
        context.showSnackBar(
            'Storage permission is required for auto-backups.');
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
        style: const TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
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
        style: TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
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
        style: TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      trailing: DropdownButton<String>(
        value: AppConstants.locales
                .any((l) => l.locale == currentLocale)
            ? currentLocale
            : AppConstants.locales.first.locale,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            controller.setLocale(value);
          }
        },
        items: AppConstants.locales
            .map(
              (l) => DropdownMenuItem(
                value: l.locale,
                child: Text(l.label),
              ),
            )
            .toList(),
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
        style: TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      trailing: DropdownButton<String>(
        value: AppConstants.currencies
                .any((c) => c.symbol == currentCurrency)
            ? currentCurrency
            : AppConstants.currencies.first.symbol,
        underline: const SizedBox(),
        onChanged: (value) {
          if (value != null) {
            controller.setCurrencySymbol(value);
          }
        },
        items: AppConstants.currencies
            .map(
              (c) => DropdownMenuItem(
                value: c.symbol,
                child: Text(c.label),
              ),
            )
            .toList(),
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
        style: const TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
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
        style: const TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  /// A tile whose action is not yet available. Tapping shows a planned-feature
  /// notice. A pill badge is shown instead of a chevron.
  Widget _buildComingSoonTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: SettingsTileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAccent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: const Text(
          'Soon',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      onTap: () => showPlannedFeatureNotice(
        context,
        title: title,
        message: 'This security feature is coming in a future update.',
      ),
    );
  }

  /// A destructive action tile with red accent colours.
  Widget _buildDangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.danger, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
            color: AppColors.danger, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.danger),
      onTap: onTap,
    );
  }

  // ── Update tile ──────────────────────────────────────────────────────────

  Widget _buildUpdateTile(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UpdateInfo?> state,
  ) {
    // Loading
    if (state.isLoading) {
      return ListTile(
        leading: const SettingsTileIcon(icon: Icons.system_update_outlined),
        title: const Text(
          'Checking for Updates\u2026',
          style: TextStyle(
              color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        subtitle: const Text(
          'Please wait a moment',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Update available
    if (state.hasValue && state.value != null) {
      final info = state.value!;
      return ListTile(
        leading: const SettingsTileIcon(icon: Icons.system_update_outlined),
        title: const Text(
          'Update Available',
          style: TextStyle(
              color: AppColors.primaryBlue, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'v${info.latestVersion} is ready to download',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        trailing: const _UpdateBadge(label: 'Download'),
        onTap: () => _showUpdateDialog(context, ref, info),
      );
    }

    // Error
    if (state.hasError) {
      return ListTile(
        leading: const SettingsTileIcon(icon: Icons.system_update_outlined),
        title: const Text(
          'Check for Updates',
          style: TextStyle(
              color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        subtitle: const Text(
          'Could not connect. Tap to retry',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        trailing:
            const Icon(Icons.refresh_rounded, color: AppColors.textMuted),
        onTap: () => ref.read(updateCheckerProvider.notifier).check(),
      );
    }

    // Default: not yet checked
    return ListTile(
      leading: const SettingsTileIcon(icon: Icons.system_update_outlined),
      title: const Text(
        'Check for Updates',
        style: TextStyle(
            color: AppColors.textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        'Current version: v${AppConstants.version}',
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () => ref.read(updateCheckerProvider.notifier).check(),
    );
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    UpdateInfo info,
  ) async {
    final notes = info.releaseNotes;
    final hasNotes = notes != null && notes.trim().isNotEmpty;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.system_update_outlined, color: AppColors.primaryBlue),
            SizedBox(width: 10),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version of XPensa is available.\n\n'
              'v${AppConstants.version}  \u2192  v${info.latestVersion}',
              style: const TextStyle(fontSize: 14),
            ),
            if (hasNotes) ...[
              const SizedBox(height: 12),
              const Text(
                "What's new:",
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                notes!.length > _kMaxReleaseNotesLength
                    ? '${notes.substring(0, _kMaxReleaseNotesLength).trimRight()}\u2026'
                    : notes,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final uri = Uri.parse(info.releaseUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              } else if (context.mounted) {
                context.showSnackBar(
                  'Could not open the download link. '
                  'Visit github.com/mini-page/XPensa/releases manually.',
                );
              }
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }
}

// ── Private widget ────────────────────────────────────────────────────────────

/// Small pill badge used as the trailing widget on the "Update Available" tile.
class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Constants ─────────────────────────────────────────────────────────────────

/// Maximum number of characters shown for release notes in the update dialog.
const int _kMaxReleaseNotesLength = 280;
