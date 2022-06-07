import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.getInstance();

  DatabaseHelper.getInstance();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _initDb();

    return _db;
  }

  Future _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'visits.db');
    if(kDebugMode){
      print("db $path");
    }

    var db = await openDatabase(path, version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  Future deleteDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'visits.db');
    _db = null;
    deleteDatabase(path);
  }

  void _onCreate(Database db, int newVersion) async {
    String s = await rootBundle.loadString("assets/sql/create.sql");

    List<String> sqls = s.split(";");

    for (String sql in sqls) {
      if (sql.trim().isNotEmpty) {
        if(kDebugMode){
          print("sql: $sql");
        }
        await db.execute(sql);
      }
    }
  }

  Future<FutureOr<void>> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if(kDebugMode){
      print("_onUpgrade: oldVersion: $oldVersion > newVersion: $newVersion");
    }

  }

  Future close() async {
    var dbClient = await db;
    return dbClient!.close();
  }
}
