import '../models/turtle_record.dart';
import 'database_helper.dart';

class TurtleService {
  // 获取所有记录
  static Future<List<TurtleRecord>> getRecords() async {
    return DatabaseHelper.instance.getAllRecords();
  }

  // 添加新记录
  static Future<void> addRecord(TurtleRecord record) async {
    await DatabaseHelper.instance.insertRecord(record);
  }

  // 删除记录
  static Future<void> deleteRecord(String id) async {
    await DatabaseHelper.instance.deleteRecord(id);
  }

  // 更新记录
  static Future<void> updateRecord(TurtleRecord updatedRecord) async {
    await DatabaseHelper.instance.updateRecord(updatedRecord);
  }
}
