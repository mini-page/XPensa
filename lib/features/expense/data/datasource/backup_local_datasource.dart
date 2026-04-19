import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupLocalDatasource {
  static const String backupExtension = '.xpensa';

  Future<File> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupFile = File(p.join(appDir.path,
        'xpensa_backup${DateTime.now().millisecondsSinceEpoch}$backupExtension'));

    final encoder = ZipFileEncoder();
    encoder.create(backupFile.path);

    final directory = Directory(appDir.path);
    final files = directory.listSync();

    for (final file in files) {
      if (file is File &&
          (file.path.endsWith('.hive') || file.path.endsWith('.lock'))) {
        encoder.addFile(file);
      }
    }

    encoder.close();
    return backupFile;
  }

  Future<void> restoreBackup(File backupFile) async {
    final appDir = await getApplicationDocumentsDirectory();

    // Extract archive
    final bytes = await backupFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(p.join(appDir.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }
  }

  Future<Directory> getAppDirectory() async {
    return getApplicationDocumentsDirectory();
  }
}
