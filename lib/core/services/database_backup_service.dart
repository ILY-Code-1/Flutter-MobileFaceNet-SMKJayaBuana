import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/app_database.dart';

/// Creates a portable `.sql` backup of the SQLite database so it can be
/// attached when the admin contacts the developer for troubleshooting.
class DatabaseBackupService {
  DatabaseBackupService._();
  static final DatabaseBackupService instance = DatabaseBackupService._();

  /// Dumps the current database (schema + data) to a `.sql` file inside the
  /// temporary directory and returns that file. The file name is stamped
  /// with the moment the backup was taken.
  Future<File> writeSqlBackup() async {
    final sql = await AppDatabase.instance.exportSqlDump();
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, 'backup_smk_jaya_buana_${_stamp(DateTime.now())}.sql'),
    );
    await file.writeAsString(sql, flush: true);
    return file;
  }

  static String _stamp(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}${two(d.month)}${two(d.day)}'
        '_${two(d.hour)}${two(d.minute)}${two(d.second)}';
  }
}
