import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:async';
import '../models/task.dart';

class DatabaseHelper {
  static const _databaseName = 'todo_final.db';
  static const _databaseVersion = 3;

  static const table = 'tasks';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnIsDone = 'is_done';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  final StreamController<List<Task>> _taskStream = StreamController.broadcast();

  Stream<List<Task>> get tasksStream => _taskStream.stream;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, _databaseName);
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnIsDone INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> refreshData() async {
    final tasks = await getAllTasks();
    _taskStream.add(tasks);
  }

  Future<int> insert(Task task) async {
    final db = await database;
    final id = await db.insert(table, task.toMap());
    await refreshData();
    return id;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> update(Task task) async {
    final db = await database;
    final count = await db.update(
      table,
      task.toMap(),
      where: '$columnId = ?',
      whereArgs: [task.id],
    );
    await refreshData();
    return count;
  }

  Future<int> delete(int id) async {
    final db = await database;
    final count = await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    await refreshData();
    return count;
  }

  Future<void> close() async {
    await _taskStream.close();
    await _database?.close();
  }
}
