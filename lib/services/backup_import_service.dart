import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'database_helper.dart';

class BackupImportService {
  // 导出为JSON备份，返回生成的文件
  static Future<File> exportJsonBackup() async {
    final file = await DatabaseHelper.instance.exportJson();
    return file;
  }

  // 让用户选择一个JSON文件并导入
  static Future<void> importFromJsonWithPicker({bool clearExisting = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return; // 用户取消

    final path = result.files.single.path;
    if (path == null) return;

    final file = File(path);
    await DatabaseHelper.instance.importJson(file, clearExisting: clearExisting);
  }
}
