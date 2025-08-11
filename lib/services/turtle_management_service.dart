import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/turtle.dart';

class TurtleManagementService {
  static const String _turtlesKey = 'turtles';

  // 获取所有乌龟
  static Future<List<Turtle>> getTurtles() async {
    final prefs = await SharedPreferences.getInstance();
    final turtlesJson = prefs.getStringList(_turtlesKey) ?? [];
    
    return turtlesJson
        .map((json) => Turtle.fromJson(jsonDecode(json)))
        .toList();
  }

  // 添加新乌龟
  static Future<void> addTurtle(Turtle turtle) async {
    final prefs = await SharedPreferences.getInstance();
    final turtles = await getTurtles();
    turtles.add(turtle);
    
    final turtlesJson = turtles
        .map((turtle) => jsonEncode(turtle.toJson()))
        .toList();
    
    await prefs.setStringList(_turtlesKey, turtlesJson);
  }

  // 删除乌龟
  static Future<void> deleteTurtle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final turtles = await getTurtles();
    turtles.removeWhere((turtle) => turtle.id == id);
    
    final turtlesJson = turtles
        .map((turtle) => jsonEncode(turtle.toJson()))
        .toList();
    
    await prefs.setStringList(_turtlesKey, turtlesJson);
  }

  // 更新乌龟
  static Future<void> updateTurtle(Turtle updatedTurtle) async {
    final prefs = await SharedPreferences.getInstance();
    final turtles = await getTurtles();
    
    final index = turtles.indexWhere((turtle) => turtle.id == updatedTurtle.id);
    if (index != -1) {
      turtles[index] = updatedTurtle;
      
      final turtlesJson = turtles
          .map((turtle) => jsonEncode(turtle.toJson()))
          .toList();
      
      await prefs.setStringList(_turtlesKey, turtlesJson);
    }
  }

  // 根据ID获取乌龟
  static Future<Turtle?> getTurtleById(String id) async {
    final turtles = await getTurtles();
    try {
      return turtles.firstWhere((turtle) => turtle.id == id);
    } catch (e) {
      return null;
    }
  }
}
