import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/data/sources/data_store_service.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageService extends DataStoreService {
  static final LocalStorageService instance = LocalStorageService._init();
  static Database? _database;
  LocalStorageService();
  LocalStorageService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exercise_cache.db');
    return _database!;
  }

  @override
  Future<void> deleteAllExercises() {
    // TODO: implement deleteAllExcercises
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExerciseById(int id) async {
    var db = await database;
    await db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ExerciseModel>> getAllExercises(String userId) async {
    var db = await database;
    final data = await db.query(
      'workouts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    var res = data.map((json) => ExerciseModel.fromJson(json)).toList();
    return res;
  }

  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    var db = await database;
    return await db.query('users');
  }

  @override
  Future<ExerciseModel?> getExerciseById(int id) async {
    var db = await database;
    final data = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (data.isNotEmpty) {
      return ExerciseModel.fromJson(data.first);
    }
    return null;
  }

  /// Inserts user data into local storage
  Future<void> registerUser(UserModel payload) async {
    var db = await database;
    await db.insert(
      'users',
      payload.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    await getAllUsers();
  }

  @override
  Future<void> saveExercise(ExerciseModel payload) async {
    var db = await database;
    await db.insert(
      'workouts',
      payload.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> deleteDatabaseFile() async {
    // Get the database path
    final dbPath = await getDatabasesPath();
    final dbName = 'workouts.db'; // Replace with your database name
    final dbFullPath = join(dbPath, dbName);

    // Delete the database file
    await deleteDatabase(dbFullPath);
    print('Database deleted: $dbFullPath');
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

  Future<Database> _initDB(String filePath) async {
    // deleteDatabaseFile();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
}
