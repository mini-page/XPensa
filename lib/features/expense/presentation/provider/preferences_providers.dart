import 'dart:convert';
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

final disabledExpenseCategoriesProvider = Provider<Set<String>>((ref) {
  return ref
          .watch(appPreferencesProvider)
          .value
          ?.disabledExpenseCategories
          .toSet() ??
      AppPreferencesModel.defaults.disabledExpenseCategories.toSet();
});

final disabledIncomeCategoriesProvider = Provider<Set<String>>((ref) {
  return ref
          .watch(appPreferencesProvider)
          .value
          ?.disabledIncomeCategories
          .toSet() ??
      AppPreferencesModel.defaults.disabledIncomeCategories.toSet();
});

final disabledAccountIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(appPreferencesProvider).value?.disabledAccountIds.toSet() ??
      AppPreferencesModel.defaults.disabledAccountIds.toSet();
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

final displayNameProvider = Provider<String>((ref) {
  return ref.watch(appPreferencesProvider).value?.displayName ??
      AppPreferencesModel.defaults.displayName;
});

final isPinEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.isPinEnabled ?? false;
});

final biometricLockEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).value?.biometricLockEnabled ??
      AppPreferencesModel.defaults.biometricLockEnabled;
});

final savingsGoalsJsonProvider = Provider<String>((ref) {
  return ref.watch(appPreferencesProvider).value?.savingsGoalsJson ?? '';
});

final customQuickAmountsProvider = Provider<List<double>>((ref) {
  final json =
      ref.watch(appPreferencesProvider).value?.customQuickAmountsJson ?? '';
  if (json.isEmpty) return const <double>[];
  try {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => (e as num).toDouble()).toList();
  } catch (_) {
    return const <double>[];
  }
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
  final key = ref.watch(appPreferencesProvider).value?.themeModeKey ??
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

  Future<void> setDisplayName(String name) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(displayName: name));
  }

  Future<void> setPin(String pinHash) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(pinHash: pinHash));
  }

  Future<void> clearPin() async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(clearPin: true));
  }

  Future<void> setBiometricLock(bool enabled) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(biometricLockEnabled: enabled));
  }

  Future<void> setWhatsNewShownVersion(String version) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(whatsNewShownVersion: version));
  }

  Future<void> setSavingsGoalsJson(String json) async {
    await _ref
        .read(appPreferencesProvider.notifier)
        .save(_current.copyWith(savingsGoalsJson: json));
  }

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
    await _ref.read(appPreferencesProvider.notifier).save(
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

  Future<void> setCustomQuickAmounts(List<double> amounts) async {
    await _ref.read(appPreferencesProvider.notifier).save(
          _current.copyWith(
            customQuickAmountsJson: jsonEncode(amounts),
          ),
        );
  }

  Future<void> setExpenseCategoryEnabled(
    String categoryName,
    bool enabled,
  ) async {
    await _saveAndEnsure(
      _current.copyWith(
        disabledExpenseCategories: _toggleDisabledValue(
          _current.disabledExpenseCategories,
          categoryName,
          enabled,
        ),
      ),
    );
  }

  Future<void> setIncomeCategoryEnabled(
    String categoryName,
    bool enabled,
  ) async {
    await _saveAndEnsure(
      _current.copyWith(
        disabledIncomeCategories: _toggleDisabledValue(
          _current.disabledIncomeCategories,
          categoryName,
          enabled,
        ),
      ),
    );
  }

  Future<void> setAccountEnabled(String accountId, bool enabled) async {
    await _saveAndEnsure(
      _current.copyWith(
        disabledAccountIds: _toggleDisabledValue(
          _current.disabledAccountIds,
          accountId,
          enabled,
        ),
      ),
    );
  }

  Future<void> updateAll({
    required String themeModeKey,
    required String locale,
    required String currencySymbol,
    required bool smartRemindersEnabled,
    required bool isOnboardingCompleted,
  }) async {
    await _ref.read(appPreferencesProvider.notifier).save(
          _current.copyWith(
            themeModeKey: themeModeKey,
            locale: locale,
            currencySymbol: currencySymbol,
            smartRemindersEnabled: smartRemindersEnabled,
            isOnboardingCompleted: isOnboardingCompleted,
          ),
        );
  }

  List<String> _toggleDisabledValue(
    List<String> currentValues,
    String value,
    bool enabled,
  ) {
    final next = currentValues.toSet();
    if (enabled) {
      next.remove(value);
    } else {
      next.add(value);
    }
    return next.toList()..sort();
  }

  Future<void> _saveAndEnsure(AppPreferencesModel next) async {
    await _ref.read(appPreferencesProvider.notifier).save(next);
    final state = _ref.read(appPreferencesProvider);
    if (state case AsyncError<AppPreferencesModel>(:final error)) {
      throw error;
    }
  }
}
