import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';
import '../../features/expense/data/datasource/preferences_local_datasource.dart';
import '../../features/expense/data/models/app_preferences_model.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();

      // We need the adapter to read preferences
      if (!Hive.isAdapterRegistered(AppPreferencesModelAdapter.typeIdValue)) {
        Hive.registerAdapter(AppPreferencesModelAdapter());
      }

      final box = await Hive.openBox<AppPreferencesModel>(
          PreferencesLocalDatasource.boxName);
      final preferences = box.get(PreferencesLocalDatasource.boxName);

      if (preferences == null ||
          !preferences.autoBackupEnabled ||
          preferences.backupDirectoryPath == null) {
        await box.close();
        return Future.value(true);
      }

      final appDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(preferences.backupDirectoryPath!);

      if (!await targetDir.exists()) {
        await box.close();
        return Future.value(true); // Directory disappeared, nothing to do
      }

      // Create a timestamped backup folder or file
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final backupFolder =
          Directory(p.join(targetDir.path, 'xpensa_backup_$timestamp'));
      await backupFolder.create(recursive: true);

      final sourceDir = Directory(appDir.path);
      await for (final entity in sourceDir.list()) {
        if (entity is File &&
            (entity.path.endsWith('.hive') || entity.path.endsWith('.lock'))) {
          final fileName = p.basename(entity.path);
          await entity.copy(p.join(backupFolder.path, fileName));
        }
      }

      // Update last backup time
      await box.put(
          PreferencesLocalDatasource.boxName,
          preferences.copyWith(
            lastBackupDateTime: DateTime.now(),
          ));

      await box.close();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
