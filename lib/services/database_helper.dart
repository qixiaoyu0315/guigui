import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/turtle.dart';
import '../models/turtle_record.dart';

class DatabaseHelper {
  static const _dbName = 'guigui.db';
  static const _dbVersion = 1;

  static const tableTurtles = 'turtles';
  static const tableRecords = 'records';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableTurtles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            species TEXT NOT NULL,
            birthDate TEXT NOT NULL,
            color INTEGER NOT NULL,
            description TEXT,
            photoPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $tableRecords (
            id TEXT PRIMARY KEY,
            turtleId TEXT NOT NULL,
            date TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            weight REAL,
            length REAL,
            width REAL,
            photoPath TEXT,
            notes TEXT,
            FOREIGN KEY(turtleId) REFERENCES $tableTurtles(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // Turtles CRUD
  Future<List<Turtle>> getAllTurtles() async {
    final db = await database;
    final maps = await db.query(tableTurtles);
    return maps.map((m) => Turtle.fromMap(m)).toList();
  }

  Future<Turtle?> getTurtleById(String id) async {
    final db = await database;
    final maps = await db.query(
      tableTurtles,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Turtle.fromMap(maps.first);
  }

  Future<void> insertTurtle(Turtle turtle) async {
    final db = await database;
    await db.insert(
      tableTurtles,
      turtle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTurtle(Turtle turtle) async {
    final db = await database;
    await db.update(
      tableTurtles,
      turtle.toMap(),
      where: 'id = ?',
      whereArgs: [turtle.id],
    );
  }

  Future<void> deleteTurtle(String id) async {
    final db = await database;
    await db.delete(tableTurtles, where: 'id = ?', whereArgs: [id]);
  }

  // Records CRUD
  Future<List<TurtleRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(tableRecords);
    return maps.map((m) => TurtleRecord.fromMap(m)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<TurtleRecord>> getRecordsByTurtle(String turtleId) async {
    final db = await database;
    final maps = await db.query(
      tableRecords,
      where: 'turtleId = ?',
      whereArgs: [turtleId],
    );
    return maps.map((m) => TurtleRecord.fromMap(m)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> insertRecord(TurtleRecord record) async {
    final db = await database;
    await db.insert(
      tableRecords,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRecord(TurtleRecord record) async {
    final db = await database;
    await db.update(
      tableRecords,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete(tableRecords, where: 'id = ?', whereArgs: [id]);
  }

  // Backup JSON
  Future<File> exportJson() async {
    final db = await database;
    final turtles = await db.query(tableTurtles);
    final records = await db.query(tableRecords);

    final data = {
      'turtles': turtles,
      'records': records,
      'exportedAt': DateTime.now().toIso8601String(),
      'dbVersion': _dbVersion,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'guigui_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> importJson(File jsonFile, {bool clearExisting = false}) async {
    final content = await jsonFile.readAsString();
    final map = jsonDecode(content) as Map<String, dynamic>;
    final db = await database;
    final batch = db.batch();

    if (clearExisting) {
      batch.delete(tableRecords);
      batch.delete(tableTurtles);
    }

    final turtles = (map['turtles'] as List<dynamic>? ?? []).cast<Map>().map(
      (e) => e.cast<String, dynamic>(),
    );
    for (final t in turtles) {
      batch.insert(
        tableTurtles,
        Map<String, Object?>.from(t),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final records = (map['records'] as List<dynamic>? ?? []).cast<Map>().map(
      (e) => e.cast<String, dynamic>(),
    );
    for (final r in records) {
      batch.insert(
        tableRecords,
        Map<String, Object?>.from(r),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // Export/Import raw DB file
  Future<File> getDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    return File(p.join(dbPath, _dbName));
  }
}
