import 'package:hive/hive.dart';

class AppPreferencesModel {
  const AppPreferencesModel({
    required this.themeModeKey,
    required this.privacyModeEnabled,
    required this.smartRemindersEnabled,
    required this.locale,
    required this.currencySymbol,
  });

  static const AppPreferencesModel defaults = AppPreferencesModel(
    themeModeKey: 'light',
    privacyModeEnabled: false,
    smartRemindersEnabled: true,
    locale: 'en_IN',
    currencySymbol: '₹',
  );

  final String themeModeKey;
  final bool privacyModeEnabled;
  final bool smartRemindersEnabled;
  final String locale;
  final String currencySymbol;

  AppPreferencesModel copyWith({
    String? themeModeKey,
    bool? privacyModeEnabled,
    bool? smartRemindersEnabled,
    String? locale,
    String? currencySymbol,
  }) {
    return AppPreferencesModel(
      themeModeKey: themeModeKey ?? this.themeModeKey,
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
      smartRemindersEnabled:
          smartRemindersEnabled ?? this.smartRemindersEnabled,
      locale: locale ?? this.locale,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }
}

class AppPreferencesModelAdapter extends TypeAdapter<AppPreferencesModel> {
  static const int typeIdValue = 3;

  @override
  final int typeId = typeIdValue;

  @override
  AppPreferencesModel read(BinaryReader reader) {
    final themeModeKey = reader.readString();
    final privacyModeEnabled = reader.readBool();
    final smartRemindersEnabled = reader.readBool();

    // Migration: Check if more data exists for new fields
    String locale = AppPreferencesModel.defaults.locale;
    String currencySymbol = AppPreferencesModel.defaults.currencySymbol;

    try {
      if (reader.availableBytes > 0) {
        locale = reader.readString();
      }
      if (reader.availableBytes > 0) {
        currencySymbol = reader.readString();
      }
    } catch (_) {
      // Fallback to defaults if reading fails
    }

    return AppPreferencesModel(
      themeModeKey: themeModeKey,
      privacyModeEnabled: privacyModeEnabled,
      smartRemindersEnabled: smartRemindersEnabled,
      locale: locale,
      currencySymbol: currencySymbol,
    );
  }

  @override
  void write(BinaryWriter writer, AppPreferencesModel obj) {
    writer
      ..writeString(obj.themeModeKey)
      ..writeBool(obj.privacyModeEnabled)
      ..writeBool(obj.smartRemindersEnabled)
      ..writeString(obj.locale)
      ..writeString(obj.currencySymbol);
  }
}
