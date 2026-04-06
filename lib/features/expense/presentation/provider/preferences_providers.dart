import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

import '../../data/datasource/preferences_local_datasource.dart';
import '../../data/models/app_preferences_model.dart';
import '../../data/repositories/hive_preferences_repository.dart';
import '../../domain/repositories/preferences_repository.dart';

const String backupTaskTag = 'xpensa_offline_backup';

final preferencesLocalDatasourceProvider = Provider<PreferencesLocalDatasource>(
  (ref) {
    return PreferencesLocalDatasource();
  },
);

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return HivePreferencesRepository(
    ref.watch(preferencesLocalDatasourceProvider),
  );
});

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferencesModel>(
      AppPreferencesNotifier.new,
    );

final appPreferencesControllerProvider = Provider<AppPreferencesController>((
  ref,
) {
  return AppPreferencesController(ref);
});

final privacyModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.privacyModeEnabled ??
      AppPreferencesModel.defaults.privacyModeEnabled;
});

final localeProvider = Provider<String>((ref) {
  return ref.watch(appPreferencesProvider).value?.locale ??
      AppPreferencesModel.defaults.locale;
});

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(appPreferencesProvider).value?.currencySymbol ??
      AppPreferencesModel.defaults.currencySymbol;
});

/// A [NumberFormat] pre-configured with the user's locale and currency symbol,
/// using 0 decimal digits. Use this for displaying whole-number currency amounts.
final currencyFormatProvider = Provider<NumberFormat>((ref) {
  return NumberFormat.currency(
    locale: ref.watch(localeProvider),
    symbol: ref.watch(currencySymbolProvider),
    decimalDigits: 0,
  );
});

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.isOnboardingCompleted ??
      AppPreferencesModel.defaults.isOnboardingCompleted;
});

final smartRemindersEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.smartRemindersEnabled ??
      AppPreferencesModel.defaults.smartRemindersEnabled;
});

final autoBackupEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.autoBackupEnabled ??
      AppPreferencesModel.defaults.autoBackupEnabled;
});

final backupFrequencyProvider = Provider<String>((ref) {
  return ref.watch(appPreferencesProvider).value?.backupFrequency ??
      AppPreferencesModel.defaults.backupFrequency;
});

final backupDirectoryPathProvider = Provider<String?>((ref) {
  return ref.watch(appPreferencesProvider).value?.backupDirectoryPath;
});

final lastBackupDateTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(appPreferencesProvider).value?.lastBackupDateTime;
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final key =
      ref.watch(appPreferencesProvider).value?.themeModeKey ??
      AppPreferencesModel.defaults.themeModeKey;
  switch (key) {
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.light;
  }
});

class AppPreferencesNotifier extends AsyncNotifier<AppPreferencesModel> {
  PreferencesRepository get _repository =>
      ref.read(preferencesRepositoryProvider);

  @override
  Future<AppPreferencesModel> build() async {
    try {
      return await _repository.getPreferences();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        dev.log(
          'Failed to fetch preferences',
          error: e,
          stackTrace: stackTrace,
          name: 'AppPreferencesNotifier',
        );
      }
      return AppPreferencesModel.defaults;
    }
  }

  Future<void> save(AppPreferencesModel preferences) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.savePreferences(preferences);
      return preferences;
    });
  }
}

class AppPreferencesController {
  AppPreferencesController(this._ref);

  final Ref _ref;

  AppPreferencesModel get _current =>
      _ref.read(appPreferencesProvider).value ?? AppPreferencesModel.defaults;

  Future<void> setThemeMode(String themeModeKey) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(themeModeKey: themeModeKey));
  }

  Future<void> setPrivacyMode(bool enabled) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(privacyModeEnabled: enabled));
  }

  Future<void> setSmartReminders(bool enabled) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(smartRemindersEnabled: enabled));
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(isOnboardingCompleted: completed));
  }

  Future<void> setLocale(String locale) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(locale: locale));
  }

  Future<void> setCurrencySymbol(String currencySymbol) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(currencySymbol: currencySymbol));
  }

  Future<void> setAutoBackup(bool enabled) async {
    final next = _current.copyWith(autoBackupEnabled: enabled);
    await _ref.read(appPreferencesProvider.notifier).save(next);

    if (enabled) {
      _scheduleBackup(next.backupFrequency);
    } else {
      Workmanager().cancelByTag(backupTaskTag);
    }
  }

  Future<void> setBackupFrequency(String frequency) async {
    final next = _current.copyWith(backupFrequency: frequency);
    await _ref.read(appPreferencesProvider.notifier).save(next);

    if (next.autoBackupEnabled) {
      _scheduleBackup(frequency);
    }
  }

  void _scheduleBackup(String frequency) {
    Duration duration;
    switch (frequency) {
      case 'weekly':
        duration = const Duration(days: 7);
        break;
      case 'monthly':
        duration = const Duration(days: 30);
        break;
      default:
        duration = const Duration(days: 1);
    }

    Workmanager().registerPeriodicTask(
      'xpensa-periodic-backup',
      'xpensa-periodic-backup-task',
      tag: backupTaskTag,
      frequency: duration,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresStorageNotLow: true,
      ),
    );
  }

  Future<void> setBackupDirectory(String? path) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(
          _current.copyWith(
            backupDirectoryPath: path,
            clearBackupDirectory: path == null,
          ),
        );
  }

  Future<void> setLastBackup(DateTime dateTime) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(lastBackupDateTime: dateTime));
  }

  Future<void> updateAll({
    required String themeModeKey,
    required String locale,
    required String currencySymbol,
    required bool smartRemindersEnabled,
    required bool isOnboardingCompleted,
  }) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(
          _current.copyWith(
            themeModeKey: themeModeKey,
            locale: locale,
            currencySymbol: currencySymbol,
            smartRemindersEnabled: smartRemindersEnabled,
            isOnboardingCompleted: isOnboardingCompleted,
          ),
        );
  }
}
