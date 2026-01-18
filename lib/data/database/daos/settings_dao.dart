import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<UserSetting?> getSettings() {
    return select(userSettings).getSingleOrNull();
  }

  Stream<UserSetting?> watchSettings() {
    return select(userSettings).watchSingleOrNull();
  }

  Future<int> updateSettings(UserSettingsCompanion settings) {
    return (update(userSettings)..where((s) => s.id.equals(1))).write(settings);
  }
}
