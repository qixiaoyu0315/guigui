import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/turtle_record.dart';

class TurtleService {
  static const String _recordsKey = 'turtle_records';

  // 获取所有记录
  static Future<List<TurtleRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(_recordsKey) ?? [];
    
    return recordsJson
        .map((json) => TurtleRecord.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // 按时间排序
  }

  // 添加新记录
  static Future<void> addRecord(TurtleRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.add(record);
    
    final recordsJson = records
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList(_recordsKey, recordsJson);
  }

  // 删除记录
  static Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.removeWhere((record) => record.id == id);
    
    final recordsJson = records
        .map((record) => jsonEncode(record.toJson()))
        .toList();
    
    await prefs.setStringList(_recordsKey, recordsJson);
  }

  // 更新记录
  static Future<void> updateRecord(TurtleRecord updatedRecord) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    
    final index = records.indexWhere((record) => record.id == updatedRecord.id);
    if (index != -1) {
      records[index] = updatedRecord;
      
      final recordsJson = records
          .map((record) => jsonEncode(record.toJson()))
          .toList();
      
      await prefs.setStringList(_recordsKey, recordsJson);
    }
  }
}
