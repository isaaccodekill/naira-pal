import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'database_provider.dart';

final settingsProvider = StreamProvider<UserSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.settingsDao.watchSettings();
});
