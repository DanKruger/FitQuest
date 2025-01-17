// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:fitquest/data/models/excercise_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CachingService {
  static final CachingService instance = CachingService._init();
  static Database? _database;
  CachingService();
  CachingService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitquest.db');
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    // Get the database path
    final dbPath = await getDatabasesPath();
    final dbName = 'fitquest.db'; // Replace with your database name
    final dbFullPath = join(dbPath, dbName);

    // Delete the database file
    await deleteDatabase(dbFullPath);
    print('Database deleted: $dbFullPath');
  }

  Future<void> cacheHistory(String userId, List<ExerciseModel?> history,
      {bool addNewTimestamp = true}) async {
    var db = await database;
    String serializedHistory = jsonEncode(
      history
          .map(
            (exercise) => exercise?.toJson(),
          )
          .toList(),
    );

    var time = DateTime.now();

    final result = await db.query(
      'workout_history',
      columns: ['timestamp'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      int storedTimestamp = result.first['timestamp'] as int;
      if (addNewTimestamp) {
        time = DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
      }
    }

    await db.insert(
      'workout_history',
      {
        'userId': userId,
        'timestamp': time.millisecondsSinceEpoch,
        'history': serializedHistory,
      },
    );
  }

  Future<HistoryTimestamp> compareTimestampWithCurrentTime(
      String userId) async {
    var db = await database;
    final result = await db.query(
      'workout_history',
      columns: ['timestamp'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      int storedTimestamp = result.first['timestamp'] as int;
      DateTime storedTime =
          DateTime.fromMillisecondsSinceEpoch(storedTimestamp);
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(storedTime);
      if (difference.inMinutes < 30) {
        return HistoryTimestamp.newer;
      } else {
        print("Local Exercise Cache is outdated");
        return HistoryTimestamp.old;
      }
    } else {
      print("Local Exercise Cache not initialized");
      return HistoryTimestamp.none;
    }
  }

  Future<List<ExerciseModel>> getCachedHistory(String userId) async {
    var db = await database;
    final result = await db.query(
      'workout_history',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (result.isEmpty) return [];
    String historyJson = result.first['history'] as String;
    List<dynamic> historyList = jsonDecode(historyJson);
    return historyList.map((e) => ExerciseModel.fromJson(e)).toList();
  }

  Future _createDB(Database db, int version) async {
    await _createExerciseHistory(db);
    await _createWorkoutsTable(db);
    await _createUserInformationTable(db);
  }

  Future<void> _createExerciseHistory(Database db) async {
    await db.execute('''
  CREATE TABLE IF NOT EXISTS workout_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    userId TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    history TEXT NOT NULL
  );
''');
  }

  Future<void> _createUserInformationTable(Database db) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      email TEXT NOT NULL
    );
    ''');
  }

  Future<void> _createWorkoutsTable(Database db) async {
    await db.execute('''
    CREATE TABLE workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT NOT NULL,
      type TEXT NOT NULL,
      date TEXT NOT NULL,
      duration INTEGER NOT NULL,
      distance REAL NOT NULL,
      route TEXT NOT NULL
    );
    ''');
  }

  Future<void> checkExistingTables() async {
    // Get a reference to the database
    final db = await database;

    // Query to get all tables
    final List<Map<String, dynamic>> tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    // Print all table names
    if (tables.isEmpty) {
      print("No tables found in the database.");
    } else {
      print("Tables in the database:");
      for (var table in tables) {
        print(table['name']);
      }
    }
  }

  Future<Database> _initDB(String filePath) async {
    // deleteDatabaseFile();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
}

enum HistoryTimestamp { none, old, newer }
