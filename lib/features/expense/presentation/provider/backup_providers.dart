import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/datasource/account_local_datasource.dart';
import '../../data/datasource/backup_local_datasource.dart';
import '../../data/datasource/budget_local_datasource.dart';
import '../../data/datasource/expense_local_datasource.dart';
import '../../data/datasource/recurring_subscription_local_datasource.dart';
import '../../../../core/utils/hive_bootstrap.dart';

final backupLocalDatasourceProvider = Provider<BackupLocalDatasource>((ref) {
  return BackupLocalDatasource();
});

final backupControllerProvider = Provider<BackupController>((ref) {
  return BackupController(ref);
});

class BackupController {
  final Ref _ref;

  BackupController(this._ref);

  BackupLocalDatasource get _datasource =>
      _ref.read(backupLocalDatasourceProvider);

  Future<void> exportData() async {
    try {
      final backupFile = await _datasource.createBackup();

      // Share the file so user can save it anywhere
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'XPensa Data Backup',
      );

      // Clean up temporary file after sharing
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType
            .any, // .xpensa might not be recognized as a custom type easily
      );

      if (result == null || result.files.single.path == null) {
        return false;
      }

      final file = File(result.files.single.path!);

      // Basic validation: check extension if possible, or just attempt decode
      if (!file.path.endsWith(BackupLocalDatasource.backupExtension)) {
        throw Exception('Invalid file format. Please select a .xpensa file.');
      }

      // Close all Hive boxes before overwriting
      await Hive.close();

      await _datasource.restoreBackup(file);

      // Re-initialize Hive
      await HiveBootstrap.initialize();

      return true;
    } catch (e) {
      // Ensure Hive is re-initialized even on error if boxes were closed
      await HiveBootstrap.initialize();
      rethrow;
    }
  }

  /// Permanently clears all user data boxes (expenses, accounts, budgets,
  /// subscriptions). App preferences are intentionally preserved.
  Future<void> resetAllData() async {
    await Hive.box(ExpenseLocalDatasource.boxName).clear();
    await Hive.box(AccountLocalDatasource.boxName).clear();
    await Hive.box(BudgetLocalDatasource.boxName).clear();
    await Hive.box(RecurringSubscriptionLocalDatasource.boxName).clear();
  }
}
