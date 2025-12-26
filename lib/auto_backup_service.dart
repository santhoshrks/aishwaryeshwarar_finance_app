import 'package:shared_preferences/shared_preferences.dart';

import 'backup_service.dart';

class AutoBackupService {
  static Future<void> runWeeklyBackup() async {
    final prefs = await SharedPreferences.getInstance();

    final lastBackupTime = prefs.getInt('lastBackupTime') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    const oneWeek = 7 * 24 * 60 * 60 * 1000;

    if (now - lastBackupTime >= oneWeek) {
      await BackupService.createBackup();

      await prefs.setInt('lastBackupTime', now);
    }
  }
}
