import 'package:hive/hive.dart';

class AppPreferencesModel {
  const AppPreferencesModel({
    required this.themeModeKey,
    required this.privacyModeEnabled,
    required this.smartRemindersEnabled,
  });

  static const AppPreferencesModel defaults = AppPreferencesModel(
    themeModeKey: 'light',
    privacyModeEnabled: false,
    smartRemindersEnabled: true,
  );

  final String themeModeKey;
  final bool privacyModeEnabled;
  final bool smartRemindersEnabled;

  AppPreferencesModel copyWith({
    String? themeModeKey,
    bool? privacyModeEnabled,
    bool? smartRemindersEnabled,
  }) {
    return AppPreferencesModel(
      themeModeKey: themeModeKey ?? this.themeModeKey,
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
      smartRemindersEnabled:
          smartRemindersEnabled ?? this.smartRemindersEnabled,
    );
  }
}

class AppPreferencesModelAdapter extends TypeAdapter<AppPreferencesModel> {
  static const int typeIdValue = 3;

  @override
  final int typeId = typeIdValue;

  @override
  AppPreferencesModel read(BinaryReader reader) {
    return AppPreferencesModel(
      themeModeKey: reader.readString(),
      privacyModeEnabled: reader.readBool(),
      smartRemindersEnabled: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, AppPreferencesModel obj) {
    writer
      ..writeString(obj.themeModeKey)
      ..writeBool(obj.privacyModeEnabled)
      ..writeBool(obj.smartRemindersEnabled);
  }
}
