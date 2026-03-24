import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/preferences_local_datasource.dart';
import '../../data/models/app_preferences_model.dart';
import '../../data/repositories/hive_preferences_repository.dart';
import '../../domain/repositories/preferences_repository.dart';

final preferencesLocalDatasourceProvider =
    Provider<PreferencesLocalDatasource>((ref) {
  return PreferencesLocalDatasource();
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return HivePreferencesRepository(
      ref.watch(preferencesLocalDatasourceProvider));
});

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesNotifier, AppPreferencesModel>(
  AppPreferencesNotifier.new,
);

final appPreferencesControllerProvider =
    Provider<AppPreferencesController>((ref) {
  return AppPreferencesController(ref);
});

final privacyModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).valueOrNull?.privacyModeEnabled ??
      AppPreferencesModel.defaults.privacyModeEnabled;
});

final smartRemindersEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).valueOrNull?.smartRemindersEnabled ??
      AppPreferencesModel.defaults.smartRemindersEnabled;
});

final appThemeModeProvider = Provider<ThemeMode>((ref) {
  final key = ref.watch(appPreferencesProvider).valueOrNull?.themeModeKey ??
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
    } catch (_) {
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
      _ref.read(appPreferencesProvider).valueOrNull ??
      AppPreferencesModel.defaults;

  Future<void> setThemeMode(String themeModeKey) async {
    await _ref.read(appPreferencesProvider.notifier).save(
          _current.copyWith(themeModeKey: themeModeKey),
        );
  }

  Future<void> setPrivacyMode(bool enabled) async {
    await _ref.read(appPreferencesProvider.notifier).save(
          _current.copyWith(privacyModeEnabled: enabled),
        );
  }

  Future<void> setSmartReminders(bool enabled) async {
    await _ref.read(appPreferencesProvider.notifier).save(
          _current.copyWith(smartRemindersEnabled: enabled),
        );
  }
}
